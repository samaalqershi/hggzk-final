import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../domain/entities/attachment.dart';
import 'expandable_image_viewer.dart';
import 'package:hggzkportal/injection_container.dart';
import '../../data/datasources/chat_local_datasource.dart';

/// يعرّف الكلاس `WhatsAppStyleImageGrid`.
/// Describes the `WhatsAppStyleImageGrid` class.
class WhatsAppStyleImageGrid extends StatelessWidget {
  /// Holds the `images` value.
  /// العربية: يخزن القيمة `images`.
  final List<Attachment> images;

  /// يخزن العضو `isMe`.
  /// Holds the `isMe` member.
  final bool isMe;

  /// يخزن العضو `onTap`.
  /// Holds the `onTap` member.
  final VoidCallback? onTap;
  // Optional callbacks to propagate actions to parent (message-level)
  /// ينفذ العملية `Function`.
  /// Runs the `Function` operation.
  final Function(String)? onReaction;

  /// ينفذ العملية `Function`.
  /// Runs the `Function` operation.
  final void Function(Attachment)? onReply;
  // Optional: per-attachment reaction state to reflect overlay in viewer
  /// يخزن العضو `reactionsByAttachment`.
  /// Holds the `reactionsByAttachment` member.
  final Map<String, String>? reactionsByAttachment;
  // Optional: callback when a reaction is set for a specific attachment
  /// ينفذ العملية `Function`.
  /// Runs the `Function` operation.
  final void Function(Attachment, String)? onReactForAttachment;

  /// ينشئ مثيلاً من `WhatsAppStyleImageGrid`.
  /// Builds an instance of `WhatsAppStyleImageGrid`.
  const WhatsAppStyleImageGrid({
    super.key,
    required this.images,
    required this.isMe,
    this.onTap,
    this.onReaction,
    this.onReply,
    this.reactionsByAttachment,
    this.onReactForAttachment,
  });

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    final imageCount = images.length;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _openImageViewer(context, 0);
      },
      onLongPress: () {
        HapticFeedback.lightImpact();
        _openImageViewer(context, 0);
      },
      child: _buildGrid(imageCount),
    );
  }

  /// ينفذ العملية `_buildGrid`.
  /// Runs the `_buildGrid` operation.
  Widget _buildGrid(int count) {
    switch (count) {
      case 1:
        return _buildSingleImage(images.first);
      case 2:
        return _buildTwoImages();
      case 3:
        return _buildThreeImages();
      case 4:
        return _buildFourImages();
      default:
        return _buildMoreImages();
    }
  }

  /// ينفذ العملية `_buildSingleImage`.
  /// Runs the `_buildSingleImage` operation.
  Widget _buildSingleImage(Attachment image) {
    // Keep a visually pleasant default ratio and ensure tap opens viewer.
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Builder(
        builder: (context) => GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _openImageViewer(context, 0);
          },
          onLongPress: () {
            HapticFeedback.lightImpact();
            _openImageViewer(context, 0);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImageSurface(image),
              if (_hasOverlayFor(image)) _buildReactionOverlay(image),
            ],
          ),
        ),
      ),
    );
  }

  /// ينفذ العملية `_buildTwoImages`.
  /// Runs the `_buildTwoImages` operation.
  Widget _buildTwoImages() {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Row(
        children: [
          Expanded(
            child: _buildImageTile(images[0], 0),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: _buildImageTile(images[1], 1),
          ),
        ],
      ),
    );
  }

  /// ينفذ العملية `_buildThreeImages`.
  /// Runs the `_buildThreeImages` operation.
  Widget _buildThreeImages() {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildImageTile(images[0], 0),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _buildImageTile(images[1], 1),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: _buildImageTile(images[2], 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ينفذ العملية `_buildFourImages`.
  /// Runs the `_buildFourImages` operation.
  Widget _buildFourImages() {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildImageTile(images[0], 0),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: _buildImageTile(images[1], 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildImageTile(images[2], 2),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: _buildImageTile(images[3], 3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ينفذ العملية `_buildMoreImages`.
  /// Runs the `_buildMoreImages` operation.
  Widget _buildMoreImages() {
    final displayImages = images.take(4).toList();
    final remainingCount = images.length - 4;

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildImageTile(displayImages[0], 0),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: _buildImageTile(displayImages[1], 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildImageTile(displayImages[2], 2),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildImageTile(displayImages[3], 3),
                      if (remainingCount > 0)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.7),
                                Colors.black.withValues(alpha: 0.5),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '+$remainingCount',
                              style: AppTextStyles.heading2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
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
    );
  }

  /// ينفذ العملية `_buildImageTile`.
  /// Runs the `_buildImageTile` operation.
  Widget _buildImageTile(Attachment image, int index) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _openImageViewer(context, index);
        },
        onLongPress: () {
          HapticFeedback.lightImpact();
          _openImageViewer(context, index);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImageSurface(image),
            if (_hasOverlayFor(image)) _buildReactionOverlay(image),
          ],
        ),
      ),
    );
  }

  /// ينفذ العملية `_buildImageSurface`.
  /// Runs the `_buildImageSurface` operation.
  Widget _buildImageSurface(Attachment image) {
    // 1) Prefer local file (while uploading or recently cached in entity)
    if (image.localFile != null && image.localFile!.existsSync()) {
      return Image.file(image.localFile!, fit: BoxFit.cover);
    }
    if (image.filePath.isNotEmpty) {
      final f = File(image.filePath);
      if (f.existsSync()) return Image.file(f, fit: BoxFit.cover);
    }

    // 2) Try local cached thumbnail from Hive
    return FutureBuilder<String?>(
      future: _loadLocalThumb(image.id),
      builder: (context, snap) {
        final p = snap.data;
        if (p != null && p.isNotEmpty && File(p).existsSync()) {
          return Image.file(File(p), fit: BoxFit.cover);
        }

        // 3) Server-provided thumbnailUrl
        if (image.thumbnailUrl != null && image.thumbnailUrl!.isNotEmpty) {
          return CachedImageWidget(
              imageUrl: image.thumbnailUrl!, fit: BoxFit.cover);
        }

        // 4) Fallback to full image URL
        return CachedImageWidget(imageUrl: image.fileUrl, fit: BoxFit.cover);
      },
    );
  }

  /// ينفذ العملية `_loadLocalThumb`.
  /// Runs the `_loadLocalThumb` operation.
  Future<String?> _loadLocalThumb(String attachmentId) async {
    try {
      final ds = sl<ChatLocalDataSource>();
      return await ds.getThumbnail('attachment_$attachmentId');
    } catch (_) {
      return null;
    }
  }

  /// ينفذ العملية `_hasOverlayFor`.
  /// Runs the `_hasOverlayFor` operation.
  bool _hasOverlayFor(Attachment image) {
    final map = reactionsByAttachment;
    if (map == null) return false;
    final r = map[image.id];
    return r != null && r.isNotEmpty;
  }

  /// ينفذ العملية `_buildReactionOverlay`.
  /// Runs the `_buildReactionOverlay` operation.
  Widget _buildReactionOverlay(Attachment image) {
    final type = reactionsByAttachment?[image.id] ?? '';
    final emoji = _emojiFor(type);
    return Positioned(
      right: 6,
      bottom: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.2), width: 0.5),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  /// ينفذ العملية `_emojiFor`.
  /// Runs the `_emojiFor` operation.
  String _emojiFor(String type) {
    switch (type) {
      case 'like':
        return '👍';
      case 'love':
        return '❤️';
      case 'laugh':
        return '😂';
      case 'wow':
        return '😮';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      default:
        return '👍';
    }
  }

  /// ينفذ العملية `_openImageViewer`.
  /// Runs the `_openImageViewer` operation.
  void _openImageViewer(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ExpandableImageViewer(
          images: images,
          initialIndex: initialIndex,
          onReaction: onReaction,
          onReply: onReply,
          initialReactionsByAttachment: reactionsByAttachment,
          onReactForAttachment: onReactForAttachment,
        ),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}
