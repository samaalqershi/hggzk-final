import 'package:equatable/equatable.dart';

/// Describes one uploaded chat attachment together with the metadata needed
/// by the UI to present previews, sizes, and media-specific actions.
/// يصف مرفق دردشة واحدًا مع البيانات الوصفية التي تحتاجها الواجهة لعرض
/// المعاينات والأحجام والإجراءات الخاصة بالوسائط.
class Attachment extends Equatable {
  /// Stable identifier for the attachment record.
  /// المعرّف الثابت لسجل المرفق.
  final String id;

  /// Conversation that owns this attachment.
  /// المحادثة المالكة لهذا المرفق.
  final String conversationId;

  /// Original file name shown in previews and download prompts.
  /// اسم الملف الأصلي المعروض في المعاينات ومطالبات التنزيل.
  final String fileName;

  /// MIME type that tells the UI how to render the attachment.
  /// نوع MIME الذي يحدد كيفية عرض المرفق في الواجهة.
  final String contentType;

  /// File size in bytes.
  /// حجم الملف بالبايت.
  final int fileSize;

  /// Local or server-side path used to resolve the file.
  /// المسار المحلي أو على الخادم المستخدم للوصول إلى الملف.
  final String filePath;

  /// Public URL used when the attachment is displayed or downloaded.
  /// الرابط العام المستخدم عند عرض المرفق أو تنزيله.
  final String fileUrl;

  /// User id or identifier of the uploader.
  /// معرّف المستخدم أو الجهة التي رفعت الملف.
  final String uploadedBy;

  /// Timestamp describing when the attachment became available.
  /// الطابع الزمني الذي يوضح متى أصبح المرفق متاحًا.
  final DateTime createdAt;

  /// Optional thumbnail used for videos or previewable documents.
  /// صورة مصغرة اختيارية تستخدم للفيديو أو الملفات القابلة للمعاينة.
  final String? thumbnailUrl;

  /// Extra backend metadata preserved for feature-specific rendering.
  /// بيانات وصفية إضافية من الخادم تُحفظ لعرض مخصص حسب الميزة.
  final Map<String, dynamic>? metadata;

  /// Optional media duration in seconds for audio or video files.
  /// مدة الوسائط الاختيارية بالثواني لملفات الصوت أو الفيديو.
  final int? duration;

  /// Transient download progress used only by the client UI.
  /// تقدم تنزيل مؤقت يستخدمه تطبيق العميل فقط.
  final double? downloadProgress;

  /// Builds the domain attachment entity from normalized backend data.
  /// ينشئ كيان المرفق من بيانات الخادم بعد تطبيعها.
  const Attachment({
    required this.id,
    required this.conversationId,
    required this.fileName,
    required this.contentType,
    required this.fileSize,
    required this.filePath,
    required this.fileUrl,
    required this.uploadedBy,
    required this.createdAt,
    this.thumbnailUrl,
    this.metadata,
    this.duration,
    this.downloadProgress,
  });

  /// Equality is based on the attachment content and metadata snapshot.
  /// تُبنى المساواة على محتوى المرفق ولقطة البيانات الوصفية.
  @override
  List<Object?> get props => [
        id,
        conversationId,
        fileName,
        contentType,
        fileSize,
        filePath,
        fileUrl,
        uploadedBy,
        createdAt,
        thumbnailUrl,
        metadata,
        duration,
        downloadProgress,
      ];

  /// Returns the lowercase file extension for presentation decisions.
  /// يعيد امتداد الملف بحروف صغيرة لاستخدامه في قرارات العرض.
  String get fileExtension => fileName.split('.').last.toLowerCase();

  /// True when the attachment is an image that can be previewed inline.
  /// تكون صحيحة عندما يكون المرفق صورة قابلة للمعاينة داخل الواجهة.
  bool get isImage => contentType.startsWith('image/');

  /// True when the attachment is a video file.
  /// تكون صحيحة عندما يكون المرفق ملف فيديو.
  bool get isVideo => contentType.startsWith('video/');

  /// True when the attachment is an audio file.
  /// تكون صحيحة عندما يكون المرفق ملف صوت.
  bool get isAudio => contentType.startsWith('audio/');

  /// True when the attachment is treated as a generic document.
  /// تكون صحيحة عندما يُعامل المرفق كوثيقة عامة.
  bool get isDocument => !isImage && !isVideo && !isAudio;

  /// Formats the file size into a readable unit for badges and captions.
  /// ينسق حجم الملف إلى وحدة مقروءة للشارات والنصوص القصيرة.
  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024)
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Chat-specific preferences that control notifications, read receipts, and
/// media behavior for one user.
/// تفضيلات خاصة بالدردشة تتحكم في الإشعارات وإيصالات القراءة وسلوك
/// الوسائط لمستخدم واحد.
class ChatSettings extends Equatable {
  /// Stable identifier for the settings row.
  /// المعرّف الثابت لسجل الإعدادات.
  final String id;

  /// User that owns these preferences.
  /// المستخدم الذي يملك هذه التفضيلات.
  final String userId;

  /// Whether chat notifications should be delivered to the user.
  /// يحدد ما إذا كانت إشعارات الدردشة يجب أن تصل للمستخدم.
  final bool notificationsEnabled;

  /// Whether incoming chat sounds should be played.
  /// يحدد ما إذا كان يجب تشغيل الأصوات عند وصول الرسائل.
  final bool soundEnabled;

  /// Whether read receipts are visible to other participants.
  /// يحدد ما إذا كانت إيصالات القراءة تظهر للمشاركين الآخرين.
  final bool showReadReceipts;

  /// Whether the UI should expose typing indicators.
  /// يحدد ما إذا كانت الواجهة تعرض مؤشرات الكتابة.
  final bool showTypingIndicator;

  /// Chat theme preference such as `light`, `dark`, or `auto`.
  /// تفضيل سمة الدردشة مثل `light` أو `dark` أو `auto`.
  final String theme;

  /// Preferred message font size for the chat UI.
  /// حجم الخط المفضل لرسائل واجهة الدردشة.
  final String fontSize;

  /// Whether media should download automatically when possible.
  /// يحدد ما إذا كانت الوسائط تُنزّل تلقائيًا عند الإمكان.
  final bool autoDownloadMedia;

  /// Whether chat history should be backed up by the client.
  /// يحدد ما إذا كان سجل الدردشة يجب أن يُنسخ احتياطيًا من العميل.
  final bool backupMessages;

  /// Builds a settings snapshot for one chat user.
  /// ينشئ لقطة إعدادات لمستخدم دردشة واحد.
  const ChatSettings({
    required this.id,
    required this.userId,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.showReadReceipts = true,
    this.showTypingIndicator = true,
    this.theme = 'auto',
    this.fontSize = 'medium',
    this.autoDownloadMedia = true,
    this.backupMessages = false,
  });

  /// Equality is based on the full settings snapshot.
  /// تُبنى المساواة على لقطة الإعدادات الكاملة.
  @override
  List<Object> get props => [
        id,
        userId,
        notificationsEnabled,
        soundEnabled,
        showReadReceipts,
        showTypingIndicator,
        theme,
        fontSize,
        autoDownloadMedia,
        backupMessages,
      ];
}
