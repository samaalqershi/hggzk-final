/// أدوات مساعدة لتحويل الفرق الزمني إلى نصوص عربية قصيرة ومفهومة.
/// Helpers that turn time differences into concise Arabic human-readable labels.
class TimeAgoHelper {
  /// يعرض وصفًا عربيًا واضحًا مثل "منذ 3 ساعات" أو "منذ أسبوع".
  /// Returns an Arabic phrase such as "3 hours ago" or "1 week ago".
  static String getTimeAgoArabic(DateTime? dateTime) {
    if (dateTime == null) {
      return 'غير معروف';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 2) {
      return 'منذ دقيقة';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقائق';
    } else if (difference.inHours < 2) {
      return 'منذ ساعة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعات';
    } else if (difference.inDays < 2) {
      return 'منذ يوم';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'منذ أسبوع' : 'منذ $weeks أسابيع';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'منذ شهر' : 'منذ $months أشهر';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'منذ سنة' : 'منذ $years سنوات';
    }
  }

  /// يعرض نسخة أقصر جدًا مناسبة للمساحات الصغيرة مثل الشارات.
  /// Returns a shorter variant suitable for compact UI surfaces.
  static String getTimeAgoShortArabic(DateTime? dateTime) {
    if (dateTime == null) {
      return 'غير معروف';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}د';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}س';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}ي';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}ش';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}سنة';
    }
  }

  /// يحدد إن كان المستخدم نشطًا الآن عبر نافذة زمنية صغيرة.
  /// Treats the user as online when the last activity is within five minutes.
  static bool isUserOnline(DateTime? lastSeen) {
    if (lastSeen == null) return false;
    final difference = DateTime.now().difference(lastSeen);
    return difference.inMinutes < 5;
  }

  /// يختار نص الحالة المناسب بين متصل الآن أو آخر ظهور.
  /// Produces the appropriate online-status text for the user.
  static String getOnlineStatusArabic(DateTime? lastSeen) {
    if (isUserOnline(lastSeen)) {
      return 'متصل الآن';
    } else if (lastSeen == null) {
      return 'غير معروف';
    } else {
      return getTimeAgoArabic(lastSeen);
    }
  }

  /// يصنف النشاط إلى حالة تشغيلية تستفيد منها المؤشرات البصرية.
  /// Classifies activity into a status the UI can map to presence indicators.
  static ActivityStatus getActivityStatus(DateTime? lastSeen) {
    if (lastSeen == null) return ActivityStatus.offline;

    final difference = DateTime.now().difference(lastSeen);

    if (difference.inMinutes < 5) {
      return ActivityStatus.online;
    } else if (difference.inMinutes < 30) {
      return ActivityStatus.recentlyActive;
    } else if (difference.inHours < 24) {
      return ActivityStatus.away;
    } else {
      return ActivityStatus.offline;
    }
  }
}

/// حالات الحضور التي تعتمد عليها واجهة الدردشة عند عرض النشاط.
/// Presence states used by chat UI when rendering user activity.
enum ActivityStatus {
  online,
  recentlyActive,
  away,
  offline,
}
