import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hggzkportal/features/chat/data/models/chat_settings_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/message.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// يعرّف الكلاس المجرد `ChatLocalDataSource`.
/// Describes the abstract `ChatLocalDataSource` class.
abstract class ChatLocalDataSource {
  // Conversations
  /// ينفذ العملية `cacheConversations`.
  /// Runs the `cacheConversations` operation.
  Future<void> cacheConversations(List<ConversationModel> conversations);

  /// ينفذ العملية `getCachedConversations`.
  /// Runs the `getCachedConversations` operation.
  Future<List<ConversationModel>?> getCachedConversations();

  /// ينفذ العملية `getCachedConversationById`.
  /// Runs the `getCachedConversationById` operation.
  Future<ConversationModel?> getCachedConversationById(String conversationId);

  /// ينفذ العملية `deleteConversationCache`.
  /// Runs the `deleteConversationCache` operation.
  Future<void> deleteConversationCache(String conversationId);

  // Messages
  /// ينفذ العملية `cacheMessages`.
  /// Runs the `cacheMessages` operation.
  Future<void> cacheMessages(
      String conversationId, List<MessageModel> messages);

  /// ينفذ العملية `getCachedMessages`.
  /// Runs the `getCachedMessages` operation.
  Future<List<MessageModel>?> getCachedMessages(String conversationId);

  /// ينفذ العملية `addMessageToCache`.
  /// Runs the `addMessageToCache` operation.
  Future<void> addMessageToCache(String conversationId, MessageModel message);

  /// ينفذ العملية `queueMessage`.
  /// Runs the `queueMessage` operation.
  Future<void> queueMessage({
    required String conversationId,
    required String messageType,
    String? content,
    Location? location,
    String? replyToMessageId,
    List<String>? attachmentIds,
  });

  /// ينفذ العملية `getQueuedMessages`.
  /// Runs the `getQueuedMessages` operation.
  Future<List<Map<String, dynamic>>> getQueuedMessages();

  /// ينفذ العملية `removeQueuedMessage`.
  /// Runs the `removeQueuedMessage` operation.
  Future<void> removeQueuedMessage(String messageId);

  // Settings
  /// ينفذ العملية `cacheSettings`.
  /// Runs the `cacheSettings` operation.
  Future<void> cacheSettings(ChatSettingsModel settings);

  /// ينفذ العملية `getCachedSettings`.
  /// Runs the `getCachedSettings` operation.
  Future<ChatSettingsModel?> getCachedSettings();

  // Thumbnails (local preview cache for media)
  /// ينفذ العملية `saveThumbnail`.
  /// Runs the `saveThumbnail` operation.
  Future<void> saveThumbnail(String key, String localPath);

  /// ينفذ العملية `getThumbnail`.
  /// Runs the `getThumbnail` operation.
  Future<String?> getThumbnail(String key);

  /// ينفذ العملية `deleteThumbnail`.
  /// Runs the `deleteThumbnail` operation.
  Future<void> deleteThumbnail(String key);

  /// ينفذ العملية `pruneThumbnails`.
  /// Runs the `pruneThumbnails` operation.
  Future<void> pruneThumbnails({int maxEntries = 300});

  // Clear
  /// ينفذ العملية `clearAllCache`.
  /// Runs the `clearAllCache` operation.
  Future<void> clearAllCache();

  /// ينفذ العملية `clearConversationsCache`.
  /// Runs the `clearConversationsCache` operation.
  Future<void> clearConversationsCache();

  /// ينفذ العملية `clearMessagesCache`.
  /// Runs the `clearMessagesCache` operation.
  Future<void> clearMessagesCache();

  /// ينفذ العملية `clearThumbnails`.
  /// Runs the `clearThumbnails` operation.
  Future<void> clearThumbnails();
}

/// يعرّف الكلاس `ChatLocalDataSourceImpl`.
/// Describes the `ChatLocalDataSourceImpl` class.
class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  /// Holds the `conversationsBoxName` value.
  /// العربية: يخزن القيمة `conversationsBoxName`.
  static const String _conversationsBoxName = 'chat_conversations';

  /// يخزن العضو `_messagesBoxName`.
  /// Holds the `_messagesBoxName` member.
  static const String _messagesBoxName = 'chat_messages';

  /// يخزن العضو `_settingsBoxName`.
  /// Holds the `_settingsBoxName` member.
  static const String _settingsBoxName = 'chat_settings';

  /// يخزن العضو `_queuedMessagesBoxName`.
  /// Holds the `_queuedMessagesBoxName` member.
  static const String _queuedMessagesBoxName = 'queued_messages';

  /// يخزن العضو `_thumbnailsBoxName`.
  /// Holds the `_thumbnailsBoxName` member.
  static const String _thumbnailsBoxName = 'chat_thumbnails';

  /// يخزن العضو `_conversationsBox`.
  /// Holds the `_conversationsBox` member.
  late Box<String> _conversationsBox;

  /// يخزن العضو `_messagesBox`.
  /// Holds the `_messagesBox` member.
  late Box<String> _messagesBox;

  /// يخزن العضو `_settingsBox`.
  /// Holds the `_settingsBox` member.
  late Box<String> _settingsBox;

  /// يخزن العضو `_queuedMessagesBox`.
  /// Holds the `_queuedMessagesBox` member.
  late Box<String> _queuedMessagesBox;

  /// يخزن العضو `_thumbnailsBox`.
  /// Holds the `_thumbnailsBox` member.
  late Box<String> _thumbnailsBox;

  /// يخزن العضو `_isInitialized`.
  /// Holds the `_isInitialized` member.
  bool _isInitialized = false;

  /// يخزن العضو `_initFuture`.
  /// Holds the `_initFuture` member.
  Future<void>? _initFuture;

  /// ينشئ مثيلاً من `ChatLocalDataSourceImpl`.
  /// Builds an instance of `ChatLocalDataSourceImpl`.
  ChatLocalDataSourceImpl() {
    _initFuture = _initializeBoxes();
  }

  /// ينفذ العملية `_initializeBoxes`.
  /// Runs the `_initializeBoxes` operation.
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
      if (!Hive.isBoxOpen(_thumbnailsBoxName)) {
        _thumbnailsBox = await Hive.openBox<String>(_thumbnailsBoxName);
      } else {
        _thumbnailsBox = Hive.box<String>(_thumbnailsBoxName);
      }
      _isInitialized = true;
    } catch (e) {
      throw const CacheException('فشل في تهيئة التخزين المحلي');
    }
  }

  /// ينفذ العملية `_ensureInitialized`.
  /// Runs the `_ensureInitialized` operation.
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    if (_initFuture != null) {
      await _initFuture;
      return;
    }
    _initFuture = _initializeBoxes();
    await _initFuture;
  }

  /// ينفذ العملية `cacheConversations`.
  /// Runs the `cacheConversations` operation.
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
      throw const CacheException('فشل في حفظ المحادثات');
    }
  }

  /// ينفذ العملية `getCachedConversations`.
  /// Runs the `getCachedConversations` operation.
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
      throw const CacheException('فشل في قراءة المحادثات المحفوظة');
    }
  }

  /// ينفذ العملية `getCachedConversationById`.
  /// Runs the `getCachedConversationById` operation.
  @override
  Future<ConversationModel?> getCachedConversationById(
      String conversationId) async {
    await _ensureInitialized();
    try {
      final conversationJson = _conversationsBox.get(conversationId);
      if (conversationJson == null) return null;

      return ConversationModel.fromJson(json.decode(conversationJson));
    } catch (e) {
      throw const CacheException('فشل في قراءة المحادثة');
    }
  }

  /// ينفذ العملية `deleteConversationCache`.
  /// Runs the `deleteConversationCache` operation.
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
      throw const CacheException('فشل في حذف المحادثة');
    }
  }

  /// ينفذ العملية `cacheMessages`.
  /// Runs the `cacheMessages` operation.
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
      throw const CacheException('فشل في حفظ الرسائل');
    }
  }

  /// ينفذ العملية `getCachedMessages`.
  /// Runs the `getCachedMessages` operation.
  @override
  Future<List<MessageModel>?> getCachedMessages(String conversationId) async {
    await _ensureInitialized();
    try {
      final messagesJson = _messagesBox.get('messages_$conversationId');
      if (messagesJson == null) return null;

      final List<dynamic> messagesList = json.decode(messagesJson);
      return messagesList.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      throw const CacheException('فشل في قراءة الرسائل المحفوظة');
    }
  }

  /// ينفذ العملية `addMessageToCache`.
  /// Runs the `addMessageToCache` operation.
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
      throw const CacheException('فشل في إضافة الرسالة للذاكرة المؤقتة');
    }
  }

  /// ينفذ العملية `queueMessage`.
  /// Runs the `queueMessage` operation.
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
      throw const CacheException('فشل في إضافة الرسالة لقائمة الانتظار');
    }
  }

  /// ينفذ العملية `getQueuedMessages`.
  /// Runs the `getQueuedMessages` operation.
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
      throw const CacheException('فشل في قراءة الرسائل في قائمة الانتظار');
    }
  }

  /// ينفذ العملية `removeQueuedMessage`.
  /// Runs the `removeQueuedMessage` operation.
  @override
  Future<void> removeQueuedMessage(String messageId) async {
    await _ensureInitialized();
    try {
      await _queuedMessagesBox.delete(messageId);
    } catch (e) {
      throw const CacheException('فشل في حذف الرسالة من قائمة الانتظار');
    }
  }

  /// ينفذ العملية `cacheSettings`.
  /// Runs the `cacheSettings` operation.
  @override
  Future<void> cacheSettings(ChatSettingsModel settings) async {
    await _ensureInitialized();
    try {
      await _settingsBox.put('settings', json.encode(settings.toJson()));
    } catch (e) {
      throw const CacheException('فشل في حفظ الإعدادات');
    }
  }

  /// ينفذ العملية `getCachedSettings`.
  /// Runs the `getCachedSettings` operation.
  @override
  Future<ChatSettingsModel?> getCachedSettings() async {
    await _ensureInitialized();
    try {
      final settingsJson = _settingsBox.get('settings');
      if (settingsJson == null) return null;

      return ChatSettingsModel.fromJson(json.decode(settingsJson));
    } catch (e) {
      throw const CacheException('فشل في قراءة الإعدادات المحفوظة');
    }
  }

  /// ينفذ العملية `clearAllCache`.
  /// Runs the `clearAllCache` operation.
  @override
  Future<void> clearAllCache() async {
    await _ensureInitialized();
    try {
      await Future.wait([
        _conversationsBox.clear(),
        _messagesBox.clear(),
        _settingsBox.clear(),
        _queuedMessagesBox.clear(),
        _thumbnailsBox.clear(),
      ]);
    } catch (e) {
      throw const CacheException('فشل في مسح الذاكرة المؤقتة');
    }
  }

  /// ينفذ العملية `clearConversationsCache`.
  /// Runs the `clearConversationsCache` operation.
  @override
  Future<void> clearConversationsCache() async {
    await _ensureInitialized();
    try {
      await _conversationsBox.clear();
    } catch (e) {
      throw const CacheException('فشل في مسح المحادثات المحفوظة');
    }
  }

  /// ينفذ العملية `clearMessagesCache`.
  /// Runs the `clearMessagesCache` operation.
  @override
  Future<void> clearMessagesCache() async {
    await _ensureInitialized();
    try {
      await _messagesBox.clear();
    } catch (e) {
      throw const CacheException('فشل في مسح الرسائل المحفوظة');
    }
  }

  /// ينفذ العملية `saveThumbnail`.
  /// Runs the `saveThumbnail` operation.
  @override
  Future<void> saveThumbnail(String key, String localPath) async {
    await _ensureInitialized();
    try {
      if (key.trim().isEmpty || localPath.trim().isEmpty) return;
      await _thumbnailsBox.put(key, localPath);
    } catch (e) {
      throw const CacheException('فشل في حفظ الصورة المصغرة');
    }
  }

  /// ينفذ العملية `getThumbnail`.
  /// Runs the `getThumbnail` operation.
  @override
  Future<String?> getThumbnail(String key) async {
    await _ensureInitialized();
    try {
      return _thumbnailsBox.get(key);
    } catch (e) {
      throw const CacheException('فشل في قراءة الصورة المصغرة');
    }
  }

  /// ينفذ العملية `deleteThumbnail`.
  /// Runs the `deleteThumbnail` operation.
  @override
  Future<void> deleteThumbnail(String key) async {
    await _ensureInitialized();
    try {
      await _thumbnailsBox.delete(key);
    } catch (e) {
      throw const CacheException('فشل في حذف الصورة المصغرة');
    }
  }

  /// ينفذ العملية `clearThumbnails`.
  /// Runs the `clearThumbnails` operation.
  @override
  Future<void> clearThumbnails() async {
    await _ensureInitialized();
    try {
      await _thumbnailsBox.clear();
    } catch (e) {
      throw const CacheException('فشل في مسح صور المعاينة');
    }
  }

  /// ينفذ العملية `pruneThumbnails`.
  /// Runs the `pruneThumbnails` operation.
  @override
  Future<void> pruneThumbnails({int maxEntries = 300}) async {
    await _ensureInitialized();
    try {
      // Remove orphan entries (file missing on disk)
      final toDelete = <dynamic>[];
      for (final key in _thumbnailsBox.keys) {
        final path = _thumbnailsBox.get(key);
        if (path == null || path.trim().isEmpty) {
          toDelete.add(key);
          continue;
        }
        try {
          final f = File(path);
          if (!f.existsSync()) {
            toDelete.add(key);
          }
        } catch (_) {
          toDelete.add(key);
        }
      }
      if (toDelete.isNotEmpty) {
        await _thumbnailsBox.deleteAll(toDelete);
      }

      // Enforce max entries by last modified time on disk (best-effort)
      final entries = <MapEntry<dynamic, String>>[];
      for (final key in _thumbnailsBox.keys) {
        final val = _thumbnailsBox.get(key);
        if (val != null) entries.add(MapEntry(key, val));
      }
      if (entries.length <= maxEntries) return;

      // Sort by file last modified descending (keep newest)
      entries.sort((a, b) {
        DateTime ma;
        DateTime mb;
        try {
          ma = File(a.value).lastModifiedSync();
        } catch (_) {
          ma = DateTime.fromMillisecondsSinceEpoch(0);
        }
        try {
          mb = File(b.value).lastModifiedSync();
        } catch (_) {
          mb = DateTime.fromMillisecondsSinceEpoch(0);
        }
        return mb.compareTo(ma);
      });

      final toRemove = entries.skip(maxEntries).toList();
      for (final e in toRemove) {
        try {
          final f = File(e.value);
          if (f.existsSync()) {
            // Best-effort delete file
            // ignore: discarded_futures
            f.deleteSync();
          }
        } catch (_) {}
        await _thumbnailsBox.delete(e.key);
      }
    } catch (e) {
      // non-fatal: do not throw if pruning fails; keep cache as-is
    }
  }
}
