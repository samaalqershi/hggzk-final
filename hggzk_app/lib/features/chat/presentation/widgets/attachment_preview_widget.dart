import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
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

  /// Builds the attachment preview card shown inside a chat bubble.
  /// ينشئ بطاقة معاينة المرفق التي تظهر داخل فقاعة الدردشة.
  const AttachmentPreviewWidget({
    super.key,
    required this.attachment,
    required this.isMe,
    this.onTap,
    this.onDownload,
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
  }

  /// Releases the shimmer controller before disposal.
  /// يحرر متحكم اللمعان قبل التخلص من الكائن.
  @override
  void dispose() {
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
              CachedImageWidget(
                imageUrl: widget.attachment.fileUrl,
                fit: BoxFit.cover,
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
              if (widget.attachment.thumbnailUrl != null)
                CachedImageWidget(
                  imageUrl: widget.attachment.thumbnailUrl!,
                  fit: BoxFit.cover,
                )
              else
                Container(
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
                    size: 32, // Reduced from 48
                    color: AppTheme.textMuted.withOpacity(0.5),
                  ),
                ),

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
                        _formatDuration(widget.attachment.duration),
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
    return Container(
      margin: const EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(10), // Reduced from 12
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
                // Play button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onTap?.call();
                  },
                  child: Container(
                    width: 32, // Reduced from 40
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isMe
                            ? [
                                Colors.white.withOpacity(0.9),
                                Colors.white.withOpacity(0.7)
                              ]
                            : [AppTheme.primaryBlue, AppTheme.primaryPurple],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isMe
                                  ? Colors.white
                                  : AppTheme.primaryBlue)
                              .withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: widget.isMe ? AppTheme.primaryBlue : Colors.white,
                      size: 18, // Reduced from 24
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Waveform
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMinimalWaveform(),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(widget.attachment.duration),
                        style: AppTextStyles.caption.copyWith(
                          color: widget.isMe
                              ? Colors.white.withOpacity(0.6)
                              : AppTheme.textMuted.withOpacity(0.7),
                          fontSize: 10,
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
  Widget _buildMinimalWaveform() {
    return SizedBox(
      height: 24, // Reduced from 30
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _MinimalWaveformPainter(
              color: widget.isMe ? Colors.white : AppTheme.primaryBlue,
              progress: 0.0,
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
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const barCount = 25; // Reduced from 30
    final barWidth = size.width / barCount;

    for (int i = 0; i < barCount; i++) {
      final x = i * barWidth + barWidth / 2;
      final normalizedPosition = (i / barCount - shimmerPosition).abs();
      final shimmerOpacity =
          normalizedPosition < 0.2 ? 1.0 - (normalizedPosition * 5) : 0.0;

      // Create more elegant wave pattern
      final waveHeight = (i % 3 == 0
              ? 0.2
              : i % 2 == 0
                  ? 0.4
                  : 0.6) *
          size.height;
      final y1 = (size.height - waveHeight) / 2;
      final y2 = y1 + waveHeight;

      final isProgressed = i / barCount <= progress;
      final currentPaint = isProgressed ? progressPaint : paint;

      if (shimmerOpacity > 0) {
        final shimmerPaint = Paint()
          ..color = color.withOpacity(0.2 + shimmerOpacity * 0.3)
          ..strokeWidth = 1.5
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
