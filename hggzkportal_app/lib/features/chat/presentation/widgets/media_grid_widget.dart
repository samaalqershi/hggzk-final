import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:ui';
import '../../../../app/dependency_injection/injection_container.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/services/local_storage_service.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../chat_settings_keys.dart';
import '../pages/chat_media_viewer_page.dart';
import '../../domain/entities/attachment.dart';

/// Grid of visual chat attachments that lets the user open images or videos
/// from the conversation media gallery.
/// شبكة لمرفقات الدردشة المرئية تتيح فتح الصور أو الفيديوهات من معرض
/// وسائط المحادثة.
class MediaGridWidget extends StatelessWidget {
  /// All image and video attachments that should appear in the gallery.
  /// جميع مرفقات الصور والفيديو التي يجب أن تظهر داخل المعرض.
  final List<Attachment> attachments;

  /// Builds the compact attachment gallery for a chat thread.
  /// ينشئ معرض المرفقات المضغوط لسلسلة المحادثة.
  const MediaGridWidget({
    super.key,
    required this.attachments,
  });

  /// Renders the 3-column gallery of conversation media.
  /// يرسم معرض وسائط المحادثة المكوّن من ثلاثة أعمدة.
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8), // Reduced from 12
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4, // Reduced from 8
        mainAxisSpacing: 4,
      ),
      itemCount: attachments.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return _MediaItem(
          attachment: attachments[index],
          galleryAttachments: attachments,
          index: index,
        );
      },
    );
  }
}

/// Single tile inside the media gallery.
/// بطاقة منفصلة داخل معرض الوسائط.
class _MediaItem extends StatefulWidget {
  /// Attachment represented by this tile.
  /// المرفق الذي تمثله هذه البطاقة.
  final Attachment attachment;

  /// Full attachment collection so the viewer can open the whole gallery.
  /// المجموعة الكاملة للمرفقات حتى يفتح العارض كل المعرض.
  final List<Attachment> galleryAttachments;

  /// Tile index used to stagger the entrance animation.
  /// فهرس البطاقة المستخدم لتدرّج حركة الظهور.
  final int index;

  /// Builds one animated media thumbnail.
  /// ينشئ صورة مصغرة متحركة واحدة للوسائط.
  const _MediaItem({
    required this.attachment,
    required this.galleryAttachments,
    required this.index,
  });

  /// Creates the animated tile state.
  /// ينشئ حالة البطاقة المتحركة.
  @override
  State<_MediaItem> createState() => _MediaItemState();
}

/// Animates the tile entrance and press feedback for a media preview.
/// يدير حركة الظهور وتغذية الضغط لمعاينة الوسائط.
class _MediaItemState extends State<_MediaItem>
    with SingleTickerProviderStateMixin {
  String? _cachedRemoteVideoPath;
  String? _cachedVideoThumbnailPath;

  bool get _autoDownloadEnabled {
    final persisted =
        sl<LocalStorageService>().getData(ChatSettingsKeys.autoDownloadMedia);
    if (persisted is bool) {
      return persisted;
    }

    return true;
  }

  /// Animation controller for the tile entrance.
  /// متحكم الحركة الخاص بظهور البطاقة.
  late AnimationController _controller;

  /// Scale curve used while the tile appears.
  /// منحنى التكبير المستخدم أثناء ظهور البطاقة.
  late Animation<double> _scaleAnimation;

  /// Tracks whether the tile is currently pressed.
  /// يتتبع ما إذا كانت البطاقة مضغوطة الآن.
  bool _isPressed = false;

  /// Prepares the entry animation for the tile.
  /// يهيئ حركة الظهور للبطاقة.
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();
  }

  /// Releases the tile animation controller.
  /// يحرر متحكم حركة البطاقة.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Resolves the attachment type and renders the thumbnail or video badge.
  /// يحدد نوع المرفق ثم يرسم الصورة المصغرة أو علامة الفيديو.
  @override
  Widget build(BuildContext context) {
    final attachment = widget.attachment;
    final isVideo = attachment.isVideo;
    final autoDownloadEnabled = _autoDownloadEnabled;
    final thumbnailUrl = attachment.thumbnailUrl?.trim();
    final localPath = attachment.filePath.trim();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatMediaViewerPage(
                attachments: widget.galleryAttachments,
                initialIndex: widget.index,
              ),
            ),
          );
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8), // Reduced from 10
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowDark.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  if (!isVideo)
                    localPath.isNotEmpty && File(localPath).existsSync()
                        ? Image.file(
                            File(localPath),
                            fit: BoxFit.cover,
                          )
                        : autoDownloadEnabled
                            ? CachedImageWidget(
                                imageUrl: attachment.fileUrl,
                                fit: BoxFit.cover,
                                httpHeaders: _buildAttachmentHeaders(),
                              )
                            : _buildDeferredMediaPlaceholder(
                                icon: Icons.image_outlined,
                              )
                  else if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
                    _buildRemoteThumbnailWithFallback(thumbnailUrl)
                  else if (localPath.isNotEmpty && File(localPath).existsSync())
                    Image.file(
                      File(localPath),
                      fit: BoxFit.cover,
                    )
                  else
                    FutureBuilder<String?>(
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
                            size: 28,
                            color: AppTheme.textMuted.withOpacity(0.55),
                          ),
                        );
                      },
                    ),

                  // Gradient overlay for video
                  if (isVideo)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),

                  // Play button for video
                  if (isVideo)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 36, // Reduced from 40
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Shimmer effect on load
                  if (_controller.isAnimating)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
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

  Widget _buildDeferredMediaPlaceholder({required IconData icon}) {
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
          color: AppTheme.textMuted.withOpacity(0.55),
        ),
      ),
    );
  }

  Widget _buildRemoteThumbnailWithFallback(String thumbnailUrl) {
    final localThumbnailPath = _resolveLocalThumbnailPath(thumbnailUrl);
    if (localThumbnailPath != null) {
      return Image.file(
        File(localThumbnailPath),
        fit: BoxFit.cover,
      );
    }

    final resolvedThumbnailUrl = ImageUtils.resolveUrl(thumbnailUrl);
    if (resolvedThumbnailUrl.isEmpty) {
      return _buildGeneratedVideoThumbnailFallback();
    }

    return Image.network(
      resolvedThumbnailUrl,
      fit: BoxFit.cover,
      headers: _buildAttachmentHeaders(),
      errorBuilder: (_, __, ___) => _buildGeneratedVideoThumbnailFallback(),
    );
  }

  Widget _buildGeneratedVideoThumbnailFallback() {
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
            size: 28,
            color: AppTheme.textMuted.withOpacity(0.55),
          ),
        );
      },
    );
  }

  Map<String, String>? _buildAttachmentHeaders() {
    final token = sl<LocalStorageService>()
        .getData(StorageConstants.accessToken) as String?;
    if (token == null || token.isEmpty) {
      return null;
    }

    return {
      'Authorization': 'Bearer $token',
    };
  }

  Future<String?> _ensureVideoThumbnail() async {
    if (!widget.attachment.isVideo) return null;

    final existingThumbnail = _cachedVideoThumbnailPath;
    if (existingThumbnail != null && File(existingThumbnail).existsSync()) {
      return existingThumbnail;
    }

    final localPath = widget.attachment.filePath.trim();
    if (localPath.isNotEmpty && File(localPath).existsSync()) {
      return _generateThumbnail(localPath);
    }

    try {
      final cachedVideoPath = await _ensureRemoteVideoCached();
      return _generateThumbnail(cachedVideoPath);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _generateThumbnail(String videoPath) async {
    final generated = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 640,
      quality: 70,
      thumbnailPath: Directory.systemTemp.path,
    );
    if (generated != null) {
      _cachedVideoThumbnailPath = generated;
    }
    return generated;
  }

  Future<String> _ensureRemoteVideoCached() async {
    final existingPath = _cachedRemoteVideoPath;
    if (existingPath != null && File(existingPath).existsSync()) {
      return existingPath;
    }

    final extension = widget.attachment.fileExtension.isNotEmpty
        ? widget.attachment.fileExtension
        : 'mp4';
    final targetPath =
        '${Directory.systemTemp.path}/chat_media_${widget.attachment.id}.$extension';
    final targetFile = File(targetPath);
    if (targetFile.existsSync()) {
      _cachedRemoteVideoPath = targetPath;
      return targetPath;
    }

    final client = HttpClient();
    try {
      final resolvedVideoUrl = ImageUtils.resolveUrl(widget.attachment.fileUrl);
      if (resolvedVideoUrl.isEmpty) {
        throw const HttpException('Video URL is empty');
      }

      final request = await client.getUrl(Uri.parse(resolvedVideoUrl));
      final headers = _buildAttachmentHeaders();
      headers?.forEach(request.headers.add);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Media download failed with status ${response.statusCode}',
          uri: Uri.parse(resolvedVideoUrl),
        );
      }

      final bytes = await consolidateHttpClientResponseBytes(response);
      await targetFile.writeAsBytes(bytes, flush: true);
      _cachedRemoteVideoPath = targetPath;
      return targetPath;
    } finally {
      client.close(force: true);
    }
  }

  String? _resolveLocalThumbnailPath(String thumbnailUrl) {
    final metadataPath = widget.attachment.metadata?['localThumbnailPath'];
    if (metadataPath is String && metadataPath.trim().isNotEmpty) {
      final metadataFile = File(metadataPath.trim());
      if (metadataFile.existsSync()) {
        return metadataPath.trim();
      }
    }

    final normalizedPath = thumbnailUrl.trim();
    if (normalizedPath.isEmpty) {
      return null;
    }

    final file = File(normalizedPath);
    if (!file.existsSync()) {
      return null;
    }

    return normalizedPath;
  }
}
