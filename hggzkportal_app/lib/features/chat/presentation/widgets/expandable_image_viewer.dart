import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:io';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../domain/entities/attachment.dart';
import 'reaction_picker_widget.dart';

/// يعرّف الكلاس `ExpandableImageViewer`.
/// Describes the `ExpandableImageViewer` class.
class ExpandableImageViewer extends StatefulWidget {
  /// Holds the `images` value.
  /// العربية: يخزن القيمة `images`.
  final List<Attachment> images;

  /// يخزن العضو `initialIndex`.
  /// Holds the `initialIndex` member.
  final int initialIndex;

  /// ينفذ العملية `Function`.
  /// Runs the `Function` operation.
  final Function(String)? onReaction; // message-level reaction
  /// ينفذ العملية `Function`.
  /// Runs the `Function` operation.
  final void Function(Attachment)? onReply;
  // Optional: initial reactions by attachment id to render overlay per image
  /// يخزن العضو `initialReactionsByAttachment`.
  /// Holds the `initialReactionsByAttachment` member.
  final Map<String, String>? initialReactionsByAttachment;
  // Optional: per-attachment reaction callback to sync overlay with parent
  /// ينفذ العملية `Function`.
  /// Runs the `Function` operation.
  final void Function(Attachment, String)? onReactForAttachment;

  /// ينشئ مثيلاً من `ExpandableImageViewer`.
  /// Builds an instance of `ExpandableImageViewer`.
  const ExpandableImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.onReaction,
    this.onReply,
    this.initialReactionsByAttachment,
    this.onReactForAttachment,
  });

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<ExpandableImageViewer> createState() => _ExpandableImageViewerState();
}

/// يعرّف الكلاس `_ExpandableImageViewerState`.
/// Describes the `_ExpandableImageViewerState` class.
class _ExpandableImageViewerState extends State<ExpandableImageViewer> {
  /// Holds the `currentIndex` value.
  /// العربية: يخزن القيمة `currentIndex`.
  late int _currentIndex;

  /// يخزن العضو `_pageController`.
  /// Holds the `_pageController` member.
  late final PageController _pageController;

  /// يخزن العضو `_imageReactions`.
  /// Holds the `_imageReactions` member.
  final Map<String, String> _imageReactions = {};

  /// يخزن العضو `_showReactionPicker`.
  /// Holds the `_showReactionPicker` member.
  bool _showReactionPicker = false;

  /// ينفذ العملية `initState`.
  /// Runs the `initState` operation.
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
    // Seed with initial per-attachment reactions if provided
    if (widget.initialReactionsByAttachment != null) {
      _imageReactions.addAll(widget.initialReactionsByAttachment!);
    }
  }

  /// ينفذ العملية `_buildPhotoChild`.
  /// Runs the `_buildPhotoChild` operation.
  Widget _buildPhotoChild(Attachment image) {
    if (image.filePath.isNotEmpty) {
      final f = File(image.filePath);
      if (f.existsSync()) return Image.file(f, fit: BoxFit.contain);
    }
    return CachedImageWidget(imageUrl: image.fileUrl, fit: BoxFit.contain);
  }

  /// ينفذ العملية `dispose`.
  /// Runs the `dispose` operation.
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onDoubleTap: () {
              final current = widget.images[_currentIndex];
              setState(() {
                _imageReactions[current.id] = 'like';
              });
              // message-level reaction
              widget.onReaction?.call('like');
              // per-attachment overlay sync
              widget.onReactForAttachment?.call(current, 'like');
            },
            onLongPress: () {
              HapticFeedback.lightImpact();
              _showImageOptions();
            },
            child: PhotoViewGallery.builder(
              pageController: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              builder: (context, index) {
                final image = widget.images[index];
                return PhotoViewGalleryPageOptions.customChild(
                  child: _buildPhotoChild(image),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3.0,
                  heroAttributes: PhotoViewHeroAttributes(tag: image.id),
                );
              },
              loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
          ),
          // Per-image reaction overlay (elegant, clear, appropriate size)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 0,
            right: 0,
            child: _buildReactionOverlay(),
          ),

          // Reaction Picker Widget - ظاهر دائماً
          if (_showReactionPicker)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 80,
              left: 0,
              right: 0,
              child: Center(
                child: ReactionPickerWidget(
                  onReaction: (reaction) {
                    final current = widget.images[_currentIndex];
                    setState(() {
                      _imageReactions[current.id] = reaction;
                      _showReactionPicker = false;
                    });
                    // message-level reaction
                    widget.onReaction?.call(reaction);
                    // per-attachment overlay sync
                    widget.onReactForAttachment?.call(current, reaction);
                  },
                ),
              ),
            ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentIndex + 1}/${widget.images.length}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),

          // زر إظهار الريآكشنات
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _showReactionPicker = !_showReactionPicker;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _showReactionPicker
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  _showReactionPicker ? Icons.close : Icons.favorite_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ينفذ العملية `_showImageOptions`.
  /// Runs the `_showImageOptions` operation.
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _ImageViewerOptionsSheet(
          onReact: (type) {
            final current = widget.images[_currentIndex];
            setState(() {
              _imageReactions[current.id] = type;
            });
            // message-level reaction
            widget.onReaction?.call(type);
            // per-attachment overlay sync back to parent grid/bubble
            widget.onReactForAttachment?.call(current, type);
          },
          onReply: widget.onReply,
          parentNavigatorContext: context,
          currentAttachment: widget.images[_currentIndex],
        );
      },
    );
  }

  /// ينفذ العملية `_buildReactionOverlay`.
  /// Runs the `_buildReactionOverlay` operation.
  Widget _buildReactionOverlay() {
    if (widget.images.isEmpty) return const SizedBox.shrink();
    final current = widget.images[_currentIndex];
    final reaction = _imageReactions[current.id];
    if (reaction == null) return const SizedBox.shrink();

    final emoji = _emojiForReaction(reaction);
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 0.5,
              ),
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
      ),
    );
  }

  /// ينفذ العملية `_emojiForReaction`.
  /// Runs the `_emojiForReaction` operation.
  String _emojiForReaction(String type) {
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
}

/// يعرّف الكلاس `_ImageViewerOptionsSheet`.
/// Describes the `_ImageViewerOptionsSheet` class.
class _ImageViewerOptionsSheet extends StatelessWidget {
  /// Receives `Function`.
  /// العربية: يعالج `Function`.
  final void Function(String) onReact;

  /// ينفذ العملية `Function`.
  /// Runs the `Function` operation.
  final void Function(Attachment)? onReply;

  /// يخزن العضو `parentNavigatorContext`.
  /// Holds the `parentNavigatorContext` member.
  final BuildContext parentNavigatorContext;

  /// يخزن العضو `currentAttachment`.
  /// Holds the `currentAttachment` member.
  final Attachment currentAttachment;

  /// ينشئ مثيلاً من `_ImageViewerOptionsSheet`.
  /// Builds an instance of `_ImageViewerOptionsSheet`.
  const _ImageViewerOptionsSheet({
    required this.onReact,
    this.onReply,
    required this.parentNavigatorContext,
    required this.currentAttachment,
  });

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _reactionChip(context, '👍', 'like', onReact),
              _reactionChip(context, '❤️', 'love', onReact),
              _reactionChip(context, '😂', 'laugh', onReact),
              _reactionChip(context, '😮', 'wow', onReact),
              _reactionChip(context, '😢', 'sad', onReact),
              _reactionChip(context, '😠', 'angry', onReact),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onReply != null)
                  _actionTile(context, Icons.reply_rounded, 'رد', () {
                    // Close the options sheet first
                    Navigator.pop(context);
                    // Then close the viewer page
                    Navigator.pop(parentNavigatorContext);
                    // Finally notify parent to set reply and focus input
                    onReply!(currentAttachment);
                  }),
                _actionTile(context, Icons.download_rounded, 'حفظ', () {
                  Navigator.pop(context);
                }),
                _actionTile(context, Icons.share_rounded, 'مشاركة', () {
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// ينفذ العملية `_reactionChip`.
  /// Runs the `_reactionChip` operation.
  Widget _reactionChip(
    BuildContext context,
    String emoji,
    String type,
    void Function(String) onReact,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.pop(context);
          onReact(type);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 22)),
        ),
      ),
    );
  }

  /// ينفذ العملية `_actionTile`.
  /// Runs the `_actionTile` operation.
  Widget _actionTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white.withValues(alpha: 0.9)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
    );
  }
}

// No global key needed; we use the bottom sheet context to pop
