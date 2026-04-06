import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

class ReviewVideoPlayerDialog extends StatefulWidget {
  final String videoUrl;

  const ReviewVideoPlayerDialog({
    super.key,
    required this.videoUrl,
  });

  @override
  State<ReviewVideoPlayerDialog> createState() =>
      _ReviewVideoPlayerDialogState();
}

class _ReviewVideoPlayerDialogState extends State<ReviewVideoPlayerDialog> {
  late final VideoPlayerController _controller;
  bool _isReady = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _isReady = true);
      }).catchError((Object error) {
        if (!mounted) return;
        setState(() => _error = error.toString());
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
      backgroundColor: AppTheme.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.tr('reviews.media.videoReview'),
                    style: AppTextStyles.h3.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
              child: AspectRatio(
                aspectRatio: _isReady ? _controller.value.aspectRatio : 16 / 9,
                child: _buildBody(context),
              ),
            ),
            if (_isReady) ...[
              const SizedBox(height: AppDimensions.spacingSm),
              VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: AppTheme.primaryBlue,
                  bufferedColor: AppTheme.primaryBlue.withOpacity(0.35),
                  backgroundColor: Colors.white.withOpacity(0.08),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                      setState(() {});
                    },
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      color: AppTheme.primaryBlue,
                      size: 34,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_error != null) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Text(
          context.tr('reviews.media.videoLoadFailed'),
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (!_isReady) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
        ),
      );
    }

    return VideoPlayer(_controller);
  }
}
