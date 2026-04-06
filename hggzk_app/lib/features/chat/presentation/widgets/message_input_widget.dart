import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/message.dart';
import '../bloc/chat_bloc.dart';

/// Composer anchored at the bottom of the chat screen for text, reply, edit,
/// attachment, and voice-note flows.
/// محرر مثبت أسفل شاشة الدردشة لكتابة النص والرد والتعديل والمرفقات
/// والملاحظات الصوتية.
class MessageInputWidget extends StatefulWidget {
  /// Live draft text controlled by the parent screen.
  /// المسودة النصية الحية التي تتحكم بها الشاشة الأب.
  final TextEditingController controller;

  /// Focus node that keeps the keyboard attached to the composer.
  /// عقدة التركيز التي تبقي لوحة المفاتيح مرتبطة بالمحرر.
  final FocusNode focusNode;

  /// Conversation that receives the outgoing message.
  /// المحادثة التي تستقبل الرسالة الصادرة.
  final String conversationId;

  /// Optional message id when the composer is replying.
  /// معرّف الرسالة الاختياري عندما يكون المحرر في وضع الرد.
  final String? replyToMessageId;

  /// Original message used when the composer edits an existing message.
  /// الرسالة الأصلية المستخدمة عند تعديل رسالة موجودة.
  final Message? editingMessage;

  /// Sends the cleaned message payload to the conversation bloc.
  /// يرسل الحمولة النصية المنظفة إلى bloc المحادثة.
  final Function(String) onSend;

  /// Sends the currently selected image batch together with an optional
  /// caption from the text field.
  /// يرسل دفعة الصور المحددة حاليًا مع تعليق اختياري من حقل النص.
  final Function(String)? onSendSelectedImages;

  /// Sends the currently selected video batch together with an optional
  /// caption from the text field.
  /// يرسل دفعة الفيديوهات المحددة حاليًا مع تعليق اختياري من حقل النص.
  final Function(String)? onSendSelectedVideos;

  /// Opens the attachment flow from the surrounding chat screen.
  /// يفتح مسار المرفقات من شاشة الدردشة المحيطة.
  final VoidCallback? onAttachment;

  /// Opens the gallery picker for one or more images.
  /// يفتح منتقي المعرض لصورة واحدة أو عدة صور.
  final Future<void> Function()? onPickGalleryImages;

  /// Opens the camera picker for a single image.
  /// يفتح الكاميرا لاختيار صورة واحدة.
  final Future<void> Function()? onPickCameraImage;

  /// Opens the gallery picker for one or more videos.
  /// يفتح منتقي المعرض لفيديو واحد أو عدة فيديوهات.
  final Future<void> Function()? onPickGalleryVideos;

  /// Image paths currently staged above the composer.
  /// مسارات الصور المعلقة حاليًا فوق المحرر.
  final List<String> selectedImagePaths;

  /// Video paths currently staged above the composer.
  /// مسارات الفيديوهات المعلقة حاليًا فوق المحرر.
  final List<String> selectedVideoPaths;

  /// Removes one staged image from the composer tray.
  /// يزيل صورة واحدة معلقة من شريط المحرر.
  final ValueChanged<String>? onRemoveSelectedImage;

  /// Clears every staged image from the composer tray.
  /// يزيل كل الصور المعلقة من شريط المحرر.
  final VoidCallback? onClearSelectedImages;

  /// Removes one staged video from the composer tray.
  /// يزيل فيديو واحدًا معلقًا من شريط المحرر.
  final ValueChanged<String>? onRemoveSelectedVideo;

  /// Clears every staged video from the composer tray.
  /// يزيل كل الفيديوهات المعلقة من شريط المحرر.
  final VoidCallback? onClearSelectedVideos;

  /// Starts location sharing when the host screen supports it.
  /// يبدأ مشاركة الموقع عندما تدعم الشاشة المضيفة ذلك.
  final VoidCallback? onLocation;

  /// Returns the composer from reply mode back to a normal draft flow.
  /// يعيد المحرر من وضع الرد إلى كتابة عادية.
  final VoidCallback? onCancelReply;

  /// Cancels edit mode without submitting a replacement message.
  /// يلغي وضع التعديل دون إرسال رسالة بديلة.
  final VoidCallback? onCancelEdit;

  /// Builds a composer that can send text, replies, attachments, or voice
  /// notes.
  /// ينشئ محررًا قادرًا على إرسال النصوص والردود والمرفقات والرسائل الصوتية.
  const MessageInputWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.conversationId,
    this.replyToMessageId,
    this.editingMessage,
    required this.onSend,
    this.onSendSelectedImages,
    this.onSendSelectedVideos,
    this.onAttachment,
    this.onPickGalleryImages,
    this.onPickCameraImage,
    this.onPickGalleryVideos,
    this.selectedImagePaths = const [],
    this.selectedVideoPaths = const [],
    this.onRemoveSelectedImage,
    this.onClearSelectedImages,
    this.onRemoveSelectedVideo,
    this.onClearSelectedVideos,
    this.onLocation,
    this.onCancelReply,
    this.onCancelEdit,
  });

  /// Convenience constructor for screens that already wire bloc callbacks.
  /// مُنشئ مساعد للشاشات التي تربط callbacks الخاصة بالـ bloc مسبقًا.
  static MessageInputWidget createWithBloc({
    Key? key,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String conversationId,
    String? replyToMessageId,
    Message? editingMessage,
    required Function(String) onSend,
    Function(String)? onSendSelectedImages,
    Function(String)? onSendSelectedVideos,
    VoidCallback? onAttachment,
    Future<void> Function()? onPickGalleryImages,
    Future<void> Function()? onPickCameraImage,
    Future<void> Function()? onPickGalleryVideos,
    List<String> selectedImagePaths = const [],
    List<String> selectedVideoPaths = const [],
    ValueChanged<String>? onRemoveSelectedImage,
    VoidCallback? onClearSelectedImages,
    ValueChanged<String>? onRemoveSelectedVideo,
    VoidCallback? onClearSelectedVideos,
    VoidCallback? onLocation,
    VoidCallback? onCancelReply,
    VoidCallback? onCancelEdit,
  }) {
    return MessageInputWidget(
      key: key,
      controller: controller,
      focusNode: focusNode,
      conversationId: conversationId,
      replyToMessageId: replyToMessageId,
      editingMessage: editingMessage,
      onSend: onSend,
      onSendSelectedImages: onSendSelectedImages,
      onSendSelectedVideos: onSendSelectedVideos,
      onAttachment: onAttachment,
      onPickGalleryImages: onPickGalleryImages,
      onPickCameraImage: onPickCameraImage,
      onPickGalleryVideos: onPickGalleryVideos,
      selectedImagePaths: selectedImagePaths,
      selectedVideoPaths: selectedVideoPaths,
      onRemoveSelectedImage: onRemoveSelectedImage,
      onClearSelectedImages: onClearSelectedImages,
      onRemoveSelectedVideo: onRemoveSelectedVideo,
      onClearSelectedVideos: onClearSelectedVideos,
      onLocation: onLocation,
      onCancelReply: onCancelReply,
      onCancelEdit: onCancelEdit,
    );
  }

  /// Creates the mutable composer state that drives animation and recording.
  /// ينشئ حالة المحرر المتغيرة التي تدير الحركة والتسجيل.
  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

/// Owns the transient UI state for the chat composer.
/// يملك الحالة المؤقتة لواجهة محرر الرسائل.
class _MessageInputWidgetState extends State<MessageInputWidget>
    with SingleTickerProviderStateMixin {
  static const double _cancelSlideThreshold = 96;
  static const Duration _minimumRecordingDuration = Duration(milliseconds: 700);
  final Map<String, Future<String?>> _videoThumbnailFutures = {};

  /// Drives the send-button and recording hint transitions.
  /// يقود انتقالات زر الإرسال ومؤشر التسجيل.
  late AnimationController _animationController;

  /// Expands the send affordance when the draft contains text.
  late Animation<double> _sendButtonAnimation;

  /// Soft pulse used to show that audio capture is active.
  late Animation<double> _recordAnimation;

  final AudioRecorder _audioRecorder = AudioRecorder();

  /// Tracks whether the recorder is currently capturing audio.
  bool _isRecording = false;

  /// Controls the visibility of the inline attachment menu.
  bool _showAttachmentOptions = false;

  /// Temporary path for the currently recorded audio file.
  String _recordingPath = '';

  /// Measures the live recording length shown in the composer.
  Duration _recordingDuration = Duration.zero;

  /// Tracks the recording ticker that refreshes the elapsed time.
  Timer? _recordingTimer;

  /// Horizontal drag distance while the finger slides to cancel.
  double _recordingDragOffset = 0;

  /// Whether the current gesture will cancel the recording when released.
  bool _willCancelRecording = false;

  /// Prevents duplicate finalize calls when both tap and gesture-end arrive.
  bool _isFinalizingRecording = false;

  /// Remembers the last recorded file dispatched so a single gesture does not
  /// enqueue the same voice note twice.
  String? _lastDispatchedRecordingPath;

  /// Timestamp of the last dispatched voice note path.
  DateTime? _lastDispatchedRecordingAt;

  /// Reads the chat bloc from the surrounding provider tree.
  ChatBloc? get _chatBloc => context.read<ChatBloc>();

  /// Sets up the composer animations and draft listener.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _sendButtonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _recordAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    widget.controller.addListener(_onTextChanged);
    _syncVideoThumbnailFutures();
    _syncActionButtonState();
  }

  @override
  void didUpdateWidget(covariant MessageInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }

    final selectedImagesChanged = !_areListsEqual(
      oldWidget.selectedImagePaths,
      widget.selectedImagePaths,
    );
    final selectedVideosChanged = !_areListsEqual(
      oldWidget.selectedVideoPaths,
      widget.selectedVideoPaths,
    );

    if (selectedImagesChanged || selectedVideosChanged) {
      _syncActionButtonState();
    }

    if (!_areListsEqual(
      oldWidget.selectedVideoPaths,
      widget.selectedVideoPaths,
    )) {
      _syncVideoThumbnailFutures();
    }
  }

  /// Releases animation, recorder, and listener resources.
  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _animationController.dispose();
    _audioRecorder.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  bool _areListsEqual(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _syncVideoThumbnailFutures() {
    final selected = widget.selectedVideoPaths.toSet();
    _videoThumbnailFutures.removeWhere((path, _) => !selected.contains(path));
    for (final path in widget.selectedVideoPaths) {
      _videoThumbnailFutures.putIfAbsent(
        path,
        () => _buildVideoThumbnail(path),
      );
    }
  }

  Future<String?> _thumbnailFutureFor(String videoPath) {
    return _videoThumbnailFutures.putIfAbsent(
      videoPath,
      () => _buildVideoThumbnail(videoPath),
    );
  }

  /// Toggles the send animation based on whether the draft is empty.
  void _onTextChanged() {
    _syncActionButtonState();
  }

  /// Keeps the primary action button aligned with the real draft state after
  /// text edits and after the recorder temporarily hijacks the same animation
  /// controller for its pulse.
  void _syncActionButtonState() {
    if (_isRecording) return;

    final hasDraftText = widget.controller.text.trim().isNotEmpty;
    final hasPendingImages = widget.selectedImagePaths.isNotEmpty;
    final hasPendingVideos = widget.selectedVideoPaths.isNotEmpty;
    if (hasDraftText || hasPendingImages || hasPendingVideos) {
      if (_animationController.status != AnimationStatus.forward &&
          _sendButtonAnimation.value < 1) {
        _animationController.forward();
      }
      return;
    }

    if (_animationController.status != AnimationStatus.reverse &&
        _sendButtonAnimation.value > 0) {
      _animationController.reverse();
    }
  }

  /// Builds the composer shell and its inline action zones.
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 10,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.12),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showAttachmentOptions) _buildMinimalAttachmentOptions(),
              if (widget.selectedImagePaths.isNotEmpty ||
                  widget.selectedVideoPaths.isNotEmpty)
                _buildSelectedImagesTray(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!_isRecording) _buildMinimalAttachmentButton(),
                  if (!_isRecording) const SizedBox(width: 5),
                  Expanded(
                    child: _isRecording
                        ? _buildRecordingComposer()
                        : _buildMinimalInputField(),
                  ),
                  const SizedBox(width: 5),
                  _buildMinimalActionButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the horizontal row of quick attachment actions.
  Widget _buildMinimalAttachmentOptions() {
    return Container(
      height: 64,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _MinimalAttachmentOption(
            icon: Icons.image_rounded,
            label: context.tr('chat.composer.image'),
            gradient: [
              AppTheme.primaryBlue.withOpacity(0.8),
              AppTheme.primaryBlue.withOpacity(0.6),
            ],
            onTap: () => _pickImage(ImageSource.gallery),
          ),
          _MinimalAttachmentOption(
            icon: Icons.camera_alt_rounded,
            label: context.tr('chat.composer.camera'),
            gradient: [
              AppTheme.neonGreen.withOpacity(0.8),
              AppTheme.neonGreen.withOpacity(0.6),
            ],
            onTap: () => _pickImage(ImageSource.camera),
          ),
          _MinimalAttachmentOption(
            icon: Icons.videocam_rounded,
            label: context.tr('chat.composer.video'),
            gradient: [
              AppTheme.error.withOpacity(0.8),
              AppTheme.error.withOpacity(0.6),
            ],
            onTap: _pickVideo,
          ),
          _MinimalAttachmentOption(
            icon: Icons.attach_file_rounded,
            label: context.tr('chat.composer.file'),
            gradient: [
              AppTheme.warning.withOpacity(0.8),
              AppTheme.warning.withOpacity(0.6),
            ],
            onTap: _pickFile,
          ),
          _MinimalAttachmentOption(
            icon: Icons.location_on_rounded,
            label: context.tr('chat.composer.location'),
            gradient: [
              AppTheme.primaryPurple.withOpacity(0.8),
              AppTheme.primaryPurple.withOpacity(0.6),
            ],
            onTap: () {
              setState(() {
                _showAttachmentOptions = false;
              });
              widget.onLocation?.call();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedImagesTray() {
    final showingVideos = widget.selectedVideoPaths.isNotEmpty;
    final stagedPaths =
        showingVideos ? widget.selectedVideoPaths : widget.selectedImagePaths;
    final count = stagedPaths.length;
    final isSingle = count == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.1),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.85),
                      AppTheme.primaryPurple.withOpacity(0.75),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  showingVideos
                      ? Icons.video_library_rounded
                      : Icons.photo_library_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isSingle
                      ? context.tr(showingVideos
                          ? 'chat.composer.selectedSingleVideo'
                          : 'chat.composer.selectedSinglePhoto')
                      : context.tr(
                          showingVideos
                              ? 'chat.composer.selectedVideosCount'
                              : 'chat.composer.selectedPhotosCount',
                          params: {'count': '$count'},
                        ),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textWhite.withOpacity(0.88),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
              if ((showingVideos
                      ? widget.onClearSelectedVideos
                      : widget.onClearSelectedImages) !=
                  null)
                GestureDetector(
                  onTap: showingVideos
                      ? widget.onClearSelectedVideos
                      : widget.onClearSelectedImages,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      context.tr('chat.composer.clearAll'),
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textWhite.withOpacity(0.72),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 86,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: stagedPaths.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final mediaPath = stagedPaths[index];
                return _buildSelectedImageChip(
                  mediaPath,
                  isVideo: showingVideos,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedImageChip(
    String imagePath, {
    bool isVideo = false,
  }) {
    return Stack(
      children: [
        Container(
          width: 86,
          height: 86,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: isVideo
              ? _buildSelectedVideoChipBody(imagePath)
              : Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: AppTheme.darkSurface.withOpacity(0.55),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: AppTheme.textMuted.withOpacity(0.55),
                        size: 22,
                      ),
                    );
                  },
                ),
        ),
        if ((isVideo
                ? widget.onRemoveSelectedVideo
                : widget.onRemoveSelectedImage) !=
            null)
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () {
                if (isVideo) {
                  widget.onRemoveSelectedVideo!(imagePath);
                } else {
                  widget.onRemoveSelectedImage!(imagePath);
                }
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.46),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 0.5,
                  ),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedVideoChipBody(String videoPath) {
    final fileName = File(videoPath).uri.pathSegments.isNotEmpty
        ? File(videoPath).uri.pathSegments.last
        : 'video.mp4';
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkSurface.withOpacity(0.82),
            AppTheme.darkCard.withOpacity(0.62),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder<String?>(
            future: _thumbnailFutureFor(videoPath),
            builder: (context, snapshot) {
              final thumbPath = snapshot.data;
              if (thumbPath != null && File(thumbPath).existsSync()) {
                return Image.file(
                  File(thumbPath),
                  fit: BoxFit.cover,
                );
              }

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.darkSurface.withOpacity(0.82),
                      AppTheme.darkCard.withOpacity(0.62),
                    ],
                  ),
                ),
              );
            },
          ),
          Container(
            color: Colors.black.withOpacity(0.08),
          ),
          FutureBuilder<String?>(
            future: _thumbnailFutureFor(videoPath),
            builder: (context, snapshot) {
              final isPreparing =
                  snapshot.connectionState == ConnectionState.waiting &&
                      (snapshot.data == null || snapshot.data!.isEmpty);
              if (!isPreparing) {
                return const SizedBox.shrink();
              }

              return Container(
                color: Colors.black.withOpacity(0.22),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.92),
                        ),
                        backgroundColor: Colors.white.withOpacity(0.18),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr('chat.composer.preparingVideo'),
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withOpacity(0.92),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Center(
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.52),
                  ],
                ),
              ),
              child: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withOpacity(0.88),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _buildVideoThumbnail(String videoPath) async {
    try {
      return await VideoThumbnail.thumbnailFile(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 280,
        quality: 72,
        thumbnailPath: Directory.systemTemp.path,
      );
    } catch (_) {
      return null;
    }
  }

  /// Builds the button that opens or closes the attachment strip.
  Widget _buildMinimalAttachmentButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _showAttachmentOptions = !_showAttachmentOptions;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: _showAttachmentOptions
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.8),
                    AppTheme.primaryPurple.withOpacity(0.7),
                  ],
                )
              : null,
          color: !_showAttachmentOptions
              ? AppTheme.darkCard.withOpacity(0.4)
              : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _showAttachmentOptions
                ? Colors.white.withOpacity(0.15)
                : AppTheme.darkBorder.withOpacity(0.15),
            width: 0.8,
          ),
        ),
        child: AnimatedRotation(
          duration: const Duration(milliseconds: 200),
          turns: _showAttachmentOptions ? 0.125 : 0,
          child: Icon(
            Icons.add_rounded,
            color: _showAttachmentOptions
                ? Colors.white
                : AppTheme.textMuted.withOpacity(0.5),
            size: 22,
          ),
        ),
      ),
    );
  }

  /// Builds the compact multiline text field used for chat drafts.
  Widget _buildMinimalInputField() {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 46,
        maxHeight: 104,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.035),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.focusNode.hasFocus
              ? AppTheme.primaryBlue.withOpacity(0.24)
              : AppTheme.darkBorder.withOpacity(0.1),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: AppTheme.textWhite.withOpacity(0.9),
                height: 1.3,
              ),
              decoration: InputDecoration(
                hintText: widget.editingMessage != null
                    ? context.tr(
                        'chat.composer.editHint',
                      )
                    : widget.replyToMessageId != null
                        ? context.tr(
                            'chat.composer.replyHint',
                          )
                        : context.tr(
                            'chat.composer.messageHint',
                          ),
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textMuted.withOpacity(0.44),
                  fontSize: 12.5,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                isDense: true,
              ),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty ||
                    widget.selectedImagePaths.isNotEmpty ||
                    widget.selectedVideoPaths.isNotEmpty) {
                  _sendMessage();
                }
              },
            ),
          ),
          GestureDetector(
            onTap: _insertEmoji,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.emoji_emotions_outlined,
                color: AppTheme.textMuted.withOpacity(0.5),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the primary send/mic action and its recording state.
  Widget _buildMinimalActionButton() {
    return AnimatedBuilder(
      animation: _sendButtonAnimation,
      builder: (context, child) {
        final showSend = _sendButtonAnimation.value > 0.5;

        return GestureDetector(
          onTap: _isRecording
              ? () => _finishRecording(forceSend: true)
              : (showSend ? _sendMessage : null),
          onLongPressStart: !showSend ? (_) => _startRecording() : null,
          onLongPressMoveUpdate: !showSend ? _handleRecordingDragUpdate : null,
          onLongPressEnd: !showSend ? (_) => _finishRecording() : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isRecording ? 50 : 44,
            height: _isRecording ? 50 : 44,
            decoration: BoxDecoration(
              gradient: showSend || _isRecording
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _isRecording
                            ? AppTheme.error.withOpacity(0.85)
                            : AppTheme.primaryBlue.withOpacity(0.8),
                        _isRecording
                            ? const Color(0xFFFF6A6A)
                            : AppTheme.primaryPurple.withOpacity(0.7),
                      ],
                    )
                  : null,
              color: !showSend && !_isRecording
                  ? AppTheme.darkCard.withOpacity(0.4)
                  : null,
              shape: BoxShape.circle,
              border: Border.all(
                color: showSend || _isRecording
                    ? Colors.white.withOpacity(0.15)
                    : AppTheme.darkBorder.withOpacity(0.15),
                width: 0.8,
              ),
              boxShadow: showSend || _isRecording
                  ? [
                      BoxShadow(
                        color: (_isRecording
                                ? AppTheme.error
                                : AppTheme.primaryBlue)
                            .withOpacity(0.22),
                        blurRadius: _isRecording ? 18 : 14,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: _isRecording
                    ? _buildMinimalRecordingIndicator()
                    : Icon(
                        showSend ? Icons.send_rounded : Icons.mic_rounded,
                        color: showSend || _isRecording
                            ? Colors.white
                            : AppTheme.textMuted.withOpacity(0.5),
                        size: 20,
                        key: ValueKey(showSend),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the pulsing indicator shown while audio capture is active.
  Widget _buildMinimalRecordingIndicator() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _recordAnimation.value,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.error.withOpacity(0.8),
                  AppTheme.error.withOpacity(0.6),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.error.withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds a WhatsApp/Telegram-inspired inline recorder shell while the
  /// finger is holding the mic button.
  Widget _buildRecordingComposer() {
    final hintColor = _willCancelRecording
        ? AppTheme.error.withOpacity(0.95)
        : AppTheme.textMuted.withOpacity(0.78);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.72),
            AppTheme.darkCard.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _willCancelRecording
              ? AppTheme.error.withOpacity(0.28)
              : AppTheme.primaryBlue.withOpacity(0.16),
          width: 0.7,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _willCancelRecording
                  ? AppTheme.error
                  : const Color(0xFFFF5A5F),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_willCancelRecording
                          ? AppTheme.error
                          : const Color(0xFFFF5A5F))
                      .withOpacity(0.35),
                  blurRadius: 10,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatRecordingDuration(_recordingDuration),
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.92),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final showHint = constraints.maxHeight >= 40;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRecordingWaveform(),
                    if (showHint) ...[
                      const SizedBox(height: 2),
                      Transform.translate(
                        offset: Offset(_recordingDragOffset * 0.35, 0),
                        child: Row(
                          children: [
                            Icon(
                              _willCancelRecording
                                  ? Icons.delete_outline_rounded
                                  : Icons.keyboard_double_arrow_left_rounded,
                              color: hintColor,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                _willCancelRecording
                                    ? context
                                        .tr('chat.composer.releaseToCancel')
                                    : context.tr('chat.composer.slideToCancel'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  color: hintColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Decorative bars that make the recording state feel alive.
  Widget _buildRecordingWaveform() {
    final bars = List.generate(18, (index) => index);
    return Row(
      children: bars.map((index) {
        final baseHeight = 5 + ((index % 5) * 2);
        final animatedHeight = _isRecording && !_willCancelRecording
            ? baseHeight + (_recordAnimation.value * 2.5)
            : baseHeight.toDouble();
        return Container(
          width: 3,
          height: animatedHeight,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color:
                (_willCancelRecording ? AppTheme.error : AppTheme.primaryBlue)
                    .withOpacity(index.isEven ? 0.18 : 0.28),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }).toList(),
    );
  }

  /// Sends the trimmed text draft through the chat bloc.
  void _sendMessage() {
    final text = widget.controller.text.trim();
    if (widget.selectedImagePaths.isNotEmpty) {
      HapticFeedback.lightImpact();
      widget.onSendSelectedImages?.call(text);
      return;
    }

    if (widget.selectedVideoPaths.isNotEmpty) {
      HapticFeedback.lightImpact();
      widget.onSendSelectedVideos?.call(text);
      return;
    }

    if (text.isNotEmpty) {
      HapticFeedback.lightImpact();
      widget.onSend(text);
    }
  }

  /// Starts microphone capture after checking runtime permission.
  Future<void> _startRecording() async {
    HapticFeedback.mediumImpact();
    widget.focusNode.unfocus();
    setState(() {
      _showAttachmentOptions = false;
    });

    final permission = await Permission.microphone.request();
    if (!permission.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('chat.composer.microphonePermissionRequired'),
            ),
          ),
        );
      }
      return;
    }

    if (await _audioRecorder.hasPermission()) {
      final directory = Directory.systemTemp;
      _recordingPath =
          '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _recordingPath,
      );

      setState(() {
        _isRecording = true;
        _willCancelRecording = false;
        _recordingDragOffset = 0;
        _recordingDuration = Duration.zero;
        _isFinalizingRecording = false;
      });

      _animationController.repeat(reverse: true);
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || !_isRecording) return;
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });
      });
    }
  }

  /// Tracks the drag distance during a hold-to-record gesture.
  void _handleRecordingDragUpdate(LongPressMoveUpdateDetails details) {
    if (!_isRecording) return;

    final dragDx = details.offsetFromOrigin.dx.clamp(-140.0, 0.0);
    final shouldCancel = dragDx <= -_cancelSlideThreshold;
    if (dragDx == _recordingDragOffset &&
        shouldCancel == _willCancelRecording) {
      return;
    }

    setState(() {
      _recordingDragOffset = dragDx;
      _willCancelRecording = shouldCancel;
    });
  }

  /// Finalizes the recording gesture by either cancelling or sending.
  Future<void> _finishRecording({bool forceSend = false}) async {
    if (!_isRecording || _isFinalizingRecording) return;
    _isFinalizingRecording = true;

    HapticFeedback.mediumImpact();
    _animationController.stop();
    _recordingTimer?.cancel();
    final capturedDuration = _recordingDuration;
    final shouldCancel = !forceSend &&
        (_willCancelRecording || capturedDuration < _minimumRecordingDuration);
    final path = await _audioRecorder.stop();

    setState(() {
      _isRecording = false;
      _willCancelRecording = false;
      _recordingDragOffset = 0;
      _recordingDuration = Duration.zero;
      _isFinalizingRecording = false;
    });

    _syncActionButtonState();

    if (shouldCancel) {
      await _discardRecordingFile(path ?? _recordingPath);
      return;
    }

    if (path != null) {
      final normalizedDurationSeconds = capturedDuration.inMilliseconds <= 0
          ? null
          : ((capturedDuration.inMilliseconds + 999) ~/ 1000).clamp(1, 3600);
      _sendAudioMessage(
        path,
        durationSeconds: normalizedDurationSeconds,
      );
    }
  }

  /// Wraps the recorded file into the dedicated chat event.
  void _sendAudioMessage(
    String path, {
    int? durationSeconds,
  }) async {
    try {
      // Upload the audio file as part of the message sending process
      await _sendMessageWithAudioFile(
        path,
        durationSeconds: durationSeconds,
      );
    } catch (e) {
      // Handle error appropriately
      print('Error sending audio message: $e');
    }
  }

  /// Picks a compressed image from the chosen source and closes the sheet.
  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.gallery && widget.onPickGalleryImages != null) {
      setState(() {
        _showAttachmentOptions = false;
      });
      await widget.onPickGalleryImages!();
      return;
    }

    if (source == ImageSource.camera && widget.onPickCameraImage != null) {
      setState(() {
        _showAttachmentOptions = false;
      });
      await widget.onPickCameraImage!();
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _showAttachmentOptions = false;
      });
      // Send image
    }
  }

  /// Picks a short video from the gallery and collapses the sheet.
  Future<void> _pickVideo() async {
    if (widget.onPickGalleryVideos != null) {
      setState(() {
        _showAttachmentOptions = false;
      });
      await widget.onPickGalleryVideos!();
      return;
    }

    final picker = ImagePicker();
    final video = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );

    if (video != null) {
      setState(() {
        _showAttachmentOptions = false;
      });
      // Send video
    }
  }

  /// Closes the attachment sheet before handing off to a file picker.
  void _pickFile() {
    setState(() {
      _showAttachmentOptions = false;
    });
    // Implement file picker
  }

  /// Triggers the emoji affordance and provides immediate tactile feedback.
  void _insertEmoji() {
    HapticFeedback.lightImpact();
    // Show emoji picker
  }

  /// Sends the recorded audio path through the chat bloc.
  Future<void> _sendMessageWithAudioFile(
    String filePath, {
    int? durationSeconds,
  }) async {
    if (_chatBloc == null) {
      print('ChatBloc not available');
      return;
    }

    try {
      final now = DateTime.now();
      final normalizedPath = filePath.trim();
      if (_lastDispatchedRecordingPath == normalizedPath &&
          _lastDispatchedRecordingAt != null &&
          now.difference(_lastDispatchedRecordingAt!).inSeconds < 8) {
        return;
      }

      _lastDispatchedRecordingPath = normalizedPath;
      _lastDispatchedRecordingAt = now;

      // Send the audio message using the new dedicated event
      _chatBloc!.add(SendAudioMessageEvent(
        conversationId: widget.conversationId,
        filePath: normalizedPath,
        replyToMessageId: widget.replyToMessageId,
        durationSeconds: durationSeconds,
      ));
    } catch (e) {
      print('Error sending audio message: $e');
    }
  }

  /// Deletes a cancelled temporary recording so accidental notes do not pile
  /// up in the temp directory.
  Future<void> _discardRecordingFile(String? path) async {
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Formats the recorder timer using a compact minute-second layout.
  String _formatRecordingDuration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Small action tile used inside the attachment sheet.
class _MinimalAttachmentOption extends StatelessWidget {
  /// Icon shown inside the attachment tile.
  final IconData icon;

  /// Short label describing the action.
  final String label;

  /// Gradient used to make the tile visually distinct.
  final List<Color> gradient;

  /// Invoked when the user taps the tile.
  final VoidCallback onTap;

  /// Builds one compact attachment action.
  const _MinimalAttachmentOption({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  /// Builds the tappable attachment action tile.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 56,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 9,
                color: AppTheme.textMuted.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
