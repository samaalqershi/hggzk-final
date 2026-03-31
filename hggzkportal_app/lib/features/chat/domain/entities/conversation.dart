import 'package:equatable/equatable.dart';
import 'message.dart';

/// Immutable conversation thread that groups participants, the latest
/// message, and unread state.
/// سلسلة محادثة غير قابلة للتعديل تجمع المشاركين وآخر رسالة وحالة غير
/// المقروء.
class Conversation extends Equatable {
  /// Stable identifier for the conversation thread.
  /// المعرّف الثابت لسلسلة المحادثة.
  final String id;

  /// Backend classification such as `direct` or `group`.
  /// تصنيف الخادم مثل `direct` أو `group`.
  final String conversationType;

  /// Display title for the conversation when available.
  /// عنوان العرض للمحادثة عندما يكون متاحًا.
  final String? title;

  /// Optional description or group context.
  /// وصف اختياري أو سياق للمجموعة.
  final String? description;

  /// Conversation avatar or fallback identity image.
  /// صورة المحادثة أو صورة الهوية البديلة.
  final String? avatar;

  /// Time when the conversation was created.
  /// وقت إنشاء المحادثة.
  final DateTime createdAt;

  /// Time when the conversation was last active.
  /// وقت آخر نشاط للمحادثة.
  final DateTime updatedAt;

  /// Most recent message used for inbox previews.
  /// آخر رسالة تُستخدم في معاينات الصندوق الوارد.
  final Message? lastMessage;

  /// Number of unread messages in the thread.
  /// عدد الرسائل غير المقروءة داخل السلسلة.
  final int unreadCount;

  /// Whether the conversation has been moved to the archive.
  /// يحدد ما إذا كانت المحادثة نُقلت إلى الأرشيف.
  final bool isArchived;

  /// Whether notifications for this conversation are muted.
  /// يحدد ما إذا كانت إشعارات هذه المحادثة مكتومة.
  final bool isMuted;

  /// Optional property context attached to the thread.
  /// سياق العقار الاختياري المرتبط بالسلسلة.
  final String? propertyId;

  /// Participants involved in the conversation.
  /// المشاركون في المحادثة.
  final List<ChatUser> participants;

  /// Builds an immutable conversation snapshot for the inbox and detail view.
  /// ينشئ لقطة غير قابلة للتعديل للمحادثة في الصندوق الوارد وصفحة التفاصيل.
  const Conversation({
    required this.id,
    required this.conversationType,
    this.title,
    this.description,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.unreadCount = 0,
    this.isArchived = false,
    this.isMuted = false,
    this.propertyId,
    required this.participants,
  });

  /// Equality is based on the full conversation snapshot.
  /// تُبنى المساواة على اللقطة الكاملة للمحادثة.
  @override
  List<Object?> get props => [
        id,
        conversationType,
        title,
        description,
        avatar,
        createdAt,
        updatedAt,
        lastMessage,
        unreadCount,
        isArchived,
        isMuted,
        propertyId,
        participants,
      ];

  /// True when the thread contains exactly two participants.
  /// تكون صحيحة عندما تضم السلسلة مشاركين فقط.
  bool get isDirectChat => conversationType == 'direct';

  /// True when the thread is a group conversation.
  /// تكون صحيحة عندما تكون المحادثة جماعية.
  bool get isGroupChat => conversationType == 'group';

  /// True when the inbox should highlight the thread as unread.
  /// تكون صحيحة عندما يجب تمييز المحادثة بأنها غير مقروءة.
  bool get hasUnreadMessages => unreadCount > 0;

  /// Returns the other participant in a direct thread.
  /// يعيد الطرف الآخر في المحادثة الثنائية.
  ChatUser? getOtherParticipant(String currentUserId) {
    if (!isDirectChat || participants.length != 2) return null;
    return participants.firstWhere((p) => p.id != currentUserId);
  }
}

/// User profile data shown inside chat threads and participant pickers.
/// بيانات ملف المستخدم المعروضة داخل سلاسل الدردشة وقوائم الاختيار.
class ChatUser extends Equatable {
  /// Stable identifier for the user.
  /// المعرّف الثابت للمستخدم.
  final String id;

  /// Display name used across chat UI.
  /// اسم العرض المستخدم في واجهة الدردشة.
  final String name;

  /// Primary email address for the account.
  /// البريد الإلكتروني الأساسي للحساب.
  final String email;

  /// Optional phone number displayed in admin flows.
  /// رقم الهاتف الاختياري المعروض في مسارات الإدارة.
  final String? phone;

  /// Avatar or profile image shown in conversation lists.
  /// صورة الحساب التي تظهر في قوائم المحادثات.
  final String? profileImage;

  /// User category used for chat routing and permissions.
  /// فئة المستخدم المستخدمة في توجيه الدردشة والصلاحيات.
  final String userType;

  /// Current availability state such as online, offline, away, or busy.
  /// حالة التوفر الحالية مثل online أو offline أو away أو busy.
  final String status;

  /// Last known activity time when the user is not online.
  /// آخر وقت نشاط معروف عندما لا يكون المستخدم متصلًا.
  final DateTime? lastSeen;

  /// Optional property context used to limit or group chat participants.
  /// سياق العقار الاختياري المستخدم لتجميع أو تضييق المشاركين.
  final String? propertyId;

  /// Whether the user is currently connected.
  /// يحدد ما إذا كان المستخدم متصلًا الآن.
  final bool isOnline;

  /// Builds the user snapshot used in chat selection and presence displays.
  /// ينشئ لقطة المستخدم المستخدمة في الاختيار والحضور داخل الدردشة.
  const ChatUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    required this.userType,
    required this.status,
    this.lastSeen,
    this.propertyId,
    required this.isOnline,
  });

  /// Equality is based on the rendered user snapshot.
  /// تُبنى المساواة على لقطة المستخدم المعروضة.
  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        profileImage,
        userType,
        status,
        lastSeen,
        propertyId,
        isOnline,
      ];
}
