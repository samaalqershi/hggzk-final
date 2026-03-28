import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../domain/entities/message.dart';

/// Grid of visual chat attachments that lets the user open images or videos
/// from the conversation media gallery.
/// شبكة لمرفقات الدردشة المرئية تتيح فتح الصور أو الفيديوهات من معرض
/// وسائط المحادثة.
class MediaGridWidget extends StatelessWidget {
  /// Messages that contain image or video attachments to display.
  /// الرسائل التي تحتوي على مرفقات صور أو فيديو لعرضها.
  final List<Message> messages;

  /// Called when the user taps one of the media tiles.
  /// يُستدعى عند النقر على إحدى بطاقات الوسائط.
  final Function(Message) onMediaTap;

  /// Builds the compact attachment gallery for a chat thread.
  /// ينشئ معرض المرفقات المضغوط لسلسلة المحادثة.
  const MediaGridWidget({
    super.key,
    required this.messages,
    required this.onMediaTap,
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
      itemCount: messages.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final message = messages[index];
        return _MediaItem(
          message: message,
          index: index,
          onTap: () => onMediaTap(message),
        );
      },
    );
  }
}

/// Single tile inside the media gallery.
/// بطاقة منفصلة داخل معرض الوسائط.
class _MediaItem extends StatefulWidget {
  /// Message whose attachment is represented by this tile.
  /// الرسالة التي تمثل مرفقها هذه البطاقة.
  final Message message;

  /// Tile index used to stagger the entrance animation.
  /// فهرس البطاقة المستخدم لتدرّج حركة الظهور.
  final int index;

  /// Called when the user opens the attachment preview.
  /// يُستدعى عند فتح معاينة المرفق.
  final VoidCallback onTap;

  /// Builds one animated media thumbnail.
  /// ينشئ صورة مصغرة متحركة واحدة للوسائط.
  const _MediaItem({
    required this.message,
    required this.index,
    required this.onTap,
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
    String? imageUrl;
    bool isVideo = false;

    if (widget.message.messageType == 'image' &&
        widget.message.attachments.isNotEmpty) {
      imageUrl = widget.message.attachments.first.fileUrl;
    } else if (widget.message.messageType == 'video' &&
        widget.message.attachments.isNotEmpty) {
      imageUrl = widget.message.attachments.first.thumbnailUrl;
      isVideo = true;
    }

    if (imageUrl == null) return const SizedBox.shrink();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
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
                  CachedImageWidget(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
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
}
