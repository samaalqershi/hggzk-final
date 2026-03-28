// lib/features/profile/presentation/widgets/upload_user_image.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image_widget.dart';

/// يعرّف الكلاس `UploadUserImage`.
/// Describes the `UploadUserImage` class.
class UploadUserImage extends StatefulWidget {
  /// Holds the `currentImageUrl` value.
  /// العربية: يخزن القيمة `currentImageUrl`.
  final String? currentImageUrl;

  /// ينفذ العملية `Function`.
  /// Runs the `Function` operation.
  final Function(String imagePath) onImageSelected;

  /// يخزن العضو `size`.
  /// Holds the `size` member.
  final double size;

  /// يخزن العضو `enabled`.
  /// Holds the `enabled` member.
  final bool enabled;

  /// ينشئ مثيلاً من `UploadUserImage`.
  /// Builds an instance of `UploadUserImage`.
  const UploadUserImage({
    super.key,
    this.currentImageUrl,
    required this.onImageSelected,
    this.size = 90, // Reduced from 120
    this.enabled = true,
  });

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<UploadUserImage> createState() => _UploadUserImageState();
}

/// يعرّف الكلاس `_UploadUserImageState`.
/// Describes the `_UploadUserImageState` class.
class _UploadUserImageState extends State<UploadUserImage>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  /// يخزن العضو `_selectedImage`.
  /// Holds the `_selectedImage` member.
  File? _selectedImage;

  /// يخزن العضو `_isLoading`.
  /// Holds the `_isLoading` member.
  bool _isLoading = false;

  /// يخزن العضو `_pulseController`.
  /// Holds the `_pulseController` member.
  late AnimationController _pulseController;

  /// يخزن العضو `_rotateController`.
  /// Holds the `_rotateController` member.
  late AnimationController _rotateController;

  /// ينفذ العملية `initState`.
  /// Runs the `initState` operation.
  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 10), // Faster rotation
      vsync: this,
    )..repeat();
  }

  /// ينفذ العملية `dispose`.
  /// Runs the `dispose` operation.
  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? _showImageSourceDialog : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Simple static avatar border - thin and without animation
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.darkCard.withValues(alpha: 0.8),
              border: Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                width: 1.0,
              ),
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildUltraMinimalImageContent(),
                  if (_isLoading) _buildLoadingOverlay(),
                ],
              ),
            ),
          ),

          // Simple static camera badge
          if (widget.enabled)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.85),
                      AppTheme.primaryPurple.withValues(alpha: 0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.darkBackground,
                    width: 1.0,
                  ),
                ),
                child: Icon(
                  _isLoading ? Icons.hourglass_empty : Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// ينفذ العملية `_buildUltraMinimalImageContent`.
  /// Runs the `_buildUltraMinimalImageContent` operation.
  Widget _buildUltraMinimalImageContent() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
      );
    } else if (widget.currentImageUrl != null &&
        widget.currentImageUrl!.isNotEmpty) {
      return CachedImageWidget(
        imageUrl: widget.currentImageUrl!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.darkCard.withValues(alpha: 0.3),
              AppTheme.darkCard.withValues(alpha: 0.2),
            ],
          ),
        ),
        child: Icon(
          Icons.person_outline_rounded,
          size: widget.size * 0.4,
          color: AppTheme.textMuted.withValues(alpha: 0.3),
        ),
      );
    }
  }

  /// ينفذ العملية `_buildLoadingOverlay`.
  /// Runs the `_buildLoadingOverlay` operation.
  Widget _buildLoadingOverlay() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Container(
        color: AppTheme.darkBackground.withValues(alpha: 0.6),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryBlue.withValues(alpha: 0.8),
              ),
              strokeWidth: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  /// ينفذ العملية `_showImageSourceDialog`.
  /// Runs the `_showImageSourceDialog` operation.
  void _showImageSourceDialog() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black26,
      builder: (context) => _UltraMinimalImageSourceSheet(
        hasCurrentImage:
            _selectedImage != null || widget.currentImageUrl != null,
        onCameraPressed: () {
          Navigator.pop(context);
          _pickImage(ImageSource.camera);
        },
        onGalleryPressed: () {
          Navigator.pop(context);
          _pickImage(ImageSource.gallery);
        },
        onRemovePressed: () {
          Navigator.pop(context);
          setState(() {
            _selectedImage = null;
          });
          widget.onImageSelected('');
        },
      ),
    );
  }

  /// ينفذ العملية `_pickImage`.
  /// Runs the `_pickImage` operation.
  Future<void> _pickImage(ImageSource source) async {
    try {
      bool hasPermission = await _checkPermission(source);
      if (!hasPermission) {
        _showMinimalPermissionDialog();
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final croppedFile = await _cropImage(pickedFile.path);
        if (croppedFile != null) {
          setState(() {
            _selectedImage = File(croppedFile.path);
          });
          widget.onImageSelected(croppedFile.path);
        }
      }
    } catch (e) {
      _showMinimalErrorSnackBar('فشل في اختيار الصورة');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// ينفذ العملية `_checkPermission`.
  /// Runs the `_checkPermission` operation.
  Future<bool> _checkPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        final result = await Permission.camera.request();
        return result.isGranted;
      }
      return true;
    } else {
      if (Platform.isIOS) {
        final status = await Permission.photos.status;
        if (status.isGranted || status.isLimited) return true;
        final result = await Permission.photos.request();
        return result.isGranted || result.isLimited;
      }
      return true;
    }
  }

  /// ينفذ العملية `_cropImage`.
  /// Runs the `_cropImage` operation.
  Future<CroppedFile?> _cropImage(String imagePath) async {
    return await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'قص الصورة',
          toolbarColor: AppTheme.darkBackground,
          toolbarWidgetColor: AppTheme.textWhite,
          activeControlsWidgetColor: AppTheme.primaryBlue,
          backgroundColor: AppTheme.darkBackground,
          cropFrameColor: AppTheme.primaryBlue.withValues(alpha: 0.5),
          cropGridColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
          lockAspectRatio: true,
          hideBottomControls: false,
          cropFrameStrokeWidth: 1,
          cropGridStrokeWidth: 1,
          cropGridRowCount: 2,
          cropGridColumnCount: 2,
          initAspectRatio: CropAspectRatioPreset.square,
        ),
        IOSUiSettings(
          title: 'قص الصورة',
          minimumAspectRatio: 1.0,
          aspectRatioLockEnabled: true,
          resetButtonHidden: false,
          rotateButtonsHidden: true,
          doneButtonTitle: 'تم',
          cancelButtonTitle: 'إلغاء',
        ),
      ],
    );
  }

  /// ينفذ العملية `_showMinimalPermissionDialog`.
  /// Runs the `_showMinimalPermissionDialog` operation.
  void _showMinimalPermissionDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      fullscreenDialog: true,
      context: context,
      barrierColor: Colors.black26,
      builder: (context) => _UltraMinimalDialog(
        icon: Icons.camera_alt_outlined,
        iconColor: AppTheme.warning,
        title: 'الصلاحية مطلوبة',
        message: 'نحتاج صلاحية الوصول للكاميرا أو المعرض',
        confirmText: 'الإعدادات',
        onConfirm: () {
          Navigator.pop(context);
          openAppSettings();
        },
      ),
    );
  }

  /// ينفذ العملية `_showMinimalErrorSnackBar`.
  /// Runs the `_showMinimalErrorSnackBar` operation.
  void _showMinimalErrorSnackBar(String message) {
    HapticFeedback.heavyImpact();

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _UltraMinimalSnackBar(
        message: message,
        icon: Icons.error_outline,
        backgroundColor: AppTheme.error,
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}

// Ultra Minimal Image Source Sheet
/// يعرّف الكلاس `_UltraMinimalImageSourceSheet`.
/// Describes the `_UltraMinimalImageSourceSheet` class.
class _UltraMinimalImageSourceSheet extends StatelessWidget {
  /// Indicates whether `hasCurrentImage` is enabled.
  /// العربية: يحدد ما إذا كانت القيمة `hasCurrentImage` مفعلة.
  final bool hasCurrentImage;

  /// يخزن العضو `onCameraPressed`.
  /// Holds the `onCameraPressed` member.
  final VoidCallback onCameraPressed;

  /// يخزن العضو `onGalleryPressed`.
  /// Holds the `onGalleryPressed` member.
  final VoidCallback onGalleryPressed;

  /// يخزن العضو `onRemovePressed`.
  /// Holds the `onRemovePressed` member.
  final VoidCallback onRemovePressed;

  /// ينشئ مثيلاً من `_UltraMinimalImageSourceSheet`.
  /// Builds an instance of `_UltraMinimalImageSourceSheet`.
  const _UltraMinimalImageSourceSheet({
    required this.hasCurrentImage,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onRemovePressed,
  });

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.darkCard.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.darkBorder.withValues(alpha: 0.05),
                width: 0.5,
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 28,
                    height: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.darkBorder.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Title
                  Text(
                    'اختر صورة',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textWhite.withValues(alpha: 0.9),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Camera option
                  _buildMinimalOption(
                    icon: Icons.camera_alt_outlined,
                    title: 'الكاميرا',
                    subtitle: 'التقط صورة جديدة',
                    onTap: onCameraPressed,
                  ),

                  // Gallery option
                  _buildMinimalOption(
                    icon: Icons.photo_library_outlined,
                    title: 'المعرض',
                    subtitle: 'اختر من الصور',
                    onTap: onGalleryPressed,
                  ),

                  // Remove option
                  if (hasCurrentImage)
                    _buildMinimalOption(
                      icon: Icons.delete_outline,
                      title: 'إزالة',
                      subtitle: 'حذف الصورة الحالية',
                      onTap: onRemovePressed,
                      isDestructive: true,
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ينفذ العملية `_buildMinimalOption`.
  /// Runs the `_buildMinimalOption` operation.
  Widget _buildMinimalOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: isDestructive
                    ? LinearGradient(
                        colors: [
                          AppTheme.error.withValues(alpha: 0.1),
                          AppTheme.error.withValues(alpha: 0.05),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          AppTheme.primaryBlue.withValues(alpha: 0.08),
                          AppTheme.primaryPurple.withValues(alpha: 0.04),
                        ],
                      ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive
                    ? AppTheme.error.withValues(alpha: 0.7)
                    : AppTheme.primaryBlue.withValues(alpha: 0.6),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDestructive
                          ? AppTheme.error.withValues(alpha: 0.8)
                          : AppTheme.textWhite.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      color: AppTheme.textMuted.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textMuted.withValues(alpha: 0.3),
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}

// Ultra Minimal Dialog
/// يعرّف الكلاس `_UltraMinimalDialog`.
/// Describes the `_UltraMinimalDialog` class.
class _UltraMinimalDialog extends StatelessWidget {
  /// Holds the `icon` value.
  /// العربية: يخزن القيمة `icon`.
  final IconData icon;

  /// يخزن العضو `iconColor`.
  /// Holds the `iconColor` member.
  final Color iconColor;

  /// يخزن العضو `title`.
  /// Holds the `title` member.
  final String title;

  /// يخزن العضو `message`.
  /// Holds the `message` member.
  final String message;

  /// يخزن العضو `confirmText`.
  /// Holds the `confirmText` member.
  final String confirmText;

  /// يخزن العضو `onConfirm`.
  /// Holds the `onConfirm` member.
  final VoidCallback onConfirm;

  /// ينشئ مثيلاً من `_UltraMinimalDialog`.
  /// Builds an instance of `_UltraMinimalDialog`.
  const _UltraMinimalDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.onConfirm,
  });

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor.withValues(alpha: 0.7),
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    AppTheme.darkBorder.withValues(alpha: 0.1),
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'إلغاء',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onConfirm();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  iconColor.withValues(alpha: 0.7),
                                  iconColor.withValues(alpha: 0.5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              confirmText,
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
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

// Ultra Minimal SnackBar
/// يعرّف الكلاس `_UltraMinimalSnackBar`.
/// Describes the `_UltraMinimalSnackBar` class.
class _UltraMinimalSnackBar extends StatefulWidget {
  /// Holds the `message` value.
  /// العربية: يخزن القيمة `message`.
  final String message;

  /// يخزن العضو `icon`.
  /// Holds the `icon` member.
  final IconData icon;

  /// يخزن العضو `backgroundColor`.
  /// Holds the `backgroundColor` member.
  final Color backgroundColor;

  /// ينشئ مثيلاً من `_UltraMinimalSnackBar`.
  /// Builds an instance of `_UltraMinimalSnackBar`.
  const _UltraMinimalSnackBar({
    required this.message,
    required this.icon,
    required this.backgroundColor,
  });

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<_UltraMinimalSnackBar> createState() => _UltraMinimalSnackBarState();
}

/// يعرّف الكلاس `_UltraMinimalSnackBarState`.
/// Describes the `_UltraMinimalSnackBarState` class.
class _UltraMinimalSnackBarState extends State<_UltraMinimalSnackBar>
    with SingleTickerProviderStateMixin {
  /// يخزن العضو `_controller`.
  /// Holds the `_controller` member.
  late AnimationController _controller;

  /// يخزن العضو `_fadeAnimation`.
  /// Holds the `_fadeAnimation` member.
  late Animation<double> _fadeAnimation;

  /// يخزن العضو `_slideAnimation`.
  /// Holds the `_slideAnimation` member.
  late Animation<Offset> _slideAnimation;

  /// ينفذ العملية `initState`.
  /// Runs the `initState` operation.
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  /// ينفذ العملية `dispose`.
  /// Runs the `dispose` operation.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.backgroundColor.withValues(alpha: 0.2),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.backgroundColor.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.backgroundColor.withValues(alpha: 0.2),
                              widget.backgroundColor.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.backgroundColor.withValues(alpha: 0.8),
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.message,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: AppTheme.textWhite.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
