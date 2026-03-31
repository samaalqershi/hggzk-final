import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hggzkportal/core/constants/api_constants.dart';
import 'package:hggzkportal/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:hggzkportal/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:hggzkportal/features/chat/data/models/message_model.dart';
import 'package:hggzkportal/features/chat/data/models/message_reaction_model.dart';
import 'package:hggzkportal/features/chat/domain/entities/conversation.dart';
import 'package:hggzkportal/features/chat/domain/entities/message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ChatWebSocketService {
  ChatWebSocketService({
    AuthLocalDataSource? authLocalDataSource,
    ChatRemoteDataSource? remoteDataSource,
  })  : _authLocalDataSource = authLocalDataSource,
        _chatRemoteDataSource = remoteDataSource;

  final AuthLocalDataSource? _authLocalDataSource;
  final ChatRemoteDataSource? _chatRemoteDataSource;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  bool _isConnected = false;
  bool get isConnected => _isConnected;
  bool _disposed = false;

  final _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();
  final _conversationController = StreamController<Conversation>.broadcast();
  final _messageController = StreamController<MessageEvent>.broadcast();
  final _typingController = StreamController<TypingEvent>.broadcast();
  final _presenceController = StreamController<PresenceEvent>.broadcast();
  final _errorController = StreamController<WebSocketError>.broadcast();

  Stream<ConnectionStatus> get connectionStatus =>
      _connectionStatusController.stream;
  Stream<Conversation> get conversationUpdates =>
      _conversationController.stream;
  Stream<ConversationEventWS> get conversationEvents =>
      _conversationController.stream
          .map((c) => ConversationEventWS(conversation: c));
  Stream<MessageEvent> get messageEvents => _messageController.stream;
  Stream<TypingEvent> get typingEvents => _typingController.stream;
  Stream<PresenceEvent> get presenceEvents => _presenceController.stream;
  Stream<WebSocketError> get errors => _errorController.stream;

  Future<void> connect() async {
    if (_disposed || _isConnected) return;

    final token = await _authLocalDataSource?.getCachedAccessToken();
    if (token == null || token.isEmpty) return;

    final uri = Uri.parse(
      '${ApiConstants.resolvedSocketUrl}/ws/chat?access_token=${Uri.encodeQueryComponent(token)}',
    );

    _channel = WebSocketChannel.connect(uri);
    _subscription = _channel!.stream.listen(
      _handleIncomingEvent,
      onDone: _handleDisconnected,
      onError: (error) => _handleError(error),
      cancelOnError: true,
    );

    _isConnected = true;
    _connectionStatusController.add(ConnectionStatus.connected);
    _startHeartbeat();
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close(status.goingAway);
    _channel = null;
    _isConnected = false;
    _connectionStatusController.add(ConnectionStatus.disconnected);
  }

  void emitReactionUpdate({
    required String conversationId,
    required String messageId,
    required String userId,
    required String reactionType,
    required bool isAdded,
  }) {
    try {
      final reaction = MessageReactionModel.fromJson({
        'id': 'temp_${DateTime.now().microsecondsSinceEpoch}',
        'message_id': messageId,
        'user_id': userId,
        'reaction_type': reactionType,
      });
      _messageController.add(MessageEvent(
        type: isAdded
            ? MessageEventType.reactionAdded
            : MessageEventType.reactionRemoved,
        messageId: messageId,
        conversationId: conversationId,
        reaction: reaction,
      ));
    } catch (e) {
      debugPrint('emitReactionUpdate error: $e');
    }
  }

  void emitNewMessageById({
    required String conversationId,
    required String messageId,
  }) {
    _messageController.add(MessageEvent(
      type: MessageEventType.newMessage,
      messageId: messageId,
      conversationId: conversationId,
    ));
  }

  void emitMessageStatusUpdate({
    required String conversationId,
    required String messageId,
    required String status,
    DateTime? deliveredAt,
    DateTime? readAt,
  }) {
    _messageController.add(MessageEvent(
      type: MessageEventType.statusUpdated,
      messageId: messageId,
      conversationId: conversationId,
      status: status,
      deliveredAt: deliveredAt,
      readAt: readAt,
    ));
  }

  Future<void> emitConversationById({
    required String conversationId,
  }) async {
    try {
      if (_chatRemoteDataSource == null) return;
      final conversation =
          await _chatRemoteDataSource!.getConversationById(conversationId);
      _conversationController.add(conversation);
    } catch (e) {
      debugPrint('emitConversationById error: $e');
    }
  }

  void sendTypingIndicator(String conversationId, bool isTyping) {
    _send({
      'type': isTyping ? 'typing.start' : 'typing.stop',
      'conversationId': conversationId,
    });
  }

  void markMessagesAsRead(String conversationId, List<String> messageIds) {
    _send(const {'type': 'ping'});
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _connectionStatusController.close();
    _conversationController.close();
    _messageController.close();
    _typingController.close();
    _presenceController.close();
    _errorController.close();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _send(const {'type': 'ping'});
    });
  }

  void _send(Map<String, dynamic> payload) {
    if (!_isConnected || _channel == null) return;
    try {
      _channel!.sink.add(jsonEncode(payload));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _handleIncomingEvent(dynamic raw) async {
    Map<String, dynamic>? event;
    try {
      if (raw is String) {
        event = jsonDecode(raw) as Map<String, dynamic>;
      } else if (raw is Map<String, dynamic>) {
        event = raw;
      }
    } catch (_) {
      return;
    }

    if (event == null) return;

    final type = event['type']?.toString() ?? '';
    final payload = (event['payload'] is Map<String, dynamic>)
        ? event['payload'] as Map<String, dynamic>
        : ((event['payload'] is Map)
            ? Map<String, dynamic>.from(event['payload'] as Map)
            : <String, dynamic>{});

    switch (type) {
      case 'connection.ready':
        _isConnected = true;
        _connectionStatusController.add(ConnectionStatus.connected);
        break;
      case 'conversation.updated':
        await _emitConversationUpdate(payload);
        break;
      case 'message.new':
        _emitMessageEvent(MessageEventType.newMessage, payload);
        break;
      case 'message.updated':
        _emitMessageEvent(MessageEventType.edited, payload);
        break;
      case 'message.deleted':
        _messageController.add(MessageEvent(
          type: MessageEventType.deleted,
          messageId: payload['messageId']?.toString(),
          conversationId: payload['conversationId']?.toString() ?? '',
        ));
        break;
      case 'message.status':
        _messageController.add(MessageEvent(
          type: MessageEventType.statusUpdated,
          messageId: payload['messageId']?.toString(),
          conversationId: payload['conversationId']?.toString() ?? '',
          status: payload['status']?.toString(),
          deliveredAt: payload['deliveredAt'] != null
              ? DateTime.tryParse(payload['deliveredAt'].toString())
              : null,
          readAt: payload['readAt'] != null
              ? DateTime.tryParse(payload['readAt'].toString())
              : null,
        ));
        break;
      case 'message.reaction_added':
        _messageController.add(MessageEvent(
          type: MessageEventType.reactionAdded,
          messageId: payload['messageId']?.toString(),
          conversationId: payload['conversationId']?.toString() ?? '',
          reaction: _parseReaction(payload['reaction']),
        ));
        break;
      case 'message.reaction_removed':
        _messageController.add(MessageEvent(
          type: MessageEventType.reactionRemoved,
          messageId: payload['messageId']?.toString(),
          conversationId: payload['conversationId']?.toString() ?? '',
          reaction: _parseReaction(payload['reaction']),
        ));
        break;
      case 'typing.updated':
        _typingController.add(TypingEvent(
          conversationId: payload['conversationId']?.toString() ?? '',
          typingUserIds:
              (payload['typingUserIds'] as List? ?? const <dynamic>[])
                  .map((e) => e.toString())
                  .toList(),
        ));
        break;
      case 'presence.updated':
        _presenceController.add(PresenceEvent(
          userId: payload['userId']?.toString() ?? '',
          status: payload['status']?.toString() ?? 'offline',
          lastSeen: payload['lastSeen'] != null
              ? DateTime.tryParse(payload['lastSeen'].toString())
              : null,
        ));
        break;
    }
  }

  void _emitMessageEvent(
    MessageEventType type,
    Map<String, dynamic> payload,
  ) {
    final messageJson = payload['message'];
    if (messageJson is! Map) return;

    final message =
        MessageModel.fromJson(Map<String, dynamic>.from(messageJson));
    _messageController.add(MessageEvent(
      type: type,
      messageId: message.id,
      conversationId:
          payload['conversationId']?.toString() ?? message.conversationId,
      message: message,
    ));
  }

  Future<void> _emitConversationUpdate(Map<String, dynamic> payload) async {
    final conversationId = payload['conversationId']?.toString();
    if (conversationId == null || conversationId.isEmpty) return;
    if (_chatRemoteDataSource == null) return;

    try {
      final conversation =
          await _chatRemoteDataSource!.getConversationById(conversationId);
      _conversationController.add(conversation);
    } catch (e) {
      debugPrint('emitConversationUpdate error: $e');
    }
  }

  MessageReaction? _parseReaction(dynamic raw) {
    if (raw is Map) {
      return MessageReactionModel.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  void _handleError(dynamic error) {
    _errorController.add(WebSocketError(
      type: ErrorType.connectionError,
      message: error.toString(),
    ));
    _handleDisconnected();
  }

  void _handleDisconnected() {
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    _connectionStatusController.add(ConnectionStatus.disconnected);

    if (_disposed) return;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      connect();
    });
  }
}

class MessageEvent {
  final MessageEventType type;
  final Message? message;
  final String? messageId;
  final String conversationId;
  final String? status;
  final MessageReaction? reaction;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  MessageEvent({
    required this.type,
    this.message,
    this.messageId,
    required this.conversationId,
    this.status,
    this.reaction,
    this.deliveredAt,
    this.readAt,
  });
}

class TypingEvent {
  final String conversationId;
  final List<String> typingUserIds;

  TypingEvent({
    required this.conversationId,
    required this.typingUserIds,
  });
}

class ConversationEventWS {
  final Conversation? conversation;

  ConversationEventWS({this.conversation});
}

class PresenceEvent {
  final String userId;
  final String status;
  final DateTime? lastSeen;

  PresenceEvent({
    required this.userId,
    required this.status,
    this.lastSeen,
  });
}

class WebSocketError {
  final ErrorType type;
  final String message;

  WebSocketError({
    required this.type,
    required this.message,
  });
}

enum ConnectionStatus {
  connected,
  disconnected,
  error,
}

enum ErrorType {
  connectionError,
  messageError,
}

enum MessageEventType {
  newMessage,
  edited,
  deleted,
  statusUpdated,
  reactionAdded,
  reactionRemoved,
}
