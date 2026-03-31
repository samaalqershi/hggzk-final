import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_settings_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/message.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Local persistence contract for cached conversations, messages, settings,
/// and queued outbound messages.
/// عقدة التخزين المحلي للمحادثات والرسائل والإعدادات والرسائل المعلقة.
abstract class ChatLocalDataSource {
  // Conversations
  /// يخزن أحدث قائمة محادثات لعرض الصندوق الوارد دون اتصال.
  Future<void> cacheConversations(List<ConversationModel> conversations);

  /// Reads the cached conversation list in the same order it was stored.
  /// يقرأ قائمة المحادثات المخزنة بنفس الترتيب الذي حُفظت به.
  Future<List<ConversationModel>?> getCachedConversations();

  /// Reads one cached conversation by its identifier.
  /// يقرأ محادثة مخزنة واحدة بواسطة معرّفها.
  Future<ConversationModel?> getCachedConversationById(String conversationId);

  /// Removes one conversation from the local cache.
  /// يزيل محادثة واحدة من الكاش المحلي.
  Future<void> deleteConversationCache(String conversationId);

  // Messages
  /// يخزن أحدث صفحة رسائل لمحادثة.
  Future<void> cacheMessages(
      String conversationId, List<MessageModel> messages);

  /// Reads the cached message list for a conversation.
  /// يقرأ قائمة الرسائل المخزنة لمحادثة.
  Future<List<MessageModel>?> getCachedMessages(String conversationId);

  /// Appends one message to the cached conversation timeline.
  /// يضيف رسالة واحدة إلى الخط الزمني المخزن للمحادثة.
  Future<void> addMessageToCache(String conversationId, MessageModel message);

  /// Stores an outbound message until the app can send it.
  /// يخزن رسالة صادرة حتى يتمكن التطبيق من إرسالها.
  Future<void> queueMessage({
    required String conversationId,
    required String messageType,
    String? content,
    Location? location,
    String? replyToMessageId,
    List<String>? attachmentIds,
  });

  /// Returns queued outbound messages waiting for retry.
  /// يعيد الرسائل الصادرة المعلقة بانتظار إعادة المحاولة.
  Future<List<Map<String, dynamic>>> getQueuedMessages();

  /// Deletes one queued outbound message after it is sent or cancelled.
  /// يحذف رسالة صادرة معلقة بعد إرسالها أو إلغائها.
  Future<void> removeQueuedMessage(String messageId);

  // Settings
  /// يخزن أحدث لقطة لتفضيلات الدردشة.
  Future<void> cacheSettings(ChatSettingsModel settings);

  /// Reads the locally cached chat preferences.
  /// يقرأ تفضيلات الدردشة المخزنة محليًا.
  Future<ChatSettingsModel?> getCachedSettings();

  // Clear
  /// Clears every cached chat artifact.
  /// يمسح كل عناصر كاش الدردشة.
  Future<void> clearAllCache();

  /// Clears only conversation cache entries.
  /// يمسح فقط عناصر كاش المحادثات.
  Future<void> clearConversationsCache();

  /// Clears only cached messages.
  /// يمسح فقط الرسائل المخزنة.
  Future<void> clearMessagesCache();
}

/// Hive-backed implementation of the chat local data source.
/// تنفيذ معتمد على Hive لمصدر بيانات الدردشة المحلي.
class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  /// Hive box name used for conversation cache entries.
  /// اسم صندوق Hive المستخدم لعناصر كاش المحادثات.
  static const String _conversationsBoxName = 'chat_conversations';

  /// Hive box name used for cached messages.
  /// اسم صندوق Hive المستخدم للرسائل المخزنة.
  static const String _messagesBoxName = 'chat_messages';

  /// Hive box name used for stored chat settings.
  /// اسم صندوق Hive المستخدم لإعدادات الدردشة المخزنة.
  static const String _settingsBoxName = 'chat_settings';

  /// Hive box name used for outbound message retries.
  /// اسم صندوق Hive المستخدم لرسائل الإرسال المؤجل.
  static const String _queuedMessagesBoxName = 'queued_messages';

  /// العربية: يخزن القيمة `conversationsBox`.
  late Box<String> _conversationsBox;

  /// العربية: يخزن القيمة `messagesBox`.
  late Box<String> _messagesBox;

  /// العربية: يخزن القيمة `settingsBox`.
  late Box<String> _settingsBox;

  /// العربية: يخزن القيمة `queuedMessagesBox`.
  late Box<String> _queuedMessagesBox;

  /// العربية: يحدد ما إذا كانت القيمة `isInitialized` مفعلة.
  bool _isInitialized = false;

  /// العربية: يخزن القيمة `initFuture`.
  Future<void>? _initFuture;

  /// Starts box initialization as soon as the data source is constructed.
  /// يبدأ تهيئة الصناديق فور إنشاء مصدر البيانات.
  ChatLocalDataSourceImpl() {
    _initFuture = _initializeBoxes();
  }

  /// Opens the Hive boxes used by the chat cache.
  /// يفتح صناديق Hive المستخدمة في كاش الدردشة.
  Future<void> _initializeBoxes() async {
    try {
      if (!Hive.isBoxOpen(_conversationsBoxName)) {
        _conversationsBox = await Hive.openBox<String>(_conversationsBoxName);
      } else {
        _conversationsBox = Hive.box<String>(_conversationsBoxName);
      }
      if (!Hive.isBoxOpen(_messagesBoxName)) {
        _messagesBox = await Hive.openBox<String>(_messagesBoxName);
      } else {
        _messagesBox = Hive.box<String>(_messagesBoxName);
      }
      if (!Hive.isBoxOpen(_settingsBoxName)) {
        _settingsBox = await Hive.openBox<String>(_settingsBoxName);
      } else {
        _settingsBox = Hive.box<String>(_settingsBoxName);
      }
      if (!Hive.isBoxOpen(_queuedMessagesBoxName)) {
        _queuedMessagesBox = await Hive.openBox<String>(_queuedMessagesBoxName);
      } else {
        _queuedMessagesBox = Hive.box<String>(_queuedMessagesBoxName);
      }
      _isInitialized = true;
    } catch (e) {
      throw CacheException(
        AppLocalizations.translateSync('chat.errors.cache'),
      );
    }
  }

  /// Waits for the Hive boxes to become available before any cache access.
  /// ينتظر حتى تصبح صناديق Hive متاحة قبل أي وصول للكاش.
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    if (_initFuture != null) {
      await _initFuture;
      return;
    }
    _initFuture = _initializeBoxes();
    await _initFuture;
  }

  /// العربية: يعالج `cacheConversations`.
  @override
  Future<void> cacheConversations(List<ConversationModel> conversations) async {
    await _ensureInitialized();
    try {
      final conversationsMap = <String, String>{};
      for (final conversation in conversations) {
        conversationsMap[conversation.id] = json.encode(conversation.toJson());
      }
      await _conversationsBox.putAll(conversationsMap);

      // Also cache the list order
      await _conversationsBox.put(
        'conversations_list',
        json.encode(conversations.map((c) => c.id).toList()),
      );
    } catch (e) {
      throw CacheException(
        AppLocalizations.translateSync('chat.errors.cache'),
      );
    }
  }

  /// العربية: يعيد cached conversations.
  @override
  Future<List<ConversationModel>?> getCachedConversations() async {
    await _ensureInitialized();
    try {
      final listJson = _conversationsBox.get('conversations_list');
      if (listJson == null) return null;

      final List<String> conversationIds =
          List<String>.from(json.decode(listJson));
      final conversations = <ConversationModel>[];

      for (final id in conversationIds) {
        final conversationJson = _conversationsBox.get(id);
        if (conversationJson != null) {
          conversations.add(
            ConversationModel.fromJson(json.decode(conversationJson)),
          );
        }
      }

      return conversations.isNotEmpty ? conversations : null;
    } catch (e) {
      throw CacheException(
        AppLocalizations.translateSync('chat.errors.cache'),
      );
    }
  }

  /// العربية: يعيد cached conversation by id.
  @override
  Future<ConversationModel?> getCachedConversationById(
      String conversationId) async {
    await _ensureInitialized();
    try {
      final conversationJson = _conversationsBox.get(conversationId);
      if (conversationJson == null) return null;

      return ConversationModel.fromJson(json.decode(conversationJson));
    } catch (e) {
      throw CacheException(
        AppLocalizations.translateSync('chat.errors.cache'),
      );
    }
  }

  /// العربية: يحذف conversation cache.
  @override
  Future<void> deleteConversationCache(String conversationId) async {
    await _ensureInitialized();
    try {
      await _conversationsBox.delete(conversationId);

      // Update the list
      final listJson = _conversationsBox.get('conversations_list');
      if (listJson != null) {
        final List<String> conversationIds =
            List<String>.from(json.decode(listJson));
        conversationIds.remove(conversationId);
        await _conversationsBox.put(
          'conversations_list',
          json.encode(conversationIds),
        );
      }

      // Delete messages
      await _messagesBox.delete('messages_$conversationId');
    } catch (e) {
      throw CacheException(
        AppLocalizations.translateSync('chat.errors.cache'),
      );
    }
  }

  /// العربية: يعالج `cacheMessages`.
  @override
  Future<void> cacheMessages(
      String conversationId, List<MessageModel> messages) async {
    await _ensureInitialized();
    try {
      final messagesJson = messages.map((m) => m.toJson()).toList();
      await _messagesBox.put(
        'messages_$conversationId',
        json.encode(messagesJson),
      );
    } catch (e) {
      throw CacheException(
        AppLocalizations.translateSync('chat.errors.cache'),
      );
    }
  }

  /// العربية: يعيد cached messages.
  @override
  Future<List<MessageModel>?> getCachedMessages(String conversationId) async {
    await _ensureInitialized();
    try {
      final messagesJson = _messagesBox.get('messages_$conversationId');
      if (messagesJson == null) return null;

      final List<dynamic> messagesList = json.decode(messagesJson);
      return messagesList.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      throw CacheException(
        AppLocalizations.translateSync('chat.errors.cache'),
      );
    }
  }

  /// العربية: يعالج `addMessageToCache`.
  @override
  Future<void> addMessageToCache(
      String conversationId, MessageModel message) async {
    await _ensureInitialized();
    try {
      final messages = await getCachedMessages(conversationId) ?? [];
      messages.insert(0, message);

      // Keep only last 100 messages in cache
      if (messages.length > 100) {
        messages.removeRange(100, messages.length);
      }

      await cacheMessages(conversationId, messages);
    } catch (e) {
      throw CacheException(
        AppLocalizations.translateSync('chat.errors.cache'),
      );
    }
  }

  /// العربية: يعالج `queueMessage`.
  @override
  Future<void> queueMessage({
    required String conversationId,
    required String messageType,
    String? content,
    Location? location,
    String? replyToMessageId,
    List<String>? attachmentIds,
  }) async {
    await _ensureInitialized();
    try {
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      final queuedMessage = {
        'id': messageId,
        'conversationId': conversationId,
        'messageType': messageType,
        if (content != null) 'content': content,
        if (location != null)
          'location': {
            'latitude': location.latitude,
            'longitude': location.longitude,
            if (location.address != null) 'address': location.address,
          },
        if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
        if (attachmentIds != null) 'attachmentIds': attachmentIds,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _queuedMessagesBox.put(messageId, json.encode(queuedMessage));
    } catch (e) {
      throw CacheException(
        AppLocalizations.translateSync('chat.errors.cache'),
      );
    }
  }

  /// العربية: يعيد queued messages.
  @override
  Future<List<Map<String, dynamic>>> getQueuedMessages() async {
    await _ensureInitialized();
    try {
      final messages = <Map<String, dynamic>>[];
      for (final key in _queuedMessagesBox.keys) {
        final messageJson = _queuedMessagesBox.get(key);
        if (messageJson != null) {
          messages.add(json.decode(messageJson));
        }
      }
      return messages;
    } catch (e) {
      throw CacheException(
        AppLocalizations.translateSync('chat.errors.cache'),
      );
    }
  }

  /// العربية: يزيل queued message.
  @override
  Future<void> removeQueuedMessage(String messageId) async {
    await _ensureInitialized();
    try {
      await _queuedMessagesBox.delete(messageId);
    } catch (e) {
      throw CacheException(
        AppLocalizations.translateSync('chat.errors.cache'),
      );
    }
  }

  /// العربية: يعالج `cacheSettings`.
  @override
  Future<void> cacheSettings(ChatSettingsModel settings) async {
    await _ensureInitialized();
    try {
      await _settingsBox.put('settings', json.encode(settings.toJson()));
    } catch (e) {
      throw CacheException(
        AppLocalizations.translateSync('chat.errors.cache'),
      );
    }
  }

  /// العربية: يعيد cached settings.
  @override
  Future<ChatSettingsModel?> getCachedSettings() async {
    await _ensureInitialized();
    try {
      final settingsJson = _settingsBox.get('settings');
      if (settingsJson == null) return null;

      return ChatSettingsModel.fromJson(json.decode(settingsJson));
    } catch (e) {
      throw CacheException(
        AppLocalizations.translateSync('chat.errors.cache'),
      );
    }
  }

  /// العربية: يعالج `clearAllCache`.
  @override
  Future<void> clearAllCache() async {
    await _ensureInitialized();
    try {
      await Future.wait([
        _conversationsBox.clear(),
        _messagesBox.clear(),
        _settingsBox.clear(),
        _queuedMessagesBox.clear(),
      ]);
    } catch (e) {
      throw CacheException(
        AppLocalizations.translateSync('chat.errors.cache'),
      );
    }
  }

  /// العربية: يعالج `clearConversationsCache`.
  @override
  Future<void> clearConversationsCache() async {
    await _ensureInitialized();
    try {
      await _conversationsBox.clear();
    } catch (e) {
      throw CacheException(
        AppLocalizations.translateSync('chat.errors.cache'),
      );
    }
  }

  /// العربية: يعالج `clearMessagesCache`.
  @override
  Future<void> clearMessagesCache() async {
    await _ensureInitialized();
    try {
      await _messagesBox.clear();
    } catch (e) {
      throw CacheException(
        AppLocalizations.translateSync('chat.errors.cache'),
      );
    }
  }
}
