import 'dart:async';
import 'package:hggzkportal/features/chat/domain/repositories/chat_repository.dart';
import 'package:hggzkportal/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:hggzkportal/services/connectivity_service.dart';
import 'package:hggzkportal/services/websocket_service.dart';

/// Keeps queued chat messages moving whenever the connection returns and helps
/// keep chat caches tidy in the background.
/// يضمن تحريك رسائل الشات المؤجلة عند عودة الاتصال ويساعد على تنظيف الكاش
/// في الخلفية.
class ChatSyncManager {
  /// Repository used to send queued messages to the backend.
  /// المستودع المستخدم لإرسال الرسائل المؤجلة إلى الخادم.
  final ChatRepository repository;

  /// Local source that stores queued messages and chat media cache data.
  /// مصدر محلي يخزن الرسائل المؤجلة وكاش وسائط الشات.
  final ChatLocalDataSource local;

  /// Connectivity monitor used to detect when the app is back online.
  /// مراقب الاتصال المستخدم لاكتشاف عودة الشبكة.
  final ConnectivityService connectivity;

  /// WebSocket bridge used to emit local events after queued messages send.
  /// جسر WebSocket يطلق الأحداث المحلية بعد إرسال الرسائل المؤجلة.
  final ChatWebSocketService ws;

  /// Subscription to connectivity changes.
  /// اشتراك في تغييرات الاتصال.
  StreamSubscription<bool>? _connSub;

  /// Guards against double initialization.
  /// يمنع التهيئة المزدوجة.
  bool _initialized = false;

  /// Injects the chat repository, local cache, connectivity monitor, and
  /// WebSocket bridge that form the sync loop.
  /// يحقن المستودع والكاش المحلي ومراقب الاتصال وجسر WebSocket التي تشكل
  /// حلقة المزامنة.
  ChatSyncManager({
    required this.repository,
    required this.local,
    required this.connectivity,
    required this.ws,
  });

  /// Starts listening for connectivity recovery and flushes queued work once
  /// the app is online.
  /// يبدأ الاستماع لعودة الاتصال ثم يفرغ الأعمال المؤجلة عندما تصبح الشبكة
  /// متاحة.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _connSub = connectivity.connectionStatus.listen((connected) {
      if (connected) {
        // Flush queued messages when back online
        // Fire and forget
        // ignore: discarded_futures
        flushQueuedMessages();
        // Best-effort cache prune
        // ignore: discarded_futures
        local.pruneThumbnails(maxEntries: 300);
      }
    });

    if (connectivity.isConnected) {
      await flushQueuedMessages();
      await local.pruneThumbnails(maxEntries: 300);
    }
  }

  /// Sends any locally queued chat messages to the server and removes them from
  /// the offline queue once acknowledged.
  /// يرسل الرسائل المؤجلة محليًا إلى الخادم ثم يحذفها من الطابور بعد تأكيدها.
  Future<void> flushQueuedMessages() async {
    try {
      final queued = await local.getQueuedMessages();
      for (final m in queued) {
        final id = (m['id'] ?? '').toString();
        final conversationId = (m['conversationId'] ?? '').toString();
        final messageType = (m['messageType'] ?? '').toString();
        final String? content = m['content']?.toString();
        final String? replyTo = m['replyToMessageId']?.toString();
        final List<String>? attachmentIds =
            (m['attachmentIds'] as List?)?.map((e) => e.toString()).toList();

        final result = await repository.sendMessage(
          conversationId: conversationId,
          messageType: messageType,
          content: content,
          replyToMessageId: replyTo,
          location: null,
          attachmentIds: attachmentIds,
        );

        await result.fold(
          (_) async {},
          (msg) async {
            await local.removeQueuedMessage(id);
            ws.emitNewMessageById(
              conversationId: conversationId,
              messageId: msg.id,
            );
          },
        );
      }
      // Prune thumbnails after processing queue
      await local.pruneThumbnails(maxEntries: 300);
    } catch (_) {}
  }

  /// Cancels connectivity subscriptions when the manager is no longer needed.
  /// يلغي اشتراكات الاتصال عندما لا تعود الإدارة مطلوبة.
  void dispose() {
    _connSub?.cancel();
  }
}
