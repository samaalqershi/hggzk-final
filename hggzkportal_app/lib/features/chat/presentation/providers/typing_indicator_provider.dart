import 'dart:async';
import 'package:flutter/foundation.dart';

/// Tracks who is typing in each conversation and auto-clears stale typing
/// indicators after a short timeout.
/// يتتبع من يكتب داخل كل محادثة ويزيل المؤشرات القديمة تلقائيًا بعد مهلة
/// قصيرة.
class TypingIndicatorProvider extends ChangeNotifier {
  /// Typing users keyed by conversation id.
  /// المستخدمون الذين يكتبون الآن، مفهرسون بمعرّف المحادثة.
  final Map<String, Set<String>> _typingUsers = {};

  /// Per-user timers that expire typing indicators when the user stops.
  /// مؤقتات لكل مستخدم تنهي مؤشر الكتابة عندما يتوقف.
  final Map<String, Timer> _typingTimers = {};
  static const Duration _typingTimeout = Duration(seconds: 5);

  /// Exposes the current typing map without allowing mutation from outside.
  /// يعرض خريطة الكتابة الحالية من دون السماح بتعديلها من الخارج.
  Map<String, Set<String>> get typingUsers => Map.unmodifiable(_typingUsers);

  /// Returns the list of typing users for a single conversation thread.
  /// يعيد قائمة المستخدمين الذين يكتبون داخل محادثة واحدة.
  List<String> getTypingUsersForConversation(String conversationId) {
    return _typingUsers[conversationId]?.toList() ?? [];
  }

  /// Checks whether a specific user is actively typing in a conversation.
  /// يتحقق مما إذا كان مستخدم محدد يكتب حاليًا داخل محادثة.
  bool isUserTyping(String conversationId, String userId) {
    return _typingUsers[conversationId]?.contains(userId) ?? false;
  }

  /// Starts or stops typing tracking for the given user and conversation.
  /// يبدأ أو يوقف تتبع الكتابة للمستخدم والمحادثة المحددين.
  void setUserTyping({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) {
    if (isTyping) {
      _addTypingUser(conversationId, userId);
      _resetTypingTimer(conversationId, userId);
    } else {
      _removeTypingUser(conversationId, userId);
      _cancelTypingTimer(conversationId, userId);
    }
  }

  /// Adds the user to the typing set if they are not already present.
  /// يضيف المستخدم إلى مجموعة الكتابة إذا لم يكن موجودًا أصلًا.
  void _addTypingUser(String conversationId, String userId) {
    _typingUsers.putIfAbsent(conversationId, () => {});
    if (_typingUsers[conversationId]!.add(userId)) {
      notifyListeners();
    }
  }

  /// Removes the user from the typing set and drops empty conversations.
  /// يزيل المستخدم من مجموعة الكتابة ويحذف المحادثات الفارغة.
  void _removeTypingUser(String conversationId, String userId) {
    if (_typingUsers[conversationId]?.remove(userId) ?? false) {
      if (_typingUsers[conversationId]!.isEmpty) {
        _typingUsers.remove(conversationId);
      }
      notifyListeners();
    }
  }

  /// Resets the inactivity timer so the typing marker can expire naturally.
  /// يعيد ضبط مؤقت الخمول حتى ينتهي مؤشر الكتابة تلقائيًا.
  void _resetTypingTimer(String conversationId, String userId) {
    final key = '$conversationId:$userId';
    _cancelTypingTimer(conversationId, userId);

    _typingTimers[key] = Timer(_typingTimeout, () {
      _removeTypingUser(conversationId, userId);
      _typingTimers.remove(key);
    });
  }

  /// Cancels the expiration timer for one typing user.
  /// يلغي مؤقت انتهاء صلاحية مستخدم يكتب.
  void _cancelTypingTimer(String conversationId, String userId) {
    final key = '$conversationId:$userId';
    _typingTimers[key]?.cancel();
    _typingTimers.remove(key);
  }

  /// Clears every typing marker that belongs to one conversation.
  /// يمسح كل مؤشرات الكتابة التابعة لمحادثة واحدة.
  void clearTypingUsersForConversation(String conversationId) {
    if (_typingUsers.remove(conversationId) != null) {
      // Cancel all timers for this conversation
      final keysToRemove = <String>[];
      _typingTimers.forEach((key, timer) {
        if (key.startsWith('$conversationId:')) {
          timer.cancel();
          keysToRemove.add(key);
        }
      });
      keysToRemove.forEach(_typingTimers.remove);
      notifyListeners();
    }
  }

  /// Clears every typing marker and timer across all conversations.
  /// يمسح كل مؤشرات الكتابة والموقتات في جميع المحادثات.
  void clearAllTypingUsers() {
    _typingUsers.clear();
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingTimers.clear();
    notifyListeners();
  }

  /// Releases timers and cached typing state before disposal.
  /// يحرر المؤقتات وحالة الكتابة المخزنة قبل التخلص من الكائن.
  @override
  void dispose() {
    clearAllTypingUsers();
    super.dispose();
  }
}
