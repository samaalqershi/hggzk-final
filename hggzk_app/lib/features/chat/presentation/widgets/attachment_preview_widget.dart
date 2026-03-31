import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:just_audio/just_audio.dart';
import '../../../../app/dependency_injection/injection_container.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../domain/entities/attachment.dart';

/// Renders a chat attachment as an image, video, audio control, or document
/// card depending on the attachment type.
/// يرسم مرفق الدردشة كصورة أو فيديو أو عنصر صوت أو بطاقة مستند حسب النوع.
class AttachmentPreviewWidget extends StatefulWidget {
  /// Attachment being previewed in the message bubble.
  /// المرفق الذي تتم معاينته داخل فقاعة الرسالة.
  final Attachment attachment;

  /// Whether the preview belongs to the current user's outgoing message.
  /// يحدد ما إذا كانت المعاينة تخص رسالة صادرة من المستخدم الحالي.
  final bool isMe;

  /// Opens the full preview or viewer when the user taps the attachment.
  /// يفتح المعاينة الكاملة أو العارض عند النقر على المرفق.
  final VoidCallback? onTap;

  /// Starts a download flow for document-like attachments.
  /// يبدأ مسار التنزيل للمرفقات الشبيهة بالمستندات.
  final VoidCallback? onDownload;

  /// Whether remote media previews may download automatically.
  /// يحدد ما إذا كان مسموحًا بتحميل معاينات الوسائط البعيدة تلقائيًا.
  final bool autoDownloadEnabled;

  /// Builds the attachment preview card shown inside a chat bubble.
  /// ينشئ بطاقة معاينة المرفق التي تظهر داخل فقاعة الدردشة.
  const AttachmentPreviewWidget({
    super.key,
    required this.attachment,
    required this.isMe,
    this.onTap,
    this.onDownload,
    this.autoDownloadEnabled = true,
  });

  /// Creates the animated state used by the preview card.
  /// ينشئ الحالة المتحركة المستخدمة لبطاقة المعاينة.
  @override
  State<AttachmentPreviewWidget> createState() =>
      _AttachmentPreviewWidgetState();
}

/// Handles preview animations and type-specific rendering for attachments.
/// يدير حركات المعاينة والرسم الخاص بكل نوع من المرفقات.
class _AttachmentPreviewWidgetState extends State<AttachmentPreviewWidget>
    with SingleTickerProviderStateMixin {
  /// Controller used to animate loading shimmer overlays.
  /// متحكم الحركة المستخدم لتمرير تأثير اللمعان.
  late AnimationController _shimmerController;

  /// Animation value that moves the shimmer highlight across the card.
  /// قيمة حركة تنقل اللمعة عبر البطاقة.
  late Animation<double> _shimmerAnimation;
  AudioPlayer? _audioPlayer;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  bool _isPlaying = false;
  bool _isPreparingAudio = false;
  String? _cachedRemoteAudioPath;
  String? _cachedRemoteVideoPath;
  String? _cachedVideoThumbnailPath;
  int? _resolvedVideoDurationSeconds;

  /// Prepares the shimmer animation when the card mounts.
  /// يهيئ حركة اللمعان عند تركيب البطاقة.
  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOutSine,
    ));

    if (widget.attachment.downloadProgress != null &&
        widget.attachment.downloadProgress! < 1.0) {
      _shimmerController.repeat();
    }

    if (widget.attachment.isVideo) {
      _resolvedVideoDurationSeconds = widget.attachment.duration;
      if ((_resolvedVideoDurationSeconds ?? 0) <= 0) {
        unawaited(_resolveVideoDuration());
      }
    }

    if (widget.attachment.isAudio) {
      _audioPlayer = AudioPlayer();
      _durationSubscription = _audioPlayer!.durationStream.listen((duration) {
        if (!mounted || duration == null) return;
        setState(() {
          _audioDuration = duration;
        });
      });
      _positionSubscription = _audioPlayer!.positionStream.listen((position) {
        if (!mounted) return;
        setState(() {
          _audioPosition = position;
        });
      });
      _playerStateSubscription =
          _audioPlayer!.playerStateStream.listen((state) {
        if (!mounted) return;
        final completed = state.processingState == ProcessingState.completed;
        setState(() {
          _isPlaying = state.playing;
          if (completed) {
            _audioPosition = Duration.zero;
            _isPlaying = false;
          }
        });
        if (completed) {
          _audioPlayer!.seek(Duration.zero);
        }
      });
    }
  }

  /// Releases the shimmer controller before disposal.
  /// يحرر متحكم اللمعان قبل التخلص من الكائن.
  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer?.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  /// Chooses the correct preview layout for the attachment type.
  /// يختار تخطيط المعاينة المناسب حسب نوع المرفق.
  @override
  Widget build(BuildContext context) {
    if (widget.attachment.isImage) {
      return _buildImagePreview();
    } else if (widget.attachment.isVideo) {
      return _buildVideoPreview();
    } else if (widget.attachment.isAudio) {
      return _buildAudioPreview();
    } else {
      return _buildDocumentPreview();
    }
  }

  /// Renders the image preview with optional progress overlay.
  /// يرسم معاينة الصورة مع طبقة تقدم اختيارية.
  Widget _buildImagePreview() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap?.call();
      },
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 220, // Reduced from 300
          minHeight: 120, // Reduced from 150
        ),
        margin: const EdgeInsets.all(6), // Reduced from 8
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10), // Reduced from 12
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Glass effect background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.isMe
                          ? AppTheme.primaryBlue.withOpacity(0.05)
                          : AppTheme.darkCard.withOpacity(0.3),
                      widget.isMe
                          ? AppTheme.primaryPurple.withOpacity(0.03)
                          : AppTheme.darkSurface.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
              // Image
              _buildProtectedMediaImage(
                imageUrl: widget.attachment.fileUrl,
                fit: BoxFit.cover,
                localFallbackPath: widget.attachment.filePath,
              ),
              // Progress overlay
              if (widget.attachment.downloadProgress != null &&
                  widget.attachment.downloadProgress! < 1.0)
                _buildMinimalProgressOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  /// Renders the video thumbnail, play affordance, and duration badge.
  /// يرسم صورة الفيديو المصغرة وزر التشغيل وشارة المدة.
  Widget _buildVideoPreview() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap?.call();
      },
      child: Container(
        height: 160, // Reduced from 200
        margin: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail or placeholder
              _buildVideoPoster(),

              // Glassmorphism play button
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 44, // Reduced from 56
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24, // Reduced from 32
                      ),
                    ),
                  ),
                ),
              ),

              // Duration badge
              Positioned(
                bottom: 6,
                right: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _formatDuration(_displayVideoDurationSeconds),
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              if (widget.attachment.downloadProgress != null &&
                  widget.attachment.downloadProgress! < 1.0)
                _buildMinimalProgressOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  /// Renders the audio attachment as a compact playback-style card.
  /// يرسم المرفق الصوتي كبطاقة مضغوطة تشبه عناصر التشغيل.
  Widget _buildAudioPreview() {
    final accentColor = widget.isMe ? Colors.white : AppTheme.primaryBlue;
    final primaryTextColor = widget.isMe ? Colors.white : AppTheme.textWhite;
    final secondaryTextColor = widget.isMe
        ? Colors.white.withOpacity(0.7)
        : AppTheme.textMuted.withOpacity(0.85);
    final waveformBackground = widget.isMe
        ? Colors.white.withOpacity(0.07)
        : AppTheme.darkBackground.withOpacity(0.28);

    return Container(
      margin: const EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isMe
                    ? [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.04),
                      ]
                    : [
                        AppTheme.darkCard.withOpacity(0.78),
                        AppTheme.darkSurface.withOpacity(0.58),
                      ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: widget.isMe
                    ? Colors.white.withOpacity(0.14)
                    : AppTheme.darkBorder.withOpacity(0.38),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: (widget.isMe ? Colors.black : AppTheme.primaryBlue)
                      .withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _toggleAudioPlayback,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.isMe
                            ? [
                                Colors.white,
                                Colors.white.withOpacity(0.84),
                              ]
                            : [
                                AppTheme.primaryBlue,
                                AppTheme.primaryPurple,
                              ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isMe
                                  ? Colors.white
                                  : AppTheme.primaryBlue)
                              .withOpacity(_isPlaying ? 0.28 : 0.18),
                          blurRadius: _isPlaying ? 18 : 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isPreparingAudio
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.isMe
                                      ? AppTheme.primaryBlue
                                      : Colors.white,
                                ),
                              ),
                            )
                          : Icon(
                              _isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: widget.isMe
                                  ? AppTheme.primaryBlue
                                  : Colors.white,
                              size: 24,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(
                                widget.isMe ? 0.12 : 0.1,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.mic_rounded,
                                  size: 12,
                                  color: accentColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isPlaying
                                      ? 'تشغيل الآن'
                                      : (_isPreparingAudio
                                          ? 'جاري التحضير'
                                          : 'رسالة صوتية'),
                                  style: AppTextStyles.caption.copyWith(
                                    color: accentColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDuration(_resolvedAudioDurationSeconds),
                            style: AppTextStyles.caption.copyWith(
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: waveformBackground,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: accentColor.withOpacity(
                              widget.isMe ? 0.08 : 0.1,
                            ),
                            width: 0.6,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Positioned.fill(
                                    child: _buildMinimalWaveform(
                                      progress: _audioProgress,
                                    ),
                                  ),
                                  if (_audioProgress > 0)
                                    Align(
                                      alignment: Alignment(
                                        (_audioProgress * 2).clamp(0.0, 2.0) -
                                            1.0,
                                        0,
                                      ),
                                      child: Container(
                                        width: 9,
                                        height: 9,
                                        decoration: BoxDecoration(
                                          color: accentColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  accentColor.withOpacity(0.22),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _formatPlaybackClock(),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: primaryTextColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Draws the lightweight waveform used to suggest audio content.
  /// يرسم شكل الموجة الخفيف الذي يرمز إلى المحتوى الصوتي.
  Widget _buildMinimalWaveform({double progress = 0.0}) {
    return SizedBox(
      height: 18,
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _MinimalWaveformPainter(
              color: widget.isMe ? Colors.white : AppTheme.primaryBlue,
              progress: progress,
              shimmerPosition: _shimmerAnimation.value,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }

  /// Renders the document card with file metadata and download affordance.
  /// يرسم بطاقة المستند مع بيانات الملف وإجراء التنزيل.
  Widget _buildDocumentPreview() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap?.call();
      },
      child: Container(
        margin: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isMe
                      ? [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.04),
                        ]
                      : [
                          AppTheme.darkCard.withOpacity(0.6),
                          AppTheme.darkCard.withOpacity(0.3),
                        ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.isMe
                      ? Colors.white.withOpacity(0.1)
                      : AppTheme.darkBorder.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  // File icon
                  Container(
                    width: 38, // Reduced from 48
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getFileIconColor().withOpacity(0.15),
                          _getFileIconColor().withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getFileIcon(),
                      color: _getFileIconColor(),
                      size: 20, // Reduced from 24
                    ),
                  ),
                  const SizedBox(width: 10),

                  // File info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.attachment.fileName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color:
                                widget.isMe ? Colors.white : AppTheme.textWhite,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.attachment.fileExtension.toUpperCase()} • ${_formatFileSize(widget.attachment.fileSize)}',
                          style: AppTextStyles.caption.copyWith(
                            color: widget.isMe
                                ? Colors.white.withOpacity(0.5)
                                : AppTheme.textMuted.withOpacity(0.6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Download button
                  if (widget.onDownload != null)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        widget.onDownload!();
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryBlue.withOpacity(0.1),
                              AppTheme.primaryPurple.withOpacity(0.05),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.download_rounded,
                          color:
                              widget.isMe ? Colors.white : AppTheme.primaryBlue,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Shows the download progress overlay while the attachment is still
  /// transferring.
  /// يعرض طبقة تقدم التنزيل أثناء انتقال المرفق.
  Widget _buildMinimalProgressOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            value: widget.attachment.downloadProgress,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withOpacity(0.9),
            ),
            backgroundColor: Colors.white.withOpacity(0.2),
          ),
        ),
      ),
    );
  }

  /// Resolves the icon that best matches the attachment file type.
  /// يحدد الأيقونة الأنسب لنوع ملف المرفق.
  IconData _getFileIcon() {
    switch (widget.attachment.fileExtension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'zip':
      case 'rar':
        return Icons.folder_zip_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  /// Resolves the accent color associated with the attachment file type.
  /// يحدد لون التمييز المرتبط بنوع ملف المرفق.
  Color _getFileIconColor() {
    switch (widget.attachment.fileExtension.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFE74C3C);
      case 'doc':
      case 'docx':
        return const Color(0xFF2E86DE);
      case 'xls':
      case 'xlsx':
        return const Color(0xFF27AE60);
      case 'ppt':
      case 'pptx':
        return const Color(0xFFF39C12);
      case 'zip':
      case 'rar':
        return const Color(0xFF9B59B6);
      default:
        return AppTheme.textMuted;
    }
  }

  /// Formats the media duration into a compact `m:ss` label.
  /// ينسق مدة الوسائط إلى تسمية مختصرة بصيغة `m:ss`.
  String _formatDuration(int? seconds) {
    if (seconds == null) return '0:00';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Formats file size into human-readable units for the preview card.
  /// ينسق حجم الملف إلى وحدات مقروءة داخل بطاقة المعاينة.
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  int? get _resolvedAudioDurationSeconds {
    if (_audioDuration.inMilliseconds > 0) {
      return (_audioDuration.inMilliseconds / 1000).ceil();
    }
    return widget.attachment.duration;
  }

  String _formatPlaybackClock() {
    if (_audioPosition.inMilliseconds > 0) {
      return _formatSecondsClock(
        (_audioPosition.inMilliseconds / 1000).floor(),
      );
    }

    return _formatSecondsClock(_resolvedAudioDurationSeconds ?? 0);
  }

  String _formatSecondsClock(int seconds) {
    final safeSeconds = seconds < 0 ? 0 : seconds;
    final minutes = safeSeconds ~/ 60;
    final remainingSeconds = safeSeconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  int? get _displayVideoDurationSeconds {
    final resolved = _resolvedVideoDurationSeconds;
    if (resolved != null && resolved > 0) {
      return resolved;
    }
    return widget.attachment.duration;
  }

  double get _audioProgress {
    final total = _audioDuration.inMilliseconds;
    if (total <= 0) return 0;
    final current = _audioPosition.inMilliseconds.clamp(0, total);
    return current / total;
  }

  Future<void> _toggleAudioPlayback() async {
    if (!widget.attachment.isAudio || _audioPlayer == null) return;

    HapticFeedback.selectionClick();

    try {
      if (_isPlaying) {
        await _audioPlayer!.pause();
        return;
      }

      if (_audioPlayer!.audioSource == null) {
        setState(() {
          _isPreparingAudio = true;
        });

        final localPath = widget.attachment.filePath;
        if (localPath.isNotEmpty && File(localPath).existsSync()) {
          await _audioPlayer!.setFilePath(localPath);
        } else {
          final cachedPath = await _ensureRemoteAudioCached();
          await _audioPlayer!.setFilePath(cachedPath);
        }
      }

      await _audioPlayer!.play();
    } catch (error) {
      debugPrint('Audio playback failed for ${widget.attachment.id}: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isPreparingAudio = false;
        });
      }
    }
  }

  Map<String, String>? _buildAudioHeaders() {
    final token = sl<LocalStorageService>()
        .getData(StorageConstants.accessToken) as String?;
    if (token == null || token.isEmpty) {
      return null;
    }
    return {
      'Authorization': 'Bearer $token',
    };
  }

  Widget _buildProtectedMediaImage({
    required String imageUrl,
    required BoxFit fit,
    String? localFallbackPath,
  }) {
    final localPath = localFallbackPath?.trim() ?? '';
    if (localPath.isNotEmpty && File(localPath).existsSync()) {
      return Image.file(
        File(localPath),
        fit: fit,
      );
    }

    if (!widget.autoDownloadEnabled) {
      return _buildDeferredPreviewPlaceholder(
        icon: widget.attachment.isVideo
            ? Icons.video_library_rounded
            : Icons.image_outlined,
      );
    }

    return CachedImageWidget(
      imageUrl: _resolveProtectedMediaUrl(imageUrl),
      fit: fit,
      httpHeaders: _buildAudioHeaders(),
    );
  }

  Widget _buildVideoPoster() {
    final thumbnailUrl = widget.attachment.thumbnailUrl?.trim() ?? '';
    final localThumbnailPath = _resolveLocalThumbnailPath(thumbnailUrl);
    final resolvedThumbnailUrl = ImageUtils.resolveUrl(thumbnailUrl);

    if (localThumbnailPath != null) {
      return Image.file(
        File(localThumbnailPath),
        fit: BoxFit.cover,
      );
    }

    if (thumbnailUrl.isNotEmpty && resolvedThumbnailUrl.isNotEmpty) {
      return Image.network(
        resolvedThumbnailUrl,
        fit: BoxFit.cover,
        headers: _buildAudioHeaders(),
        errorBuilder: (_, __, ___) => _buildGeneratedVideoPosterFallback(),
      );
    }

    return _buildGeneratedVideoPosterFallback();
  }

  Widget _buildGeneratedVideoPosterFallback() {
    return FutureBuilder<String?>(
      future: _ensureVideoThumbnail(),
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
                AppTheme.darkCard.withOpacity(0.8),
                AppTheme.darkSurface.withOpacity(0.6),
              ],
            ),
          ),
          child: Icon(
            Icons.videocam_rounded,
            size: 32,
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
        );
      },
    );
  }

  Widget _buildDeferredPreviewPlaceholder({required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard.withOpacity(0.82),
            AppTheme.darkSurface.withOpacity(0.64),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 28,
          color: AppTheme.textMuted.withOpacity(0.6),
        ),
      ),
    );
  }

  String _resolveProtectedMediaUrl(String fileUrl) {
    return ImageUtils.resolveUrl(fileUrl);
  }

  String? _resolveLocalThumbnailPath(String thumbnailUrl) {
    final metadataPath = widget.attachment.metadata?['localThumbnailPath'];
    if (metadataPath is String && metadataPath.trim().isNotEmpty) {
      final metadataFile = File(metadataPath.trim());
      if (metadataFile.existsSync()) {
        return metadataPath.trim();
      }
    }

    if (thumbnailUrl.isEmpty) {
      return null;
    }

    final file = File(thumbnailUrl);
    if (!file.existsSync()) {
      return null;
    }

    return thumbnailUrl;
  }

  Future<String> _ensureRemoteAudioCached() async {
    final cachedPath = await _cacheProtectedMediaToTempFile(
      cachedPath: _cachedRemoteAudioPath,
      prefix: 'chat_audio',
      fallbackExtension: 'm4a',
    );
    _cachedRemoteAudioPath = cachedPath;
    return cachedPath;
  }

  Future<String> _ensureRemoteVideoCached() async {
    final cachedPath = await _cacheProtectedMediaToTempFile(
      cachedPath: _cachedRemoteVideoPath,
      prefix: 'chat_video',
      fallbackExtension: 'mp4',
    );
    _cachedRemoteVideoPath = cachedPath;
    return cachedPath;
  }

  Future<String?> _ensureVideoThumbnail() async {
    final existingPath = _cachedVideoThumbnailPath;
    if (existingPath != null && File(existingPath).existsSync()) {
      return existingPath;
    }

    final localPath = widget.attachment.filePath.trim();
    if (localPath.isNotEmpty && File(localPath).existsSync()) {
      return _generateVideoThumbnail(localPath);
    }

    try {
      final cachedVideoPath = await _ensureRemoteVideoCached();
      return _generateVideoThumbnail(cachedVideoPath);
    } catch (_) {
      return null;
    }
  }

  Future<void> _resolveVideoDuration() async {
    VideoPlayerController? controller;
    try {
      final localPath = widget.attachment.filePath.trim();
      if (localPath.isNotEmpty && File(localPath).existsSync()) {
        controller = VideoPlayerController.file(File(localPath));
      } else {
        final cachedVideoPath = await _ensureRemoteVideoCached();
        controller = VideoPlayerController.file(File(cachedVideoPath));
      }

      await controller.initialize();
      final seconds = controller.value.duration.inSeconds;
      if (!mounted || seconds <= 0) {
        return;
      }

      setState(() {
        _resolvedVideoDurationSeconds = seconds;
      });
    } catch (_) {
      // Ignore and keep the backend-provided duration if resolution fails.
    } finally {
      await controller?.dispose();
    }
  }

  Future<String?> _generateVideoThumbnail(String videoPath) async {
    final generated = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 720,
      quality: 72,
      thumbnailPath: Directory.systemTemp.path,
    );
    _cachedVideoThumbnailPath = generated;
    return generated;
  }

  Future<String> _cacheProtectedMediaToTempFile({
    required String? cachedPath,
    required String prefix,
    required String fallbackExtension,
  }) async {
    final existingPath = cachedPath;
    if (existingPath != null && File(existingPath).existsSync()) {
      return existingPath;
    }

    final extension = widget.attachment.fileExtension.isNotEmpty
        ? widget.attachment.fileExtension
        : fallbackExtension;
    final targetPath =
        '${Directory.systemTemp.path}/${prefix}_${widget.attachment.id}.$extension';
    final targetFile = File(targetPath);
    if (targetFile.existsSync()) {
      return targetPath;
    }

    final resolvedUrl = _resolveProtectedMediaUrl(widget.attachment.fileUrl);
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(resolvedUrl));
      final headers = _buildAudioHeaders();
      headers?.forEach(request.headers.add);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Media download failed with status ${response.statusCode}',
          uri: Uri.parse(resolvedUrl),
        );
      }

      final bytes = await consolidateHttpClientResponseBytes(response);
      await targetFile.writeAsBytes(bytes, flush: true);
      return targetPath;
    } finally {
      client.close(force: true);
    }
  }
}

/// Paints the decorative waveform used by audio attachments.
/// يرسم الموجة الزخرفية المستخدمة في المرفقات الصوتية.
class _MinimalWaveformPainter extends CustomPainter {
  /// Base color used for the waveform bars.
  /// اللون الأساسي لأعمدة الموجة.
  final Color color;

  /// Playback or download progress used to emphasize the filled portion.
  /// تقدم التشغيل أو التنزيل المستخدم لإبراز الجزء المكتمل.
  final double progress;

  /// Position of the moving highlight effect.
  /// موضع تأثير اللمعة المتحركة.
  final double shimmerPosition;

  /// Builds the waveform painter for one audio preview.
  /// ينشئ رسّام الموجة لمعاينة صوتية واحدة.
  _MinimalWaveformPainter({
    required this.color,
    required this.progress,
    this.shimmerPosition = 0,
  });

  /// Draws the waveform bars and the moving shimmer highlight.
  /// يرسم أعمدة الموجة ولمعة الحركة المتنقلة.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.18)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color.withOpacity(0.88)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    const barCount = 32;
    final barWidth = size.width / barCount;
    final amplitudes = <double>[
      0.22,
      0.48,
      0.32,
      0.72,
      0.42,
      0.28,
      0.65,
      0.36,
      0.54,
      0.24,
      0.78,
      0.34,
      0.58,
      0.26,
      0.44,
      0.70,
    ];

    for (int i = 0; i < barCount; i++) {
      final x = i * barWidth + barWidth / 2;
      final normalizedPosition = (i / barCount - shimmerPosition).abs();
      final shimmerOpacity =
          normalizedPosition < 0.2 ? 1.0 - (normalizedPosition * 5) : 0.0;

      final waveHeight = amplitudes[i % amplitudes.length] * size.height;
      final y1 = (size.height - waveHeight) / 2;
      final y2 = y1 + waveHeight;

      final isProgressed = i / barCount <= progress;
      final currentPaint = isProgressed ? progressPaint : paint;

      if (shimmerOpacity > 0) {
        final shimmerPaint = Paint()
          ..color = color.withOpacity(0.18 + shimmerOpacity * 0.32)
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(x, y1), Offset(x, y2), shimmerPaint);
      } else {
        canvas.drawLine(Offset(x, y1), Offset(x, y2), currentPaint);
      }
    }
  }

  /// The waveform animation changes continuously, so repainting is required.
  /// تتغير حركة الموجة باستمرار، لذلك إعادة الرسم مطلوبة.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
