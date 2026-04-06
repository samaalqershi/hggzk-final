import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

class ReviewMediaDraft {
  final List<String> imagesBase64;
  final String? videoBase64;
  final String? videoThumbnailBase64;

  const ReviewMediaDraft({
    this.imagesBase64 = const [],
    this.videoBase64,
    this.videoThumbnailBase64,
  });
}

enum _ReviewMediaAction {
  galleryImages,
  cameraImage,
  galleryVideo,
  cameraVideo,
}

class ReviewMediaPickerWidget extends StatefulWidget {
  final ValueChanged<ReviewMediaDraft> onChanged;
  final int maxImages;

  const ReviewMediaPickerWidget({
    super.key,
    required this.onChanged,
    this.maxImages = 5,
  });

  @override
  State<ReviewMediaPickerWidget> createState() =>
      _ReviewMediaPickerWidgetState();
}

class _ReviewMediaPickerWidgetState extends State<ReviewMediaPickerWidget> {
  final ImagePicker _picker = ImagePicker();
  final List<_ReviewImageDraft> _images = [];

  String? _videoBase64;
  String? _videoThumbnailBase64;
  Uint8List? _videoThumbnailBytes;
  String? _videoName;
  bool _isProcessingVideo = false;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _panelColor => _isDark
      ? AppTheme.darkSurface.withValues(alpha: 0.94)
      : AppTheme.lightSurface;

  Color get _panelAltColor => _isDark
      ? AppTheme.darkCard.withValues(alpha: 0.88)
      : AppTheme.lightBackground;

  Color get _borderColor => _isDark
      ? AppTheme.darkBorder.withValues(alpha: 0.9)
      : AppTheme.lightBorder.withValues(alpha: 0.95);

  Color get _shadowColor => Colors.black.withValues(
        alpha: _isDark ? 0.22 : 0.06,
      );

  Color get _iconColor => _isDark ? AppTheme.textLight : AppTheme.textDark;

  Color get _softFill => _isDark
      ? Colors.white.withValues(alpha: 0.04)
      : Colors.black.withValues(alpha: 0.025);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: AppDimensions.spacingMd),
        if (_images.isEmpty && _videoBase64 == null)
          _buildEmptyState()
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_images.isNotEmpty) _buildImagesStrip(),
              if (_images.isNotEmpty && _videoBase64 != null)
                const SizedBox(height: AppDimensions.spacingSm),
              if (_videoBase64 != null) _buildVideoCard(),
              const SizedBox(height: AppDimensions.spacingSm),
              _buildActionsRow(),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                context.tr(
                  'reviews.media.imagesCount',
                  params: {
                    'count': '${_images.length}',
                    'max': '${widget.maxImages}',
                  },
                ),
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('reviews.mediaSectionTitle'),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      AppTheme.textMuted.withValues(alpha: 0.45),
                      AppTheme.textMuted.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('reviews.mediaSectionHint'),
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _panelColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: _borderColor,
              width: 0.8,
            ),
          ),
          child: Icon(
            Icons.perm_media_rounded,
            size: 16,
            color: _iconColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: _showPickerSheet,
      child: Container(
        height: 122,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_panelColor, _panelAltColor],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
          border: Border.all(
            color: _borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _shadowColor,
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _softFill,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _shadowColor,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 22,
                  color: _iconColor,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                context.tr('reviews.mediaTapToAdd'),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                context.tr('reviews.mediaTapToAddHint'),
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagesStrip() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppDimensions.spacingSm),
        itemBuilder: (context, index) {
          final item = _images[index];
          return Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _panelAltColor,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusMd,
                  ),
                  border: Border.all(
                    color: _borderColor,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _shadowColor,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  image: DecorationImage(
                    image: FileImage(File(item.path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: _buildRemoveButton(
                  onTap: () {
                    setState(() => _images.removeAt(index));
                    _emitChange();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVideoCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _panelColor,
            _panelAltColor,
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        border: Border.all(
          color: _borderColor,
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 116,
                      height: 78,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusMd,
                        ),
                        image: _videoThumbnailBytes != null
                            ? DecorationImage(
                                image: MemoryImage(_videoThumbnailBytes!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        gradient: _videoThumbnailBytes == null
                            ? LinearGradient(
                                colors: [
                                  Colors.black.withValues(
                                    alpha: _isDark ? 0.22 : 0.08,
                                  ),
                                  Colors.black.withValues(
                                    alpha: _isDark ? 0.1 : 0.03,
                                  ),
                                ],
                              )
                            : null,
                      ),
                      child: _videoThumbnailBytes == null
                          ? Icon(
                              Icons.videocam_rounded,
                              color: Colors.white.withOpacity(0.9),
                              size: 28,
                            )
                          : null,
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('reviews.media.videoReview'),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _videoName ?? context.tr('reviews.media.videoSelected'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.textMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                _buildRemoveButton(
                  onTap: () {
                    setState(() {
                      _videoBase64 = null;
                      _videoThumbnailBase64 = null;
                      _videoThumbnailBytes = null;
                      _videoName = null;
                    });
                    _emitChange();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildActionChip(
            icon: Icons.add_photo_alternate_outlined,
            label: context.tr('reviews.media.addPhotos'),
            onTap: _images.length >= widget.maxImages
                ? () => _showInfo(context.tr('reviews.media.maxImagesReached'))
                : _pickGalleryImages,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        Expanded(
          child: _buildActionChip(
            icon: Icons.videocam_outlined,
            label: context.tr('reviews.media.addVideo'),
            onTap: _videoBase64 != null
                ? () => _showInfo(context.tr('reviews.media.onlyOneVideo'))
                : _pickVideoFromGallery,
            isLoading: _isProcessingVideo,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        GestureDetector(
          onTap: _showPickerSheet,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _panelColor,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
              border: Border.all(
                color: _borderColor,
                width: 0.8,
              ),
            ),
            child: Icon(
              Icons.more_horiz_rounded,
              color: _iconColor,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: _panelColor,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
          border: Border.all(
            color: _borderColor,
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: _shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _iconColor,
                  ),
                ),
              )
            else
              Icon(
                icon,
                color: _iconColor,
                size: 18,
              ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoveButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close,
          size: 16,
          color: AppTheme.textWhite,
        ),
      ),
    );
  }

  Future<void> _showPickerSheet() async {
    final action = await showModalBottomSheet<_ReviewMediaAction>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadiusLg),
        ),
      ),
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildPickerOption(
                icon: Icons.photo_library_outlined,
                label: context.tr('reviews.media.galleryImages'),
                onTap: () {
                  Navigator.pop(context, _ReviewMediaAction.galleryImages);
                },
              ),
              _buildPickerOption(
                icon: Icons.camera_alt_outlined,
                label: context.tr('reviews.media.cameraImage'),
                onTap: () {
                  Navigator.pop(context, _ReviewMediaAction.cameraImage);
                },
              ),
              _buildPickerOption(
                icon: Icons.video_library_outlined,
                label: context.tr('reviews.media.galleryVideo'),
                onTap: () {
                  Navigator.pop(context, _ReviewMediaAction.galleryVideo);
                },
              ),
              _buildPickerOption(
                icon: Icons.videocam_outlined,
                label: context.tr('reviews.media.cameraVideo'),
                onTap: () {
                  Navigator.pop(context, _ReviewMediaAction.cameraVideo);
                },
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || action == null) return;

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    switch (action) {
      case _ReviewMediaAction.galleryImages:
        await _pickGalleryImages();
        break;
      case _ReviewMediaAction.cameraImage:
        await _pickCameraImage();
        break;
      case _ReviewMediaAction.galleryVideo:
        await _pickVideoFromGallery();
        break;
      case _ReviewMediaAction.cameraVideo:
        await _pickVideoFromCamera();
        break;
    }
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: _iconColor),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.textWhite,
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _pickGalleryImages() async {
    final hasPermission = await _ensureMediaPermission(ImageSource.gallery);
    if (!hasPermission) return;

    final remaining = widget.maxImages - _images.length;
    if (remaining <= 0) {
      _showInfo(context.tr('reviews.media.maxImagesReached'));
      return;
    }

    final picked = await _picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (picked.isEmpty) return;

    final limited = picked.take(remaining).toList();
    for (final file in limited) {
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      if (bytes.length > 5 * 1024 * 1024) {
        _showInfo(context.tr('reviews.media.imageTooLarge'));
        continue;
      }
      _images.add(
        _ReviewImageDraft(
          path: file.path,
          base64: _encodeBytes(
            bytes,
            _guessMimeType(file.path, fallback: 'image/jpeg'),
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {});
      _emitChange();
    }
  }

  Future<void> _pickCameraImage() async {
    final hasPermission = await _ensureMediaPermission(ImageSource.camera);
    if (!hasPermission) return;

    if (_images.length >= widget.maxImages) {
      _showInfo(context.tr('reviews.media.maxImagesReached'));
      return;
    }

    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    if (bytes.length > 5 * 1024 * 1024) {
      _showInfo(context.tr('reviews.media.imageTooLarge'));
      return;
    }

    setState(() {
      _images.add(
        _ReviewImageDraft(
          path: picked.path,
          base64: _encodeBytes(
            bytes,
            _guessMimeType(picked.path, fallback: 'image/jpeg'),
          ),
        ),
      );
    });
    _emitChange();
  }

  Future<void> _pickVideoFromGallery() async {
    await _pickVideo(ImageSource.gallery);
  }

  Future<void> _pickVideoFromCamera() async {
    await _pickVideo(ImageSource.camera);
  }

  Future<void> _pickVideo(ImageSource source) async {
    final hasPermission = await _ensureMediaPermission(source);
    if (!hasPermission) return;

    if (_videoBase64 != null) {
      _showInfo(context.tr('reviews.media.onlyOneVideo'));
      return;
    }

    final picked = await _picker.pickVideo(
      source: source,
      maxDuration: const Duration(seconds: 45),
    );
    if (picked == null) return;

    setState(() => _isProcessingVideo = true);

    try {
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      if (bytes.length > 25 * 1024 * 1024) {
        _showInfo(context.tr('reviews.media.videoTooLarge'));
        return;
      }

      final thumbnail = await VideoThumbnail.thumbnailData(
        video: picked.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 512,
        quality: 70,
      );
      if (!mounted) return;

      setState(() {
        _videoBase64 = _encodeBytes(
          bytes,
          _guessMimeType(picked.path, fallback: 'video/mp4'),
        );
        _videoThumbnailBytes = thumbnail;
        _videoThumbnailBase64 =
            thumbnail == null ? null : _encodeBytes(thumbnail, 'image/jpeg');
        _videoName = picked.name;
      });
      _emitChange();
    } finally {
      if (mounted) {
        setState(() => _isProcessingVideo = false);
      }
    }
  }

  void _emitChange() {
    widget.onChanged(
      ReviewMediaDraft(
        imagesBase64: _images.map((item) => item.base64).toList(),
        videoBase64: _videoBase64,
        videoThumbnailBase64: _videoThumbnailBase64,
      ),
    );
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _ensureMediaPermission(ImageSource source) async {
    final PermissionStatus status;

    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else if (Platform.isIOS) {
      status = await Permission.photos.request();
    } else {
      return true;
    }

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (!mounted) return false;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('auth.upload.permissionMessage')),
        behavior: SnackBarBehavior.floating,
        action: status.isPermanentlyDenied || status.isRestricted
            ? SnackBarAction(
                label: context.tr('common.settings'),
                onPressed: openAppSettings,
              )
            : null,
      ),
    );
    return false;
  }

  String _encodeBytes(Uint8List bytes, String mimeType) {
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
  }

  String _guessMimeType(String path, {required String fallback}) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.webm')) return 'video/webm';
    if (lower.endsWith('.mkv')) return 'video/x-matroska';
    return fallback;
  }
}

class _ReviewImageDraft {
  final String path;
  final String base64;

  const _ReviewImageDraft({
    required this.path,
    required this.base64,
  });
}
