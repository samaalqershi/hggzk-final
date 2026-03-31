import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../app/dependency_injection/injection_container.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/attachment.dart';

class ChatMediaViewerPage extends StatefulWidget {
  final List<Attachment> attachments;
  final int initialIndex;

  const ChatMediaViewerPage({
    super.key,
    required this.attachments,
    this.initialIndex = 0,
  });

  @override
  State<ChatMediaViewerPage> createState() => _ChatMediaViewerPageState();
}

class _ChatMediaViewerPageState extends State<ChatMediaViewerPage> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.attachments.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attachments = widget.attachments;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: attachments.length,
              onPageChanged: (index) {
                if (!mounted) return;
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final attachment = attachments[index];
                if (attachment.isVideo) {
                  return _ChatVideoViewer(
                    attachment: attachment,
                    headers: _buildHeaders(),
                  );
                }

                if (attachment.isImage) {
                  return _ChatImageViewer(
                    attachment: attachment,
                    headers: _buildHeaders(),
                  );
                }

                return Center(
                  child: Icon(
                    Icons.insert_drive_file_rounded,
                    size: 72,
                    color: Colors.white.withOpacity(0.8),
                  ),
                );
              },
            ),
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${attachments.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String>? _buildHeaders() {
    final token = sl<LocalStorageService>()
        .getData(StorageConstants.accessToken) as String?;
    if (token == null || token.isEmpty) {
      return null;
    }

    return {
      'Authorization': 'Bearer $token',
    };
  }
}

class _ChatImageViewer extends StatelessWidget {
  final Attachment attachment;
  final Map<String, String>? headers;

  const _ChatImageViewer({
    required this.attachment,
    required this.headers,
  });

  @override
  Widget build(BuildContext context) {
    final localPath = attachment.filePath.trim();
    final localFile = localPath.isNotEmpty ? File(localPath) : null;
    final hasLocal = localFile != null && localFile.existsSync();

    return InteractiveViewer(
      minScale: 0.8,
      maxScale: 4,
      child: Center(
        child: hasLocal
            ? Image.file(localFile, fit: BoxFit.contain)
            : Image.network(
                _resolveMediaUrl(attachment.fileUrl),
                headers: headers,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.broken_image_rounded,
                    size: 72,
                    color: Colors.white.withOpacity(0.7),
                  );
                },
              ),
      ),
    );
  }
}

class _ChatVideoViewer extends StatefulWidget {
  final Attachment attachment;
  final Map<String, String>? headers;

  const _ChatVideoViewer({
    required this.attachment,
    required this.headers,
  });

  @override
  State<_ChatVideoViewer> createState() => _ChatVideoViewerState();
}

class _ChatVideoViewerState extends State<_ChatVideoViewer> {
  VideoPlayerController? _controller;
  Future<void>? _initializeFuture;
  bool _showControls = true;
  String? _cachedVideoPath;
  Timer? _controlsHideTimer;
  bool _isMuted = false;
  bool _isScrubbing = false;
  bool _wasPlayingBeforeScrubbing = false;
  double _playbackSpeed = 1.0;
  BoxFit _videoFit = BoxFit.contain;
  String? _seekFeedbackLabel;
  Alignment _seekFeedbackAlignment = Alignment.center;

  @override
  void initState() {
    super.initState();
    _initializeFuture = _initializeController();
  }

  @override
  void dispose() {
    _controlsHideTimer?.cancel();
    _controller?.removeListener(_onVideoStateChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _toggleControlsVisibility();
      },
      child: Center(
        child: FutureBuilder<void>(
          future: _initializeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator(
                color: Colors.white,
              );
            }

            if (snapshot.hasError ||
                _controller == null ||
                !_controller!.value.isInitialized) {
              return Icon(
                Icons.video_file_rounded,
                size: 72,
                color: Colors.white.withOpacity(0.7),
              );
            }

            final controller = _controller!;
            final videoSize = controller.value.size;
            final hasVideoSize = videoSize.width > 0 && videoSize.height > 0;

            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black,
                    child: Center(
                      child: hasVideoSize
                          ? FittedBox(
                              fit: _videoFit,
                              child: SizedBox(
                                width: videoSize.width,
                                height: videoSize.height,
                                child: VideoPlayer(controller),
                              ),
                            )
                          : AspectRatio(
                              aspectRatio: controller.value.aspectRatio == 0
                                  ? 16 / 9
                                  : controller.value.aspectRatio,
                              child: VideoPlayer(controller),
                            ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onDoubleTap: () =>
                              _seekBy(const Duration(seconds: -10)),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onDoubleTap: () =>
                              _seekBy(const Duration(seconds: 10)),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _showControls ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !_showControls,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.28),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.46),
                                ],
                                stops: const [0, 0.45, 1],
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.36),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: _togglePlayback,
                              iconSize: 72,
                              icon: Icon(
                                controller.value.isPlaying
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.play_circle_fill_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 18,
                          child: _buildControlsCard(controller),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_seekFeedbackLabel != null)
                  Align(
                    alignment: _seekFeedbackAlignment,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 28),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.52),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.14),
                        ),
                      ),
                      child: Text(
                        _seekFeedbackLabel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                if (controller.value.isBuffering)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.36),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _initializeController() async {
    final controller = await _createController();
    _controller = controller;
    await controller.initialize();
    await controller.setLooping(false);
    await controller.setPlaybackSpeed(_playbackSpeed);
    controller.addListener(_onVideoStateChanged);
    if (!mounted) return;
    _restartControlsTimer();
    setState(() {});
  }

  Future<VideoPlayerController> _createController() async {
    final localPath = widget.attachment.filePath.trim();
    if (localPath.isNotEmpty) {
      final file = File(localPath);
      if (file.existsSync()) {
        return VideoPlayerController.file(file);
      }
    }

    final cachedPath = await _ensureRemoteVideoCached();
    return VideoPlayerController.file(File(cachedPath));
  }

  void _onVideoStateChanged() {
    if (!mounted || _controller == null) return;

    final value = _controller!.value;
    if (value.isInitialized &&
        value.duration > Duration.zero &&
        value.position >= value.duration &&
        !value.isPlaying) {
      _controller!.seekTo(Duration.zero);
    }

    if (value.isPlaying && !_isScrubbing) {
      _restartControlsTimer();
    }

    setState(() {});
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
      _showControlsPermanently();
      return;
    }

    if (controller.value.position >= controller.value.duration &&
        controller.value.duration > Duration.zero) {
      controller.seekTo(Duration.zero);
    }
    controller.play();
    _restartControlsTimer();
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      final remainingMinutes = minutes % 60;
      return '$hours:${remainingMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildControlsCard(VideoPlayerController controller) {
    final duration = controller.value.duration;
    final position =
        controller.value.position > duration && duration > Duration.zero
            ? duration
            : controller.value.position;
    final maxMillis =
        duration.inMilliseconds <= 0 ? 1.0 : duration.inMilliseconds.toDouble();
    final positionMillis = position.inMilliseconds.clamp(0, maxMillis.toInt());

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.48),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3.5,
              activeTrackColor: AppTheme.primaryBlue,
              inactiveTrackColor: Colors.white.withOpacity(0.18),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.14),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              min: 0,
              max: maxMillis,
              value: positionMillis.toDouble(),
              onChangeStart: (_) {
                _isScrubbing = true;
                _wasPlayingBeforeScrubbing = controller.value.isPlaying;
                if (_wasPlayingBeforeScrubbing) {
                  controller.pause();
                }
                _showControlsPermanently();
              },
              onChanged: (value) {
                controller.seekTo(Duration(milliseconds: value.round()));
              },
              onChangeEnd: (value) {
                controller.seekTo(Duration(milliseconds: value.round()));
                _isScrubbing = false;
                if (_wasPlayingBeforeScrubbing) {
                  controller.play();
                }
                _restartControlsTimer();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 8),
            child: Row(
              children: [
                Text(
                  _formatDuration(position),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '-${_formatDuration(duration > position ? duration - position : Duration.zero)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 380;

              if (isCompact) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildPlaybackControls(controller),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildUtilityControls(),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  ..._buildPlaybackControls(controller),
                  const Spacer(),
                  ..._buildUtilityControls(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPlaybackControls(VideoPlayerController controller) {
    return [
      _buildIconControl(
        icon: Icons.replay_10_rounded,
        tooltip: 'رجوع 10 ثوان',
        onPressed: () => _seekBy(const Duration(seconds: -10)),
      ),
      _buildIconControl(
        icon: controller.value.isPlaying
            ? Icons.pause_rounded
            : Icons.play_arrow_rounded,
        tooltip: controller.value.isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
        onPressed: _togglePlayback,
        emphasize: true,
      ),
      _buildIconControl(
        icon: Icons.forward_10_rounded,
        tooltip: 'تقديم 10 ثوان',
        onPressed: () => _seekBy(const Duration(seconds: 10)),
      ),
    ];
  }

  List<Widget> _buildUtilityControls() {
    return [
      _buildIconControl(
        icon: _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
        tooltip: _isMuted ? 'إلغاء الكتم' : 'كتم الصوت',
        onPressed: _toggleMute,
      ),
      PopupMenuButton<double>(
        initialValue: _playbackSpeed,
        tooltip: 'سرعة التشغيل',
        color: const Color(0xFF161616),
        onSelected: _setPlaybackSpeed,
        itemBuilder: (context) {
          const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
          return speeds
              .map(
                (speed) => PopupMenuItem<double>(
                  value: speed,
                  child: Text(
                    '${speed.toStringAsFixed(speed.truncateToDouble() == speed ? 0 : 2)}x',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
              .toList();
        },
        child: _buildChipControl(
          label: '${_formatSpeed(_playbackSpeed)}x',
          icon: Icons.speed_rounded,
        ),
      ),
      const SizedBox(width: 8),
      _buildIconControl(
        icon: _videoFit == BoxFit.contain
            ? Icons.fit_screen_rounded
            : Icons.crop_free_rounded,
        tooltip: _videoFit == BoxFit.contain ? 'ملء الشاشة' : 'احتواء',
        onPressed: _toggleVideoFit,
      ),
    ];
  }

  Widget _buildIconControl({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool emphasize = false,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: () {
        onPressed();
        _restartControlsTimer();
      },
      icon: Icon(
        icon,
        color: Colors.white,
        size: emphasize ? 30 : 24,
      ),
      style: IconButton.styleFrom(
        backgroundColor:
            emphasize ? Colors.white.withOpacity(0.12) : Colors.transparent,
      ),
    );
  }

  Widget _buildChipControl({
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _seekBy(Duration delta) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final duration = controller.value.duration;
    final nextPosition = controller.value.position + delta;
    final boundedPosition = nextPosition < Duration.zero
        ? Duration.zero
        : (duration > Duration.zero && nextPosition > duration
            ? duration
            : nextPosition);

    controller.seekTo(boundedPosition);
    _flashSeekFeedback(
      delta.isNegative
          ? '-${delta.inSeconds.abs()} ثوان'
          : '+${delta.inSeconds} ثوان',
      alignment:
          delta.isNegative ? Alignment.centerLeft : Alignment.centerRight,
    );
    _restartControlsTimer();
  }

  void _toggleMute() {
    final controller = _controller;
    if (controller == null) return;

    final nextMuted = !_isMuted;
    controller.setVolume(nextMuted ? 0 : 1);
    setState(() {
      _isMuted = nextMuted;
    });
  }

  void _setPlaybackSpeed(double speed) {
    final controller = _controller;
    if (controller == null) return;

    controller.setPlaybackSpeed(speed);
    setState(() {
      _playbackSpeed = speed;
    });
    _flashSeekFeedback('${_formatSpeed(speed)}x',
        alignment: Alignment.topCenter);
    _restartControlsTimer();
  }

  void _toggleVideoFit() {
    setState(() {
      _videoFit = _videoFit == BoxFit.contain ? BoxFit.cover : BoxFit.contain;
    });
    _flashSeekFeedback(
      _videoFit == BoxFit.contain ? 'احتواء' : 'ملء',
      alignment: Alignment.topCenter,
    );
    _restartControlsTimer();
  }

  String _formatSpeed(double speed) {
    if (speed.truncateToDouble() == speed) {
      return speed.toStringAsFixed(0);
    }
    return speed.toStringAsFixed(speed == 0.75 || speed == 1.25 ? 2 : 1);
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _restartControlsTimer();
    } else {
      _controlsHideTimer?.cancel();
    }
  }

  void _showControlsPermanently() {
    _controlsHideTimer?.cancel();
    if (!_showControls && mounted) {
      setState(() {
        _showControls = true;
      });
    }
  }

  void _restartControlsTimer() {
    final controller = _controller;
    _controlsHideTimer?.cancel();
    if (!mounted || controller == null || !controller.value.isPlaying) {
      return;
    }

    _controlsHideTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted || _isScrubbing || !_controller!.value.isPlaying) {
        return;
      }
      setState(() {
        _showControls = false;
      });
    });
  }

  void _flashSeekFeedback(String label, {required Alignment alignment}) {
    if (!mounted) return;

    setState(() {
      _seekFeedbackLabel = label;
      _seekFeedbackAlignment = alignment;
      _showControls = true;
    });

    Future<void>.delayed(const Duration(milliseconds: 850), () {
      if (!mounted || _seekFeedbackLabel != label) return;
      setState(() {
        _seekFeedbackLabel = null;
      });
    });
  }

  Future<String> _ensureRemoteVideoCached() async {
    final existingPath = _cachedVideoPath;
    if (existingPath != null && File(existingPath).existsSync()) {
      return existingPath;
    }

    final extension = widget.attachment.fileExtension.isNotEmpty
        ? widget.attachment.fileExtension
        : 'mp4';
    final targetPath =
        '${Directory.systemTemp.path}/chat_viewer_${widget.attachment.id}.$extension';
    final targetFile = File(targetPath);
    if (targetFile.existsSync()) {
      _cachedVideoPath = targetPath;
      return targetPath;
    }

    final resolvedUrl = _resolveMediaUrl(widget.attachment.fileUrl);
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(resolvedUrl));
      widget.headers?.forEach(request.headers.add);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Video download failed with status ${response.statusCode}',
          uri: Uri.parse(resolvedUrl),
        );
      }

      final bytes = await consolidateHttpClientResponseBytes(response);
      await targetFile.writeAsBytes(bytes, flush: true);
      _cachedVideoPath = targetPath;
      return targetPath;
    } finally {
      client.close(force: true);
    }
  }
}

String _resolveMediaUrl(String fileUrl) {
  if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
    return fileUrl;
  }

  final base = ApiConstants.imageBaseUrl;
  if (fileUrl.startsWith('/')) {
    return '$base$fileUrl';
  }
  return '$base/$fileUrl';
}
