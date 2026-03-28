// lib/features/admin_properties/presentation/widgets/unit_image_gallery.dart
// (الجزء الأول من التحديثات)

import 'dart:async';
import 'package:hggzkportal/core/constants/app_constants.dart';
import 'package:hggzkportal/core/utils/image_utils.dart';
import 'package:hggzkportal/core/utils/video_utils.dart';
import 'package:hggzkportal/core/theme/app_theme.dart';
import 'package:hggzkportal/core/widgets/video_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:hggzkportal/core/theme/app_text_styles.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:reorderables/reorderables.dart';
import '../../domain/entities/unit_image.dart';
import '../bloc/unit_images/unit_images_bloc.dart';
import '../bloc/unit_images/unit_images_event.dart';
import '../bloc/unit_images/unit_images_state.dart';

/// يمثل هذا الكلاس UnitImageGallery البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitImageGallery in the admin unit workflow.
class UnitImageGallery extends StatefulWidget {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String? unitId;

  /// يحتفظ هذا الحقل بقيمة tempKey التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tempKey value used by the admin unit workflow.
  final String? tempKey;

  /// يحتفظ هذا الحقل بقيمة isReadOnly التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isReadOnly value used by the admin unit workflow.
  final bool isReadOnly;

  /// يحتفظ هذا الحقل بقيمة maxImages التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the maxImages value used by the admin unit workflow.
  final int maxImages;

  /// يحتفظ هذا الحقل بقيمة maxVideos التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the maxVideos value used by the admin unit workflow.
  final int maxVideos; // إضافة حد الفيديوهات
  /// يستقبل callback لتحديث الصور بعد التغيير.
  /// Accepts a callback to notify image updates.
  final Function(List<UnitImage>)? onImagesChanged;

  /// يستقبل callback لتحديث الصور المحلية بعد التغيير.
  /// Accepts a callback to notify local image updates.
  final Function(List<String>)? onLocalImagesChanged;

  /// يحتفظ هذا الحقل بقيمة initialImages التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the initialImages value used by the admin unit workflow.
  final List<UnitImage>? initialImages;

  /// يحتفظ هذا الحقل بقيمة initialLocalImages التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the initialLocalImages value used by the admin unit workflow.
  final List<String>? initialLocalImages;

  /// ينشئ هذا المُنشئ مثيلاً من UnitImageGallery.
  /// This constructor creates an instance of UnitImageGallery.
  const UnitImageGallery({
    super.key,
    this.unitId,
    this.tempKey,
    this.isReadOnly = false,
    this.maxImages = 10,
    this.maxVideos = 3, // حد افتراضي للفيديوهات
    this.onImagesChanged,
    this.onLocalImagesChanged,
    this.initialImages,
    this.initialLocalImages,
  });

  /// ينشئ هذا الأسلوب كائن الحالة الخاص بهذه الصفحة.
  /// This method performs the createState operation in the admin unit workflow.
  @override
  State<UnitImageGallery> createState() => UnitImageGalleryState();
}

/// يمثل هذا الكلاس UnitImageGalleryState البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitImageGalleryState in the admin unit workflow.
class UnitImageGalleryState extends State<UnitImageGallery>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  /// يحتفظ هذا الحقل بقيمة _animationController التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _animationController value used by the admin unit workflow.
  late AnimationController _animationController;

  /// يحتفظ هذا الحقل بقيمة _pulseController التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _pulseController value used by the admin unit workflow.
  late AnimationController _pulseController;

  /// يحتفظ هذا الحقل بقيمة _selectionController التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _selectionController value used by the admin unit workflow.
  late AnimationController _selectionController;

  /// يحتفظ هذا الحقل بقيمة _uploadAnimationController التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _uploadAnimationController value used by the admin unit workflow.
  late AnimationController _uploadAnimationController;

  /// يحتفظ هذا الحقل بقيمة _imagesBloc التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _imagesBloc value used by the admin unit workflow.
  UnitImagesBloc? _imagesBloc;

  // Local state management
  /// يحتفظ هذا الحقل بقيمة _localImages التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _localImages value used by the admin unit workflow.
  List<String> _localImages = [];

  /// يحتفظ هذا الحقل بقيمة _remoteImages التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _remoteImages value used by the admin unit workflow.
  List<UnitImage> _remoteImages = [];

  /// يحتفظ هذا الحقل بقيمة _displayImages التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _displayImages value used by the admin unit workflow.
  List<UnitImage> _displayImages = [];

  // تتبع الفيديوهات المنفصل
  /// يحتفظ هذا الحقل بقيمة _videoThumbnails التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _videoThumbnails value used by the admin unit workflow.
  final Map<String, String?> _videoThumbnails =
      {}; // مسار الفيديو -> مسار الصورة المصغرة

  // Upload tracking
  /// يحتفظ هذا الحقل بقيمة _uploadProgress التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _uploadProgress value used by the admin unit workflow.
  final Map<String, double> _uploadProgress = {};

  /// يحتفظ هذا الحقل بقيمة _uploadingFiles التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _uploadingFiles value used by the admin unit workflow.
  final Map<String, bool> _uploadingFiles = {};

  /// يحتفظ هذا الحقل بقيمة _uploadingFileObjects التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _uploadingFileObjects value used by the admin unit workflow.
  final Map<String, File?> _uploadingFileObjects = {};

  /// يحتفظ هذا الحقل بقيمة _uploadingFileTypes التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _uploadingFileTypes value used by the admin unit workflow.
  final Map<String, String> _uploadingFileTypes =
      {}; // تتبع نوع الملف (image/video)

  /// يحتفظ هذا الحقل بقيمة _hoveredIndex التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _hoveredIndex value used by the admin unit workflow.
  int? _hoveredIndex;

  /// يحتفظ هذا الحقل بقيمة _isDragging التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _isDragging value used by the admin unit workflow.
  bool _isDragging = false;

  /// يحتفظ هذا الحقل بقيمة _isSelectionMode التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _isSelectionMode value used by the admin unit workflow.
  bool _isSelectionMode = false;

  /// يحتفظ هذا الحقل بقيمة _isReorderMode التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _isReorderMode value used by the admin unit workflow.
  bool _isReorderMode = false;

  /// يحتفظ هذا الحقل بقيمة _isLocalSelectionMode التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _isLocalSelectionMode value used by the admin unit workflow.
  bool _isLocalSelectionMode = false;

  /// يحتفظ هذا الحقل بقيمة _isLocalReorderMode التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _isLocalReorderMode value used by the admin unit workflow.
  bool _isLocalReorderMode = false;

  /// يحتفظ هذا الحقل بقيمة _selectedImageIds التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _selectedImageIds value used by the admin unit workflow.
  final Set<String> _selectedImageIds = {};

  /// يحتفظ هذا الحقل بقيمة _selectedLocalIndices التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _selectedLocalIndices value used by the admin unit workflow.
  final Set<int> _selectedLocalIndices = {};

  /// يحتفظ هذا الحقل بقيمة _primaryImageIndex التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _primaryImageIndex value used by the admin unit workflow.
  int? _primaryImageIndex = 0;

  /// يحتفظ هذا الحقل بقيمة _primaryLocalImageIndex التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _primaryLocalImageIndex value used by the admin unit workflow.
  int? _primaryLocalImageIndex = 0;

  /// يعيد هذا getter قيمة _isLocalMode المشتقة من الحالة الحالية.
  /// This getter derives the _isLocalMode value from the current state.
  bool get _isLocalMode =>
      (widget.unitId == null || widget.unitId!.isEmpty) &&
      (widget.tempKey == null || widget.tempKey!.isEmpty);

  /// يحتفظ هذا الحقل بقيمة _isInitialLoadDone التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _isInitialLoadDone value used by the admin unit workflow.
  bool _isInitialLoadDone = false;

  // عد الوسائط
  /// يعيد هذا getter قيمة _imageCount المشتقة من الحالة الحالية.
  /// This getter derives the _imageCount value from the current state.
  int get _imageCount => _displayImages.where((img) => img.isImage).length;

  /// يعيد هذا getter قيمة _videoCount المشتقة من الحالة الحالية.
  /// This getter derives the _videoCount value from the current state.
  int get _videoCount => _displayImages.where((img) => img.isVideo).length;

  /// يعيد هذا getter قيمة _localImageCount المشتقة من الحالة الحالية.
  /// This getter derives the _localImageCount value from the current state.
  int get _localImageCount =>
      _localImages.where((path) => !AppConstants.isVideoFile(path)).length;

  /// يعيد هذا getter قيمة _localVideoCount المشتقة من الحالة الحالية.
  /// This getter derives the _localVideoCount value from the current state.
  int get _localVideoCount =>
      _localImages.where((path) => AppConstants.isVideoFile(path)).length;

  /// ينفذ هذا الأسلوب عملية initState ضمن مسار إدارة الوحدات.
  /// This method performs the initState operation in the admin unit workflow.
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  /// ينفذ هذا الأسلوب عملية _initializeAnimations ضمن مسار إدارة الوحدات.
  /// This method performs the _initializeAnimations operation in the admin unit workflow.
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _uploadAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animationController.forward();
  }

  /// ينفذ هذا الأسلوب عملية _initializeData ضمن مسار إدارة الوحدات.
  /// This method performs the _initializeData operation in the admin unit workflow.
  void _initializeData() {
    if (widget.initialLocalImages != null) {
      _localImages = List.from(widget.initialLocalImages!);
      _generateThumbnailsForLocalVideos();
    }

    if (widget.initialImages != null && !_isLocalMode) {
      _remoteImages = List.from(widget.initialImages!);
      _displayImages = List.from(widget.initialImages!);
      _primaryImageIndex =
          _displayImages.indexWhere((img) => img.isPrimary == true);
      if (_primaryImageIndex == -1) _primaryImageIndex = 0;
    }
  }

  /// ينفذ هذا الأسلوب عملية _generateThumbnailsForLocalVideos ضمن مسار إدارة الوحدات.
  /// This method performs the _generateThumbnailsForLocalVideos operation in the admin unit workflow.
  Future<void> _generateThumbnailsForLocalVideos() async {
    for (String path in _localImages) {
      if (AppConstants.isVideoFile(path)) {
        final thumbnail = await VideoUtils.generateVideoThumbnail(path);
        if (mounted) {
          setState(() {
            _videoThumbnails[path] = thumbnail;
          });
        }
      }
    }
  }

  /// ينفذ هذا الأسلوب عملية didChangeDependencies ضمن مسار إدارة الوحدات.
  /// This method performs the didChangeDependencies operation in the admin unit workflow.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isLocalMode && !_isInitialLoadDone) {
      try {
        _imagesBloc = context.read<UnitImagesBloc?>();
        if (_imagesBloc != null &&
            ((widget.unitId != null && widget.unitId!.isNotEmpty) ||
                (widget.tempKey != null && widget.tempKey!.isNotEmpty))) {
          _imagesBloc!.add(LoadUnitImagesEvent(
              unitId: widget.unitId, tempKey: widget.tempKey));
          _isInitialLoadDone = true;
        }
      } catch (e) {
        debugPrint('UnitImagesBloc not available, working in local mode');
      }
    }
  }

  /// ينفذ هذا الأسلوب عملية dispose ضمن مسار إدارة الوحدات.
  /// This method performs the dispose operation in the admin unit workflow.
  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _selectionController.dispose();
    _uploadAnimationController.dispose();
    super.dispose();
  }

  /// ينفذ هذا الأسلوب عملية build ضمن مسار إدارة الوحدات.
  /// This method performs the build operation in the admin unit workflow.
  @override
  Widget build(BuildContext context) {
    if (_isLocalMode) {
      return _buildLocalModeContent();
    }

    if (_imagesBloc == null) {
      return _buildLocalModeContent();
    }

    return BlocConsumer<UnitImagesBloc, UnitImagesState>(
      bloc: _imagesBloc,
      listener: (context, state) {
        handleStateChanges(state);
      },
      builder: (context, state) {
        return _buildContent(state);
      },
    );
  }

  /// ينفذ هذا الأسلوب عملية uploadLocalImages ضمن مسار إدارة الوحدات.
  /// This method performs the uploadLocalImages operation in the admin unit workflow.
  Future<void> uploadLocalImages(String newUnitId) async {
    if (_localImages.isEmpty || _imagesBloc == null) return;

    _imagesBloc!.add(UploadMultipleUnitImagesEvent(
      unitId: newUnitId,
      tempKey: widget.tempKey,
      filePaths: _localImages,
    ));

    setState(() {
      _localImages.clear();
      _videoThumbnails.clear();
    });
  }

  /// ينفذ هذا الأسلوب عملية _buildContent ضمن مسار إدارة الوحدات.
  /// This method performs the _buildContent operation in the admin unit workflow.
  Widget _buildContent(UnitImagesState state) {
    final images =
        _displayImages.isNotEmpty ? _displayImages : getImagesFromState(state);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildEnhancedHeader(images.length, state),
          const SizedBox(height: 20),
          if (_uploadingFiles.isNotEmpty) buildEnhancedUploadProgressCards(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: buildMainContent(images, state),
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildLocalModeContent ضمن مسار إدارة الوحدات.
  /// This method performs the _buildLocalModeContent operation in the admin unit workflow.
  Widget _buildLocalModeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocalHeaderSection(_localImages.length),
          const SizedBox(height: 20),
          if (!widget.isReadOnly &&
              (_localImageCount < widget.maxImages ||
                  _localVideoCount < widget.maxVideos) &&
              !_isLocalSelectionMode &&
              !_isLocalReorderMode)
            buildMinimalistUploadArea(),
          if (_localImages.isNotEmpty) ...[
            if (!widget.isReadOnly &&
                (_localImageCount < widget.maxImages ||
                    _localVideoCount < widget.maxVideos) &&
                !_isLocalSelectionMode &&
                !_isLocalReorderMode)
              const SizedBox(height: 24),
            _isLocalReorderMode
                ? _buildLocalReorderableGrid(_localImages)
                : _buildLocalImagesGrid(_localImages),
          ],
          if (_localImages.isEmpty && widget.isReadOnly)
            buildMinimalistEmptyState(),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildLocalReorderableGrid ضمن مسار إدارة الوحدات.
  /// This method performs the _buildLocalReorderableGrid operation in the admin unit workflow.
  Widget _buildLocalReorderableGrid(List<String> images) {
    return ReorderableWrap(
      spacing: 8,
      runSpacing: 8,
      needsLongPressDraggable: false,
      children: images.asMap().entries.map((entry) {
        final index = entry.key;
        final imagePath = entry.value;
        return _buildReorderableLocalImageItem(imagePath, index);
      }).toList(),
      onReorder: (oldIndex, newIndex) {
        _reorderLocalImages(oldIndex, newIndex);
      },
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildReorderableLocalImageItem ضمن مسار إدارة الوحدات.
  /// This method performs the _buildReorderableLocalImageItem operation in the admin unit workflow.
  Widget _buildReorderableLocalImageItem(String imagePath, int index) {
    final isPrimary = index == _primaryLocalImageIndex;

    return Container(
      key: ValueKey('local_$index'),
      width: (MediaQuery.of(context).size.width - 56) / 3,
      height: (MediaQuery.of(context).size.width - 56) / 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildImageFromPath(imagePath),
          ),

          // Drag Handle
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.drag_indicator_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),

          // Order Number
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Primary Badge
          if (isPrimary)
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'رئيسية',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _reorderLocalImages ضمن مسار إدارة الوحدات.
  /// This method performs the _reorderLocalImages operation in the admin unit workflow.
  void _reorderLocalImages(int oldIndex, int newIndex) {
    setState(() {
      final image = _localImages.removeAt(oldIndex);
      _localImages.insert(newIndex, image);

      // Update primary image index if needed
      if (_primaryLocalImageIndex == oldIndex) {
        _primaryLocalImageIndex = newIndex;
      } else if (oldIndex < _primaryLocalImageIndex! &&
          newIndex >= _primaryLocalImageIndex!) {
        _primaryLocalImageIndex = _primaryLocalImageIndex! - 1;
      } else if (oldIndex > _primaryLocalImageIndex! &&
          newIndex <= _primaryLocalImageIndex!) {
        _primaryLocalImageIndex = _primaryLocalImageIndex! + 1;
      }
    });

    if (widget.onLocalImagesChanged != null) {
      widget.onLocalImagesChanged!(_localImages);
    }
  }

  /// ينفذ هذا الأسلوب عملية _buildLocalHeaderSection ضمن مسار إدارة الوحدات.
  /// This method performs the _buildLocalHeaderSection operation in the admin unit workflow.
  Widget _buildLocalHeaderSection(int imageCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLocalSelectionMode
                        ? 'تم تحديد ${_selectedLocalIndices.length}'
                        : _isLocalReorderMode
                            ? 'ترتيب الوسائط'
                            : 'معرض الوسائط (محلي)',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'صور: $_localImageCount/${widget.maxImages} • فيديو: $_localVideoCount/${widget.maxVideos}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              if (!widget.isReadOnly && imageCount > 0)
                _buildLocalHeaderActions(),
            ],
          ),
          if (_isLocalSelectionMode || _isLocalReorderMode)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isLocalSelectionMode
                        ? Icons.info_outline_rounded
                        : Icons.drag_indicator_rounded,
                    size: 14,
                    color: AppTheme.primaryBlue.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isLocalSelectionMode
                        ? 'اضغط على الوسائط لتحديدها'
                        : 'اسحب الوسائط لإعادة ترتيبها',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          if (!_isLocalSelectionMode && !_isLocalReorderMode)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppTheme.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 12,
                    color: AppTheme.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'سيتم الرفع عند الحفظ',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.warning,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildLocalHeaderActions ضمن مسار إدارة الوحدات.
  /// This method performs the _buildLocalHeaderActions operation in the admin unit workflow.
  Widget _buildLocalHeaderActions() {
    return Row(
      children: [
        if (!_isLocalReorderMode)
          buildActionChip(
            icon: _isLocalSelectionMode
                ? Icons.close_rounded
                : Icons.check_circle_outline_rounded,
            label: _isLocalSelectionMode ? 'إلغاء' : 'تحديد',
            onTap: () {
              HapticFeedback.lightImpact();
              toggleLocalSelectionMode();
            },
            isActive: _isLocalSelectionMode,
          ),
        const SizedBox(width: 8),
        if (!_isLocalSelectionMode && _localImages.length > 1)
          buildActionChip(
            icon: _isLocalReorderMode
                ? Icons.done_rounded
                : Icons.swap_vert_rounded,
            label: _isLocalReorderMode ? 'تم' : 'ترتيب',
            onTap: () {
              HapticFeedback.lightImpact();
              toggleLocalReorderMode();
            },
            isActive: _isLocalReorderMode,
          ),
        if (_isLocalSelectionMode && _selectedLocalIndices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: buildActionChip(
              icon: Icons.delete_outline_rounded,
              label: 'حذف',
              onTap: deleteSelectedLocalImages,
              isDestructive: true,
            ),
          ),
      ],
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildLocalImagesGrid ضمن مسار إدارة الوحدات.
  /// This method performs the _buildLocalImagesGrid operation in the admin unit workflow.
  Widget _buildLocalImagesGrid(List<String> items) {
    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 275),
            columnCount: 3,
            child: ScaleAnimation(
              scale: 0.95,
              child: FadeInAnimation(
                child: _buildLocalMediaItem(
                  items[index],
                  index,
                  _selectedLocalIndices.contains(index),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildLocalMediaItem ضمن مسار إدارة الوحدات.
  /// This method performs the _buildLocalMediaItem operation in the admin unit workflow.
  Widget _buildLocalMediaItem(String path, int index, bool isSelected) {
    final bool isHovered = _hoveredIndex == index;
    final bool isPrimary = index == _primaryLocalImageIndex;
    final bool isVideo = AppConstants.isVideoFile(path);

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: () {
          if (_isLocalSelectionMode) {
            setState(() {
              if (_selectedLocalIndices.contains(index)) {
                _selectedLocalIndices.remove(index);
              } else {
                _selectedLocalIndices.add(index);
              }
            });
          } else {
            if (isVideo) {
              previewLocalVideo(path);
            } else {
              previewLocalImage(path);
            }
          }
        },
        onLongPress: () {
          if (!widget.isReadOnly && !_isLocalSelectionMode) {
            HapticFeedback.mediumImpact();
            showLocalMediaOptionsMenu(path, index, isVideo);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(isHovered || isSelected ? 0.95 : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryBlue.withValues(alpha: 0.6)
                  : AppTheme.darkBorder.withValues(alpha: 0.1),
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (isVideo)
                  _buildVideoThumbnail(path)
                else
                  _buildImageFromPath(path),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(
                            alpha:
                                isHovered || _isLocalSelectionMode ? 0.6 : 0.3),
                      ],
                    ),
                  ),
                ),
                if (isVideo)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.darkCard.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                if (!widget.isReadOnly && !_isLocalSelectionMode)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    top: isHovered ? 8 : -40,
                    left: 8,
                    right: 8,
                    child: buildQuickActions(
                      onView: () => isVideo
                          ? previewLocalVideo(path)
                          : previewLocalImage(path),
                      onSetPrimary: !isPrimary && !isVideo
                          ? () => setLocalPrimaryImage(index)
                          : null,
                      onDelete: () => confirmDeleteLocalMedia(index),
                    ),
                  ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isVideo
                          ? AppTheme.info.withValues(alpha: 0.8)
                          : AppTheme.darkCard.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isVideo ? Icons.videocam : Icons.image,
                          size: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          isVideo ? 'فيديو' : '${index + 1}',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isPrimary && !isVideo)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.warning.withValues(alpha: 0.3),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'رئيسية',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_isLocalSelectionMode)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryBlue
                            : AppTheme.darkCard.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                if (!_isLocalSelectionMode)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.schedule,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildVideoThumbnail ضمن مسار إدارة الوحدات.
  /// This method performs the _buildVideoThumbnail operation in the admin unit workflow.
  Widget _buildVideoThumbnail(String videoPath) {
    final thumbnail = _videoThumbnails[videoPath];

    if (thumbnail != null && File(thumbnail).existsSync()) {
      return Image.file(
        File(thumbnail),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return buildVideoPlaceholder();
        },
      );
    }

    return buildVideoPlaceholder();
  }

  /// ينفذ هذا الأسلوب عملية buildVideoPlaceholder ضمن مسار إدارة الوحدات.
  /// This method performs the buildVideoPlaceholder operation in the admin unit workflow.
  Widget buildVideoPlaceholder() {
    return Container(
      color: AppTheme.darkCard.withValues(alpha: 0.3),
      child: Center(
        child: Icon(
          Icons.videocam_outlined,
          color: AppTheme.textMuted.withValues(alpha: 0.5),
          size: 32,
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية buildQuickActions ضمن مسار إدارة الوحدات.
  /// This method performs the buildQuickActions operation in the admin unit workflow.
  Widget buildQuickActions({
    required VoidCallback onView,
    VoidCallback? onSetPrimary,
    required VoidCallback onDelete,
  }) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          buildQuickActionButton(
            icon: Icons.visibility_outlined,
            onTap: onView,
          ),
          if (onSetPrimary != null)
            buildQuickActionButton(
              icon: Icons.star_outline_rounded,
              onTap: onSetPrimary,
              color: AppTheme.warning,
            ),
          buildQuickActionButton(
            icon: Icons.delete_outline_rounded,
            onTap: onDelete,
            color: AppTheme.error,
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية buildImageFromPath ضمن مسار إدارة الوحدات.
  /// This method performs the buildImageFromPath operation in the admin unit workflow.
  Widget buildImageFromPath(String path) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.of(context).devicePixelRatio;
        final targetWidth = (constraints.maxWidth.isFinite
                ? constraints.maxWidth * dpr
                : 256 * dpr)
            .clamp(64, 1024)
            .round();
        if (path.startsWith('http')) {
          return CachedNetworkImage(
            imageUrl: path,
            fadeInDuration: const Duration(milliseconds: 0),
            imageBuilder: (ctx, provider) => Image(
              image: ResizeImage(provider, width: targetWidth),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
            ),
            placeholder: (context, url) => Container(
              color: AppTheme.darkCard.withValues(alpha: 0.3),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppTheme.darkCard.withValues(alpha: 0.3),
              child: Icon(
                Icons.image_not_supported_outlined,
                color: AppTheme.textMuted.withValues(alpha: 0.3),
                size: 24,
              ),
            ),
          );
        } else {
          return Image.file(
            File(path),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
            cacheWidth: targetWidth,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppTheme.darkCard.withValues(alpha: 0.3),
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppTheme.textMuted.withValues(alpha: 0.3),
                  size: 24,
                ),
              );
            },
          );
        }
      },
    );
  }

  /// ينفذ هذا الأسلوب عملية deleteLocalImage ضمن مسار إدارة الوحدات.
  /// This method performs the deleteLocalImage operation in the admin unit workflow.
  void deleteLocalImage(int index) {
    setState(() {
      _localImages.removeAt(index);
      _selectedLocalIndices.remove(index);
      // تحديث الـ indices بعد الحذف
      final updatedIndices = <int>{};
      for (var i in _selectedLocalIndices) {
        if (i > index) {
          updatedIndices.add(i - 1);
        } else if (i < index) {
          updatedIndices.add(i);
        }
      }
      _selectedLocalIndices.clear();
      _selectedLocalIndices.addAll(updatedIndices);

      // تحديث الـ primary index
      if (_primaryLocalImageIndex == index) {
        _primaryLocalImageIndex = _localImages.isEmpty ? null : 0;
      } else if (_primaryLocalImageIndex != null &&
          _primaryLocalImageIndex! > index) {
        _primaryLocalImageIndex = _primaryLocalImageIndex! - 1;
      }
    });

    if (widget.onLocalImagesChanged != null) {
      widget.onLocalImagesChanged!(_localImages);
    }

    showSuccessSnackBar('تم حذف الصورة');
  }

  /// ينفذ هذا الأسلوب عملية confirmDeleteLocalImage ضمن مسار إدارة الوحدات.
  /// This method performs the confirmDeleteLocalImage operation in the admin unit workflow.
  void confirmDeleteLocalImage(int index) {
    showDialog(
      fullscreenDialog: true,
      context: context,
      builder: (context) => _DeleteConfirmationDialog(
        count: 1,
        onConfirm: () {
          Navigator.pop(context);
          deleteLocalImage(index);
        },
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية showLocalMediaOptionsMenu ضمن مسار إدارة الوحدات.
  /// This method performs the showLocalMediaOptionsMenu operation in the admin unit workflow.
  void showLocalMediaOptionsMenu(String path, int index, bool isVideo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _LocalMediaOptionsSheet(
        mediaPath: path,
        index: index,
        isVideo: isVideo,
        isPrimary: !isVideo && index == _primaryLocalImageIndex,
        onSetPrimary: !isVideo
            ? () {
                Navigator.pop(context);
                setLocalPrimaryImage(index);
              }
            : null,
        onDelete: () {
          Navigator.pop(context);
          confirmDeleteLocalMedia(index);
        },
        onView: () {
          Navigator.pop(context);
          if (isVideo) {
            previewLocalVideo(path);
          } else {
            previewLocalImage(path);
          }
        },
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية confirmDeleteLocalMedia ضمن مسار إدارة الوحدات.
  /// This method performs the confirmDeleteLocalMedia operation in the admin unit workflow.
  void confirmDeleteLocalMedia(int index) {
    showDialog(
      fullscreenDialog: true,
      context: context,
      builder: (context) => _DeleteConfirmationDialog(
        count: 1,
        onConfirm: () {
          Navigator.pop(context);
          deleteLocalMedia(index);
        },
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية deleteLocalMedia ضمن مسار إدارة الوحدات.
  /// This method performs the deleteLocalMedia operation in the admin unit workflow.
  void deleteLocalMedia(int index) {
    setState(() {
      final path = _localImages[index];
      if (AppConstants.isVideoFile(path)) {
        _videoThumbnails.remove(path);
      }

      _localImages.removeAt(index);
      _selectedLocalIndices.remove(index);

      final updatedIndices = <int>{};
      for (var i in _selectedLocalIndices) {
        if (i > index) {
          updatedIndices.add(i - 1);
        } else if (i < index) {
          updatedIndices.add(i);
        }
      }
      _selectedLocalIndices.clear();
      _selectedLocalIndices.addAll(updatedIndices);

      if (_primaryLocalImageIndex == index) {
        _primaryLocalImageIndex = _localImages.isEmpty ? null : 0;
      } else if (_primaryLocalImageIndex != null &&
          _primaryLocalImageIndex! > index) {
        _primaryLocalImageIndex = _primaryLocalImageIndex! - 1;
      }
    });

    if (widget.onLocalImagesChanged != null) {
      widget.onLocalImagesChanged!(_localImages);
    }

    showSuccessSnackBar('تم حذف الوسائط');
  }

  /// ينفذ هذا الأسلوب عملية pickVideo ضمن مسار إدارة الوحدات.
  /// This method performs the pickVideo operation in the admin unit workflow.
  Future<void> pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: AppConstants.maxVideoDuration,
      );

      if (video != null) {
        // التحقق من حجم الفيديو
        final file = File(video.path);
        final sizeInBytes = await file.length();

        if (sizeInBytes > AppConstants.maxVideoUploadSize) {
          showErrorSnackBar(
              'حجم الفيديو كبير جداً. الحد الأقصى ${AppConstants.maxVideoUploadSize ~/ (1024 * 1024)} ميجابايت');
          return;
        }

        await handleMediaFile(video.path, isVideo: true);
      }
    } catch (e) {
      showErrorSnackBar('فشل في اختيار الفيديو');
    }
  }

  /// ينفذ هذا الأسلوب عملية handleMediaFile ضمن مسار إدارة الوحدات.
  /// This method performs the handleMediaFile operation in the admin unit workflow.
  Future<void> handleMediaFile(String filePath, {required bool isVideo}) async {
    if (_isLocalMode) {
      // Generate thumbnail for video
      if (isVideo) {
        final thumbnail = await VideoUtils.generateVideoThumbnail(filePath);
        if (mounted) {
          setState(() {
            _videoThumbnails[filePath] = thumbnail;
          });
        }
      }

      setState(() {
        _localImages.add(filePath);
        if (_primaryLocalImageIndex == null &&
            _localImages.isNotEmpty &&
            !isVideo) {
          _primaryLocalImageIndex = 0;
        }

        // تابع unit_image_gallery.dart من حيث توقفنا
      });
      if (widget.onLocalImagesChanged != null) {
        widget.onLocalImagesChanged!(_localImages);
      }
      showSuccessSnackBar(isVideo
          ? 'تم إضافة الفيديو (سيتم الرفع عند الحفظ)'
          : 'تم إضافة الصورة (سيتم الرفع عند الحفظ)');
    } else if (_imagesBloc != null &&
        (widget.unitId != null ||
            (widget.tempKey != null && widget.tempKey!.isNotEmpty))) {
      // في وضع التعديل، ارفع مباشرة
      final fileKey = DateTime.now().millisecondsSinceEpoch.toString();
      setState(() {
        _uploadingFiles[fileKey] = true;
        _uploadingFileObjects[fileKey] = File(filePath);
        _uploadProgress[fileKey] = 0.0;
        _uploadingFileTypes[fileKey] = isVideo ? 'video' : 'image';
      });

      _imagesBloc!.add(UploadUnitImageEvent(
        unitId: widget.unitId,
        tempKey: widget.tempKey,
        filePath: filePath,
        isPrimary: _displayImages.isEmpty && !isVideo,
        category: isVideo ? 'video' : null,
      ));
    }
  }

  /// ينفذ هذا الأسلوب عملية pickImage ضمن مسار إدارة الوحدات.
  /// This method performs the pickImage operation in the admin unit workflow.
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        await handleMediaFile(image.path, isVideo: false);
      }
    } catch (e) {
      showErrorSnackBar('فشل في اختيار الصورة');
    }
  }

  /// ينفذ هذا الأسلوب عملية pickMultipleImages ضمن مسار إدارة الوحدات.
  /// This method performs the pickMultipleImages operation in the admin unit workflow.
  Future<void> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final remainingSlots =
            widget.maxImages - (_isLocalMode ? _localImageCount : _imageCount);
        final imagesToAdd = images.take(remainingSlots).toList();

        if (imagesToAdd.isNotEmpty) {
          if (_isLocalMode) {
            setState(() {
              _localImages.addAll(imagesToAdd.map((img) => img.path));
              if (_primaryLocalImageIndex == null && _localImages.isNotEmpty) {
                _primaryLocalImageIndex = 0;
              }
            });
            if (widget.onLocalImagesChanged != null) {
              widget.onLocalImagesChanged!(_localImages);
            }
            showSuccessSnackBar(
                'تم إضافة ${imagesToAdd.length} صورة (سيتم الرفع عند الحفظ)');
          } else if (_imagesBloc != null &&
              (widget.unitId != null || widget.tempKey != null)) {
            setState(() {
              for (var img in imagesToAdd) {
                final fileKey =
                    '${DateTime.now().millisecondsSinceEpoch}_${img.name}';
                _uploadingFiles[fileKey] = true;
                _uploadingFileObjects[fileKey] = File(img.path);
                _uploadProgress[fileKey] = 0.0;
                _uploadingFileTypes[fileKey] = 'image';
              }
            });

            _imagesBloc!.add(UploadMultipleUnitImagesEvent(
              unitId: widget.unitId,
              tempKey: widget.tempKey,
              filePaths: imagesToAdd.map((img) => img.path).toList(),
            ));
          }
        }
      }
    } catch (e) {
      showErrorSnackBar('فشل في اختيار الصور');
    }
  }

  // 1. _buildLocalHeaderActions
  /// ينفذ هذا الأسلوب عملية buildLocalHeaderActions ضمن مسار إدارة الوحدات.
  /// This method performs the buildLocalHeaderActions operation in the admin unit workflow.
  Widget buildLocalHeaderActions() {
    return Row(
      children: [
        if (!_isLocalReorderMode)
          buildActionChip(
            icon: _isLocalSelectionMode
                ? Icons.close_rounded
                : Icons.check_circle_outline_rounded,
            label: _isLocalSelectionMode ? 'إلغاء' : 'تحديد',
            onTap: () {
              HapticFeedback.lightImpact();
              toggleLocalSelectionMode();
            },
            isActive: _isLocalSelectionMode,
          ),
        const SizedBox(width: 8),
        if (!_isLocalSelectionMode && _localImages.length > 1)
          buildActionChip(
            icon: _isLocalReorderMode
                ? Icons.done_rounded
                : Icons.swap_vert_rounded,
            label: _isLocalReorderMode ? 'تم' : 'ترتيب',
            onTap: () {
              HapticFeedback.lightImpact();
              toggleLocalReorderMode();
            },
            isActive: _isLocalReorderMode,
          ),
        if (_isLocalSelectionMode && _selectedLocalIndices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: buildActionChip(
              icon: Icons.delete_outline_rounded,
              label: 'حذف',
              onTap: deleteSelectedLocalImages,
              isDestructive: true,
            ),
          ),
      ],
    );
  }

  // 2. _toggleLocalSelectionMode
  /// ينفذ هذا الأسلوب عملية toggleLocalSelectionMode ضمن مسار إدارة الوحدات.
  /// This method performs the toggleLocalSelectionMode operation in the admin unit workflow.
  void toggleLocalSelectionMode() {
    setState(() {
      _isLocalSelectionMode = !_isLocalSelectionMode;
      if (!_isLocalSelectionMode) {
        _selectedLocalIndices.clear();
      } else {
        _isLocalReorderMode = false;
      }
    });
  }

  // 3. _toggleLocalReorderMode
  /// ينفذ هذا الأسلوب عملية toggleLocalReorderMode ضمن مسار إدارة الوحدات.
  /// This method performs the toggleLocalReorderMode operation in the admin unit workflow.
  void toggleLocalReorderMode() {
    setState(() {
      _isLocalReorderMode = !_isLocalReorderMode;
      if (_isLocalReorderMode) {
        _isLocalSelectionMode = false;
        _selectedLocalIndices.clear();
      }
    });
  }

  // 4. _deleteSelectedLocalImages
  /// ينفذ هذا الأسلوب عملية deleteSelectedLocalImages ضمن مسار إدارة الوحدات.
  /// This method performs the deleteSelectedLocalImages operation in the admin unit workflow.
  void deleteSelectedLocalImages() {
    if (_selectedLocalIndices.isEmpty) return;

    showDialog(
      fullscreenDialog: true,
      context: context,
      builder: (context) => _DeleteConfirmationDialog(
        count: _selectedLocalIndices.length,
        onConfirm: () {
          Navigator.pop(context);

          final sortedIndices = _selectedLocalIndices.toList()
            ..sort((a, b) => b.compareTo(a));
          for (var index in sortedIndices) {
            final path = _localImages[index];
            if (AppConstants.isVideoFile(path)) {
              _videoThumbnails.remove(path);
            }
            _localImages.removeAt(index);
          }

          setState(() {
            _selectedLocalIndices.clear();
            _isLocalSelectionMode = false;
            if (_primaryLocalImageIndex != null &&
                _primaryLocalImageIndex! >= _localImages.length) {
              _primaryLocalImageIndex = _localImages.isEmpty ? null : 0;
            }
          });

          if (widget.onLocalImagesChanged != null) {
            widget.onLocalImagesChanged!(_localImages);
          }

          showSuccessSnackBar('تم حذف الوسائط المحددة');
        },
      ),
    );
  }

  // 5. _buildLocalReorderableGrid
  /// ينفذ هذا الأسلوب عملية buildLocalReorderableGrid ضمن مسار إدارة الوحدات.
  /// This method performs the buildLocalReorderableGrid operation in the admin unit workflow.
  Widget buildLocalReorderableGrid(List<String> items) {
    return ReorderableWrap(
      spacing: 8,
      runSpacing: 8,
      needsLongPressDraggable: false,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final path = entry.value;
        return buildReorderableLocalMediaItem(path, index);
      }).toList(),
      onReorder: (oldIndex, newIndex) {
        reorderLocalImages(oldIndex, newIndex);
      },
    );
  }

  // 6. _buildReorderableLocalMediaItem
  /// ينفذ هذا الأسلوب عملية buildReorderableLocalMediaItem ضمن مسار إدارة الوحدات.
  /// This method performs the buildReorderableLocalMediaItem operation in the admin unit workflow.
  Widget buildReorderableLocalMediaItem(String path, int index) {
    final isPrimary = index == _primaryLocalImageIndex;
    final isVideo = AppConstants.isVideoFile(path);

    return Container(
      key: ValueKey('local_$index'),
      width: (MediaQuery.of(context).size.width - 56) / 3,
      height: (MediaQuery.of(context).size.width - 56) / 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child:
                isVideo ? _buildVideoThumbnail(path) : buildImageFromPath(path),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.drag_indicator_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          if (isPrimary && !isVideo)
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'رئيسية',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 7. _reorderLocalImages
  /// ينفذ هذا الأسلوب عملية reorderLocalImages ضمن مسار إدارة الوحدات.
  /// This method performs the reorderLocalImages operation in the admin unit workflow.
  void reorderLocalImages(int oldIndex, int newIndex) {
    setState(() {
      final item = _localImages.removeAt(oldIndex);
      _localImages.insert(newIndex, item);

      if (_primaryLocalImageIndex == oldIndex) {
        _primaryLocalImageIndex = newIndex;
      } else if (oldIndex < _primaryLocalImageIndex! &&
          newIndex >= _primaryLocalImageIndex!) {
        _primaryLocalImageIndex = _primaryLocalImageIndex! - 1;
      } else if (oldIndex > _primaryLocalImageIndex! &&
          newIndex <= _primaryLocalImageIndex!) {
        _primaryLocalImageIndex = _primaryLocalImageIndex! + 1;
      }
    });

    if (widget.onLocalImagesChanged != null) {
      widget.onLocalImagesChanged!(_localImages);
    }
  }

  // 8. _setLocalPrimaryImage
  /// ينفذ هذا الأسلوب عملية setLocalPrimaryImage ضمن مسار إدارة الوحدات.
  /// This method performs the setLocalPrimaryImage operation in the admin unit workflow.
  void setLocalPrimaryImage(int index) {
    setState(() {
      _primaryLocalImageIndex = index;
    });
    showSuccessSnackBar('تم تعيين الصورة كرئيسية');
  }

  // 9. _buildHeaderActions
  /// ينفذ هذا الأسلوب عملية buildHeaderActions ضمن مسار إدارة الوحدات.
  /// This method performs the buildHeaderActions operation in the admin unit workflow.
  Widget buildHeaderActions(bool isSelectionMode) {
    return Row(
      children: [
        if (!_isReorderMode)
          buildActionChip(
            icon: isSelectionMode
                ? Icons.close_rounded
                : Icons.check_circle_outline_rounded,
            label: isSelectionMode ? 'إلغاء' : 'تحديد',
            onTap: () {
              HapticFeedback.lightImpact();
              toggleSelectionMode();
            },
            isActive: isSelectionMode,
          ),
        const SizedBox(width: 8),
        if (!isSelectionMode && _displayImages.length > 1)
          buildActionChip(
            icon: _isReorderMode ? Icons.done_rounded : Icons.swap_vert_rounded,
            label: _isReorderMode ? 'تم' : 'ترتيب',
            onTap: () {
              HapticFeedback.lightImpact();
              toggleReorderMode();
            },
            isActive: _isReorderMode,
          ),
        if (isSelectionMode && _selectedImageIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: buildActionChip(
              icon: Icons.delete_outline_rounded,
              label: 'حذف',
              onTap: deleteSelectedImages,
              isDestructive: true,
            ),
          ),
      ],
    );
  }

  // 10. _buildActionChip
  /// ينفذ هذا الأسلوب عملية buildActionChip ضمن مسار إدارة الوحدات.
  /// This method performs the buildActionChip operation in the admin unit workflow.
  Widget buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppTheme.error.withValues(alpha: 0.1)
              : isActive
                  ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDestructive
                ? AppTheme.error.withValues(alpha: 0.3)
                : isActive
                    ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isDestructive
                  ? AppTheme.error
                  : isActive
                      ? AppTheme.primaryBlue
                      : Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isDestructive
                    ? AppTheme.error
                    : isActive
                        ? AppTheme.primaryBlue
                        : Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 11. _toggleSelectionMode
  /// ينفذ هذا الأسلوب عملية toggleSelectionMode ضمن مسار إدارة الوحدات.
  /// This method performs the toggleSelectionMode operation in the admin unit workflow.
  void toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedImageIds.clear();
        _selectedLocalIndices.clear();
        if (_imagesBloc != null) {
          _imagesBloc!.add(const DeselectAllUnitImagesEvent());
        }
        _selectionController.reverse();
      } else {
        _isReorderMode = false;
        _selectionController.forward();
      }
    });
  }

  // 12. _toggleReorderMode
  /// ينفذ هذا الأسلوب عملية toggleReorderMode ضمن مسار إدارة الوحدات.
  /// This method performs the toggleReorderMode operation in the admin unit workflow.
  void toggleReorderMode() {
    setState(() {
      _isReorderMode = !_isReorderMode;
      if (_isReorderMode) {
        _isSelectionMode = false;
        _selectedImageIds.clear();
      }
    });
  }

  // 13. _buildMinimalistLoadingState
  /// ينفذ هذا الأسلوب عملية buildMinimalistLoadingState ضمن مسار إدارة الوحدات.
  /// This method performs the buildMinimalistLoadingState operation in the admin unit workflow.
  Widget buildMinimalistLoadingState() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryBlue.withValues(alpha: 0.5)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'جاري التحميل...',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted.withValues(alpha: 0.5),
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 14. _buildMinimalistEmptyState
  /// ينفذ هذا الأسلوب عملية buildMinimalistEmptyState ضمن مسار إدارة الوحدات.
  /// This method performs the buildMinimalistEmptyState operation in the admin unit workflow.
  Widget buildMinimalistEmptyState() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              color: AppTheme.textMuted.withValues(alpha: 0.3),
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد وسائط',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted.withValues(alpha: 0.5),
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 15. _buildReorderableGrid
  /// ينفذ هذا الأسلوب عملية buildReorderableGrid ضمن مسار إدارة الوحدات.
  /// This method performs the buildReorderableGrid operation in the admin unit workflow.
  Widget buildReorderableGrid(List<UnitImage> images) {
    return ReorderableWrap(
      spacing: 8,
      runSpacing: 8,
      needsLongPressDraggable: false,
      children: images.asMap().entries.map((entry) {
        final index = entry.key;
        final image = entry.value;
        return buildReorderableImageItem(image, index);
      }).toList(),
      onReorder: (oldIndex, newIndex) {
        reorderImages(oldIndex, newIndex);
      },
    );
  }

  // 16. _buildReorderableImageItem
  /// ينفذ هذا الأسلوب عملية buildReorderableImageItem ضمن مسار إدارة الوحدات.
  /// This method performs the buildReorderableImageItem operation in the admin unit workflow.
  Widget buildReorderableImageItem(UnitImage image, int index) {
    final isPrimary = index == _primaryImageIndex;
    final isVideo = image.isVideo;

    return Container(
      key: ValueKey(image.id),
      width: (MediaQuery.of(context).size.width - 56) / 3,
      height: (MediaQuery.of(context).size.width - 56) / 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: isVideo
                ? buildRemoteVideoThumbnail(image)
                : buildOptimizedImage(image),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.drag_indicator_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          if (isPrimary && !isVideo)
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'رئيسية',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 17. _reorderImages
  /// ينفذ هذا الأسلوب عملية reorderImages ضمن مسار إدارة الوحدات.
  /// This method performs the reorderImages operation in the admin unit workflow.
  void reorderImages(int oldIndex, int newIndex) {
    setState(() {
      final image = _displayImages.removeAt(oldIndex);
      _displayImages.insert(newIndex, image);

      if (_primaryImageIndex == oldIndex) {
        _primaryImageIndex = newIndex;
      } else if (oldIndex < _primaryImageIndex! &&
          newIndex >= _primaryImageIndex!) {
        _primaryImageIndex = _primaryImageIndex! - 1;
      } else if (oldIndex > _primaryImageIndex! &&
          newIndex <= _primaryImageIndex!) {
        _primaryImageIndex = _primaryImageIndex! + 1;
      }
    });

    if (_imagesBloc != null &&
        (widget.unitId != null || widget.tempKey != null)) {
      _imagesBloc!.add(ReorderUnitImagesEvent(
        unitId: widget.unitId,
        tempKey: widget.tempKey,
        imageIds: _displayImages.map((img) => img.id).toList(),
      ));
    }

    if (widget.onImagesChanged != null) {
      widget.onImagesChanged!(_displayImages);
    }
  }

  // 18. _showMediaOptionsMenu
  /// ينفذ هذا الأسلوب عملية showMediaOptionsMenu ضمن مسار إدارة الوحدات.
  /// This method performs the showMediaOptionsMenu operation in the admin unit workflow.
  void showMediaOptionsMenu(UnitImage media, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MediaOptionsSheet(
        media: media,
        index: index,
        isPrimary: index == _primaryImageIndex,
        isVideo: media.isVideo,
        onSetPrimary: !media.isVideo
            ? () {
                Navigator.pop(context);
                setPrimaryImage(index);
              }
            : null,
        onDelete: () {
          Navigator.pop(context);
          confirmDeleteImage(media);
        },
        onView: () {
          Navigator.pop(context);
          if (media.isVideo) {
            previewVideo(media);
          } else {
            previewImage(media);
          }
        },
      ),
    );
  }

  // 19. _setPrimaryImage
  /// ينفذ هذا الأسلوب عملية setPrimaryImage ضمن مسار إدارة الوحدات.
  /// This method performs the setPrimaryImage operation in the admin unit workflow.
  void setPrimaryImage(int index) {
    setState(() {
      _primaryImageIndex = index;
    });

    if (_imagesBloc != null &&
        (widget.unitId != null || widget.tempKey != null) &&
        index < _displayImages.length) {
      _imagesBloc!.add(SetPrimaryUnitImageEvent(
        unitId: widget.unitId,
        tempKey: widget.tempKey,
        imageId: _displayImages[index].id,
      ));
    }

    showSuccessSnackBar('تم تعيين الصورة كرئيسية');
  }

  // 20. _confirmDeleteImage
  /// ينفذ هذا الأسلوب عملية confirmDeleteImage ضمن مسار إدارة الوحدات.
  /// This method performs the confirmDeleteImage operation in the admin unit workflow.
  void confirmDeleteImage(UnitImage media) {
    showDialog(
      fullscreenDialog: true,
      context: context,
      builder: (context) => _DeleteConfirmationDialog(
        count: 1,
        onConfirm: () {
          Navigator.pop(context);

          if (_imagesBloc != null) {
            HapticFeedback.lightImpact();
            _imagesBloc!.add(DeleteUnitImageEvent(imageId: media.id));
          }

          setState(() {
            final index =
                _displayImages.indexWhere((img) => img.id == media.id);
            if (index != -1) {
              _displayImages.removeAt(index);
              if (_primaryImageIndex == index) {
                _primaryImageIndex = 0;
              } else if (_primaryImageIndex! > index) {
                _primaryImageIndex = _primaryImageIndex! - 1;
              }
            }
          });

          showSuccessSnackBar(
              media.isVideo ? 'تم حذف الفيديو' : 'تم حذف الصورة');
        },
      ),
    );
  }

  // 21. _deleteSelectedImages
  /// ينفذ هذا الأسلوب عملية deleteSelectedImages ضمن مسار إدارة الوحدات.
  /// This method performs the deleteSelectedImages operation in the admin unit workflow.
  void deleteSelectedImages() {
    if (_selectedImageIds.isEmpty) return;

    showDialog(
      fullscreenDialog: true,
      context: context,
      builder: (context) => _DeleteConfirmationDialog(
        count: _selectedImageIds.length,
        onConfirm: () {
          Navigator.pop(context);

          if (_imagesBloc != null) {
            _imagesBloc!.add(DeleteMultipleUnitImagesEvent(
              imageIds: _selectedImageIds.toList(),
            ));
          }

          setState(() {
            _displayImages
                .removeWhere((img) => _selectedImageIds.contains(img.id));
            _selectedImageIds.clear();
            _isSelectionMode = false;
          });

          showSuccessSnackBar('تم حذف الوسائط المحددة');
        },
      ),
    );
  }

  // 22. _buildOptimizedImage
  /// ينفذ هذا الأسلوب عملية buildOptimizedImage ضمن مسار إدارة الوحدات.
  /// This method performs the buildOptimizedImage operation in the admin unit workflow.
  Widget buildOptimizedImage(UnitImage image) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.of(context).devicePixelRatio;
        final targetWidth = (constraints.maxWidth.isFinite
                ? constraints.maxWidth * dpr
                : 256 * dpr)
            .clamp(64, 1024)
            .round();
        return CachedNetworkImage(
          imageUrl: image.url,
          fadeInDuration: const Duration(milliseconds: 0),
          imageBuilder: (ctx, provider) => Image(
            image: ResizeImage(provider, width: targetWidth),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
          ),
          placeholder: (context, url) => Container(
            color: AppTheme.darkCard.withValues(alpha: 0.3),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppTheme.darkCard.withValues(alpha: 0.3),
            child: Icon(
              Icons.image_not_supported_outlined,
              color: AppTheme.textMuted.withValues(alpha: 0.3),
              size: 24,
            ),
          ),
        );
      },
    );
  }

  // 23. _buildImageFromPath
  /// ينفذ هذا الأسلوب عملية _buildImageFromPath ضمن مسار إدارة الوحدات.
  /// This method performs the _buildImageFromPath operation in the admin unit workflow.
  Widget _buildImageFromPath(String path) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.of(context).devicePixelRatio;
        final targetWidth = (constraints.maxWidth.isFinite
                ? constraints.maxWidth * dpr
                : 256 * dpr)
            .clamp(64, 1024)
            .round();
        if (path.startsWith('http')) {
          return CachedNetworkImage(
            imageUrl: path,
            fadeInDuration: const Duration(milliseconds: 0),
            imageBuilder: (ctx, provider) => Image(
              image: ResizeImage(provider, width: targetWidth),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
            ),
            placeholder: (context, url) => Container(
              color: AppTheme.darkCard.withValues(alpha: 0.3),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppTheme.darkCard.withValues(alpha: 0.3),
              child: Icon(
                Icons.image_not_supported_outlined,
                color: AppTheme.textMuted.withValues(alpha: 0.3),
                size: 24,
              ),
            ),
          );
        } else {
          return Image.file(
            File(path),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
            cacheWidth: targetWidth,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppTheme.darkCard.withValues(alpha: 0.3),
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppTheme.textMuted.withValues(alpha: 0.3),
                  size: 24,
                ),
              );
            },
          );
        }
      },
    );
  }

  // 24. _buildQuickActionButton
  /// ينفذ هذا الأسلوب عملية buildQuickActionButton ضمن مسار إدارة الوحدات.
  /// This method performs the buildQuickActionButton operation in the admin unit workflow.
  Widget buildQuickActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color?.withValues(alpha: 0.3) ??
                AppTheme.darkBorder.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          color: color?.withValues(alpha: 0.9) ??
              AppTheme.textWhite.withValues(alpha: 0.8),
          size: 14,
        ),
      ),
    );
  }

  // 25. _handleStateChanges
  /// ينفذ هذا الأسلوب عملية handleStateChanges ضمن مسار إدارة الوحدات.
  /// This method performs the handleStateChanges operation in the admin unit workflow.
  void handleStateChanges(UnitImagesState state) {
    if (state is UnitImagesLoaded) {
      setState(() {
        _displayImages = state.images;
        _primaryImageIndex =
            state.images.indexWhere((img) => img.isPrimary == true);
        if (_primaryImageIndex == -1) _primaryImageIndex = 0;
      });
      if (widget.onImagesChanged != null) {
        widget.onImagesChanged!(state.images);
      }
    } else if (state is UnitImageUploaded) {
      setState(() {
        _displayImages = state.allImages;
        _uploadingFiles.clear();
        _uploadingFileObjects.clear();
        _uploadProgress.clear();
      });
      showSuccessSnackBar('تم رفع الوسائط بنجاح');
      if (widget.onImagesChanged != null) {
        widget.onImagesChanged!(state.allImages);
      }
    } else if (state is MultipleImagesUploaded) {
      setState(() {
        _displayImages = state.allImages;
        _uploadingFiles.clear();
        _uploadingFileObjects.clear();
        _uploadProgress.clear();
      });
      showSuccessSnackBar(
        'تم رفع ${state.successCount} ملف بنجاح${state.failedCount > 0 ? ' (${state.failedCount} فشلت)' : ''}',
      );
      if (widget.onImagesChanged != null) {
        widget.onImagesChanged!(state.allImages);
      }
    } else if (state is UnitImageDeleted) {
      setState(() {
        _displayImages = state.remainingImages;
      });
      showSuccessSnackBar('تم حذف الوسائط');
      if (widget.onImagesChanged != null) {
        widget.onImagesChanged!(state.remainingImages);
      }
    } else if (state is UnitImagesError) {
      setState(() {
        _uploadingFiles.clear();
        _uploadingFileObjects.clear();
        _uploadProgress.clear();
      });
      showErrorSnackBar(state.message);
    } else if (state is UnitImageUploading) {
      if (state.uploadingFileName != null && state.uploadProgress != null) {
        setState(() {
          _uploadingFiles.forEach((key, value) {
            if (_uploadingFileObjects[key]
                    ?.path
                    .endsWith(state.uploadingFileName!) ??
                false) {
              _uploadProgress[key] = state.uploadProgress!;
            }
          });
        });
      }
    }
  }

  // 26. _getImagesFromState
  /// ينفذ هذا الأسلوب عملية getImagesFromState ضمن مسار إدارة الوحدات.
  /// This method performs the getImagesFromState operation in the admin unit workflow.
  List<UnitImage> getImagesFromState(UnitImagesState state) {
    if (state is UnitImagesLoaded) return state.images;
    if (state is UnitImageUploaded) return state.allImages;
    if (state is MultipleImagesUploaded) return state.allImages;
    if (state is UnitImageDeleted) return state.remainingImages;
    if (state is MultipleImagesDeleted) return state.remainingImages;
    if (state is ImagesReordered) return state.reorderedImages;
    if (state is PrimaryImageSet) return state.updatedImages;
    if (state is UnitImageUpdated) return state.updatedImages;
    if (state is UnitImageUploading) return state.currentImages;
    if (state is UnitImageDeleting) return state.currentImages;
    if (state is UnitImageUpdating) return state.currentImages;
    if (state is ImagesReordering) return state.currentImages;
    if (state is UnitImagesError) return state.previousImages ?? [];
    return widget.initialImages ?? _remoteImages;
  }

  // 27. _showSuccessSnackBar
  /// ينفذ هذا الأسلوب عملية showSuccessSnackBar ضمن مسار إدارة الوحدات.
  /// This method performs the showSuccessSnackBar operation in the admin unit workflow.
  void showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.success.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 28. _showErrorSnackBar
  /// ينفذ هذا الأسلوب عملية showErrorSnackBar ضمن مسار إدارة الوحدات.
  /// This method performs the showErrorSnackBar operation in the admin unit workflow.
  void showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.error.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية buildEnhancedHeader ضمن مسار إدارة الوحدات.
  /// This method performs the buildEnhancedHeader operation in the admin unit workflow.
  Widget buildEnhancedHeader(int totalCount, UnitImagesState state) {
    final isSelectionMode =
        state is UnitImagesLoaded ? state.isSelectionMode : _isSelectionMode;
    final selectedCount = state is UnitImagesLoaded
        ? state.selectedImageIds.length
        : _selectedImageIds.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSelectionMode
                        ? 'تم تحديد $selectedCount'
                        : _isReorderMode
                            ? 'ترتيب الوسائط'
                            : 'معرض الوسائط',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'صور: $_imageCount/${widget.maxImages} • فيديو: $_videoCount/${widget.maxVideos}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              if (!widget.isReadOnly && totalCount > 0)
                buildHeaderActions(isSelectionMode),
            ],
          ),
          if (_isSelectionMode || _isReorderMode)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isSelectionMode
                        ? Icons.info_outline_rounded
                        : Icons.drag_indicator_rounded,
                    size: 14,
                    color: AppTheme.primaryBlue.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isSelectionMode
                        ? 'اضغط على الوسائط لتحديدها'
                        : 'اسحب الوسائط لإعادة ترتيبها',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية buildEnhancedUploadProgressCards ضمن مسار إدارة الوحدات.
  /// This method performs the buildEnhancedUploadProgressCards operation in the admin unit workflow.
  Widget buildEnhancedUploadProgressCards() {
    return Column(
      children: _uploadingFiles.entries.map((entry) {
        final progress = _uploadProgress[entry.key] ?? 0.0;
        final file = _uploadingFileObjects[entry.key];
        final fileType = _uploadingFileTypes[entry.key] ?? 'image';
        return buildEnhancedUploadProgressCard(
            entry.key, progress, file, fileType);
      }).toList(),
    );
  }

  /// ينفذ هذا الأسلوب عملية buildEnhancedUploadProgressCard ضمن مسار إدارة الوحدات.
  /// This method performs the buildEnhancedUploadProgressCard operation in the admin unit workflow.
  Widget buildEnhancedUploadProgressCard(
      String fileKey, double progress, File? file, String fileType) {
    final fileName = file?.path.split('/').last ?? 'ملف';
    final isComplete = progress >= 1.0;
    final isVideo = fileType == 'video';

    return AnimatedBuilder(
      animation: _uploadAnimationController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkCard.withValues(alpha: 0.4),
                AppTheme.darkCard.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isComplete
                  ? AppTheme.success.withValues(alpha: 0.3)
                  : AppTheme.primaryBlue.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isComplete
                    ? AppTheme.success.withValues(alpha: 0.1)
                    : AppTheme.primaryBlue.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Thumbnail
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.darkBorder.withValues(alpha: 0.2),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: buildUploadThumbnail(file, isVideo),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isVideo ? Icons.videocam : Icons.image,
                                size: 14,
                                color:
                                    AppTheme.primaryBlue.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  fileName,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppTheme.textWhite
                                        .withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: isComplete
                                    ? Container(
                                        key: const ValueKey('complete'),
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.success
                                              .withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check_rounded,
                                          size: 14,
                                          color: AppTheme.success,
                                        ),
                                      )
                                    : AnimatedBuilder(
                                        key: const ValueKey('uploading'),
                                        animation: _pulseController,
                                        builder: (context, child) {
                                          return Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppTheme.primaryBlue
                                                  .withValues(
                                                      alpha: 0.1 +
                                                          (_pulseController
                                                                  .value *
                                                              0.1)),
                                            ),
                                            child: Icon(
                                              Icons.cloud_upload_outlined,
                                              size: 14,
                                              color: AppTheme.primaryBlue,
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Progress Bar
                          Stack(
                            children: [
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppTheme.darkBorder
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 4,
                                width: MediaQuery.of(context).size.width *
                                    progress *
                                    0.65,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isComplete
                                        ? [
                                            AppTheme.success,
                                            AppTheme.success
                                                .withValues(alpha: 0.7)
                                          ]
                                        : [
                                            AppTheme.primaryBlue,
                                            AppTheme.primaryBlue
                                                .withValues(alpha: 0.7)
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isComplete
                                          ? AppTheme.success
                                              .withValues(alpha: 0.3)
                                          : AppTheme.primaryBlue
                                              .withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),
                          Text(
                            isComplete
                                ? 'اكتمل الرفع'
                                : 'جاري الرفع... ${(progress * 100).toInt()}%',
                            style: AppTextStyles.caption.copyWith(
                              color: isComplete
                                  ? AppTheme.success.withValues(alpha: 0.8)
                                  : AppTheme.textMuted.withValues(alpha: 0.7),
                              fontSize: 11,
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
      },
    );
  }

  /// ينفذ هذا الأسلوب عملية buildUploadThumbnail ضمن مسار إدارة الوحدات.
  /// This method performs the buildUploadThumbnail operation in the admin unit workflow.
  Widget buildUploadThumbnail(File? file, bool isVideo) {
    if (file == null) {
      return Container(
        color: AppTheme.darkCard.withValues(alpha: 0.5),
        child: Icon(
          isVideo ? Icons.videocam_outlined : Icons.image_outlined,
          color: AppTheme.textMuted.withValues(alpha: 0.5),
          size: 24,
        ),
      );
    }

    if (isVideo) {
      final thumbnail = _videoThumbnails[file.path];
      if (thumbnail != null && File(thumbnail).existsSync()) {
        return Image.file(
          File(thumbnail),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => buildVideoPlaceholder(),
        );
      }
      return buildVideoPlaceholder();
    }

    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppTheme.darkCard.withValues(alpha: 0.5),
          child: Icon(
            Icons.image_outlined,
            color: AppTheme.textMuted.withValues(alpha: 0.5),
            size: 24,
          ),
        );
      },
    );
  }

  /// ينفذ هذا الأسلوب عملية buildMainContent ضمن مسار إدارة الوحدات.
  /// This method performs the buildMainContent operation in the admin unit workflow.
  Widget buildMainContent(List<UnitImage> images, UnitImagesState state) {
    if (state is UnitImagesLoading && images.isEmpty) {
      return buildMinimalistLoadingState();
    }

    final canAddMore =
        (_imageCount < widget.maxImages) || (_videoCount < widget.maxVideos);

    return Column(
      key: ValueKey('content-${images.length}-$_isReorderMode'),
      children: [
        // Upload Area
        if (!widget.isReadOnly &&
            canAddMore &&
            _uploadingFiles.isEmpty &&
            !_isSelectionMode &&
            !_isReorderMode)
          buildMinimalistUploadArea(),

        // Images Grid
        if (images.isNotEmpty) ...[
          if (!widget.isReadOnly &&
              canAddMore &&
              !_isSelectionMode &&
              !_isReorderMode)
            const SizedBox(height: 24),
          _isReorderMode
              ? buildReorderableGrid(images)
              : buildEnhancedImagesGrid(images, state),
        ],

        // Empty State
        if (images.isEmpty && widget.isReadOnly) buildMinimalistEmptyState(),
      ],
    );
  }

  /// ينفذ هذا الأسلوب عملية buildEnhancedImagesGrid ضمن مسار إدارة الوحدات.
  /// This method performs the buildEnhancedImagesGrid operation in the admin unit workflow.
  Widget buildEnhancedImagesGrid(
      List<UnitImage> images, UnitImagesState state) {
    final selectedImageIds =
        state is UnitImagesLoaded ? state.selectedImageIds : _selectedImageIds;
    final isSelectionMode =
        state is UnitImagesLoaded ? state.isSelectionMode : _isSelectionMode;

    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 275),
            columnCount: 3,
            child: ScaleAnimation(
              scale: 0.95,
              child: FadeInAnimation(
                child: buildEnhancedMediaItem(
                  images[index],
                  index,
                  selectedImageIds.contains(images[index].id),
                  isSelectionMode,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية buildEnhancedMediaItem ضمن مسار إدارة الوحدات.
  /// This method performs the buildEnhancedMediaItem operation in the admin unit workflow.
  Widget buildEnhancedMediaItem(
    UnitImage media,
    int index,
    bool isSelected,
    bool isSelectionMode,
  ) {
    final bool isHovered = _hoveredIndex == index;
    final bool isPrimary = index == _primaryImageIndex;
    final bool isVideo = media.isVideo;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: () {
          if (isSelectionMode) {
            HapticFeedback.lightImpact();
            if (_imagesBloc != null) {
              _imagesBloc!
                  .add(ToggleUnitImageSelectionEvent(imageId: media.id));
            } else {
              setState(() {
                if (_selectedImageIds.contains(media.id)) {
                  _selectedImageIds.remove(media.id);
                } else {
                  _selectedImageIds.add(media.id);
                }
              });
            }
          } else {
            if (isVideo) {
              previewVideo(media);
            } else {
              previewImage(media);
            }
          }
        },
        onLongPress: () {
          if (!widget.isReadOnly && !isSelectionMode) {
            HapticFeedback.mediumImpact();
            showMediaOptionsMenu(media, index);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(isHovered || isSelected ? 0.95 : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryBlue.withValues(alpha: 0.6)
                  : AppTheme.darkBorder.withValues(alpha: 0.1),
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Media content
                if (isVideo)
                  buildRemoteVideoThumbnail(media)
                else
                  buildOptimizedImage(media),

                // Gradient Overlay
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(
                            alpha: isHovered || isSelectionMode ? 0.6 : 0.3),
                      ],
                    ),
                  ),
                ),

                // Video play button
                if (isVideo)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.darkCard.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                // Quick Actions
                if (!widget.isReadOnly && !isSelectionMode)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    top: isHovered ? 8 : -40,
                    left: 8,
                    right: 8,
                    child: buildQuickActions(
                      onView: () =>
                          isVideo ? previewVideo(media) : previewImage(media),
                      onSetPrimary: !isVideo && !isPrimary
                          ? () => setPrimaryImage(index)
                          : null,
                      onDelete: () => confirmDeleteImage(media),
                    ),
                  ),

                // Media type badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isVideo
                          ? AppTheme.info.withValues(alpha: 0.8)
                          : AppTheme.darkCard.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isVideo ? Icons.videocam : Icons.image,
                          size: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          isVideo ? media.durationFormatted : '${index + 1}',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Primary Badge
                if (isPrimary && !isVideo)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.warning.withValues(alpha: 0.3),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'رئيسية',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Selection Checkbox
                if (isSelectionMode)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryBlue
                            : AppTheme.darkCard.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية buildRemoteVideoThumbnail ضمن مسار إدارة الوحدات.
  /// This method performs the buildRemoteVideoThumbnail operation in the admin unit workflow.
  Widget buildRemoteVideoThumbnail(UnitImage video) {
    // Try backend-provided poster unless it's an explicit placeholder
    final vt = (video.videoThumbnail ?? '').trim();
    final isPlaceholder = vt.isEmpty || vt.contains('via.placeholder.com');
    final firstChoice = !isPlaceholder ? ImageUtils.resolveUrl(vt) : '';
    final secondChoice = ImageUtils.resolveUrl(video.thumbnails.hd.isNotEmpty
        ? video.thumbnails.hd
        : video.thumbnails.medium);

    // Guard against attempting to render a non-image URL as an image
    final candidates =
        [firstChoice, secondChoice].where((u) => u.isNotEmpty).toList();
    String displayUrl = '';
    for (final u in candidates) {
      final lower = u.toLowerCase();
      final looksLikeImage = lower.endsWith('.png') ||
          lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.webp') ||
          lower.contains('image');
      if (looksLikeImage) {
        displayUrl = u;
        break;
      }
    }
    if (displayUrl.isEmpty) return buildVideoPlaceholder();

    return CachedNetworkImage(
      imageUrl: displayUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => buildVideoPlaceholder(),
      errorWidget: (context, url, error) => buildVideoPlaceholder(),
    );
  }

  /// ينفذ هذا الأسلوب عملية buildMinimalistUploadArea ضمن مسار إدارة الوحدات.
  /// This method performs the buildMinimalistUploadArea operation in the admin unit workflow.
  Widget buildMinimalistUploadArea() {
    final canAddImages = _isLocalMode
        ? _localImageCount < widget.maxImages
        : _imageCount < widget.maxImages;
    final canAddVideos = _isLocalMode
        ? _localVideoCount < widget.maxVideos
        : _videoCount < widget.maxVideos;

    return GestureDetector(
      onTap: showImagePickerOptions,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 140,
        decoration: BoxDecoration(
          color: _isDragging
              ? AppTheme.primaryBlue.withValues(alpha: 0.05)
              : AppTheme.darkCard.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isDragging
                ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                : AppTheme.darkBorder.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: DragTarget<List<XFile>>(
          onWillAcceptWithDetails: (details) {
            setState(() => _isDragging = true);
            return true;
          },
          onLeave: (data) {
            setState(() => _isDragging = false);
          },
          onAcceptWithDetails: (details) {
            setState(() => _isDragging = false);
            _handleDroppedFiles(details.data);
          },
          builder: (context, candidateData, rejectedData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isDragging
                        ? Icons.file_download_outlined
                        : Icons.add_photo_alternate_outlined,
                    color: _isDragging
                        ? AppTheme.primaryBlue.withValues(alpha: 0.8)
                        : AppTheme.textMuted.withValues(alpha: 0.5),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isDragging
                        ? 'أفلت الملفات هنا'
                        : 'اضغط أو اسحب لإضافة صور أو فيديو',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textMuted.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (!canAddImages && !canAddVideos)
                    Text(
                      'وصلت للحد الأقصى',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.error.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                      ),
                    )
                  else
                    Text(
                      'صور: PNG, JPG • فيديو: MP4, MOV • Max ${AppConstants.maxVideoUploadSize ~/ (1024 * 1024)}MB',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية showImagePickerOptions ضمن مسار إدارة الوحدات.
  /// This method performs the showImagePickerOptions operation in the admin unit workflow.
  void showImagePickerOptions() {
    final canAddImages = _isLocalMode
        ? _localImageCount < widget.maxImages
        : _imageCount < widget.maxImages;
    final canAddVideos = _isLocalMode
        ? _localVideoCount < widget.maxVideos
        : _videoCount < widget.maxVideos;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MinimalistImagePickerSheet(
        onCameraSelected: canAddImages
            ? () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              }
            : null,
        onGallerySelected: canAddImages
            ? () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              }
            : null,
        onMultipleSelected: canAddImages
            ? () {
                Navigator.pop(context);
                pickMultipleImages();
              }
            : null,
        onVideoSelected: canAddVideos
            ? () {
                Navigator.pop(context);
                pickVideo();
              }
            : null,
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية previewVideo ضمن مسار إدارة الوحدات.
  /// This method performs the previewVideo operation in the admin unit workflow.
  void previewVideo(UnitImage video) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _VideoPreviewScreen(
              videoUrl: video.url,
              isLocal: false,
            ),
          );
        },
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية previewLocalVideo ضمن مسار إدارة الوحدات.
  /// This method performs the previewLocalVideo operation in the admin unit workflow.
  void previewLocalVideo(String videoPath) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _VideoPreviewScreen(
              videoUrl: videoPath,
              isLocal: true,
            ),
          );
        },
      ),
    );
  }

  // بقية الدوال كما هي مع الدوال المساعدة...

  /// ينفذ هذا الأسلوب عملية previewImage ضمن مسار إدارة الوحدات.
  /// This method performs the previewImage operation in the admin unit workflow.
  void previewImage(UnitImage image) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _MinimalistImagePreview(image: image),
          );
        },
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية previewLocalImage ضمن مسار إدارة الوحدات.
  /// This method performs the previewLocalImage operation in the admin unit workflow.
  void previewLocalImage(String imagePath) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _MinimalistLocalImagePreview(imagePath: imagePath),
          );
        },
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _showSuccessSnackBar ضمن مسار إدارة الوحدات.
  /// This method performs the _showSuccessSnackBar operation in the admin unit workflow.
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.success.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _handleDroppedFiles ضمن مسار إدارة الوحدات.
  /// This method performs the _handleDroppedFiles operation in the admin unit workflow.
  void _handleDroppedFiles(List<XFile> files) {
    if (files.isNotEmpty) {
      final images = <XFile>[];
      final videos = <XFile>[];

      for (var file in files) {
        if (AppConstants.isVideoFile(file.path)) {
          videos.add(file);
        } else if (AppConstants.isImageFile(file.path)) {
          images.add(file);
        }
      }

      final remainingImageSlots =
          widget.maxImages - (_isLocalMode ? _localImageCount : _imageCount);
      final remainingVideoSlots =
          widget.maxVideos - (_isLocalMode ? _localVideoCount : _videoCount);

      final imagesToAdd = images.take(remainingImageSlots).toList();
      final videosToAdd = videos.take(remainingVideoSlots).toList();

      final allFilesToAdd = [...imagesToAdd, ...videosToAdd];

      if (allFilesToAdd.isNotEmpty) {
        if (_isLocalMode) {
          setState(() {
            _localImages.addAll(allFilesToAdd.map((file) => file.path));
            if (_primaryLocalImageIndex == null && _localImages.isNotEmpty) {
              _primaryLocalImageIndex = 0;
            }
          });

          // Generate thumbnails for videos
          for (var video in videosToAdd) {
            VideoUtils.generateVideoThumbnail(video.path).then((thumbnail) {
              if (mounted && thumbnail != null) {
                setState(() {
                  _videoThumbnails[video.path] = thumbnail;
                });
              }
            });
          }

          if (widget.onLocalImagesChanged != null) {
            widget.onLocalImagesChanged!(_localImages);
          }
          _showSuccessSnackBar(
              'تم إضافة ${allFilesToAdd.length} ملف (سيتم الرفع عند الحفظ)');
        } else if (_imagesBloc != null &&
            (widget.unitId != null || widget.tempKey != null)) {
          setState(() {
            for (var file in allFilesToAdd) {
              final fileKey =
                  '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
              _uploadingFiles[fileKey] = true;
              _uploadingFileObjects[fileKey] = File(file.path);
              _uploadProgress[fileKey] = 0.0;
              _uploadingFileTypes[fileKey] =
                  AppConstants.isVideoFile(file.path) ? 'video' : 'image';
            }
          });

          _imagesBloc!.add(UploadMultipleUnitImagesEvent(
            unitId: widget.unitId,
            tempKey: widget.tempKey,
            filePaths: allFilesToAdd.map((file) => file.path).toList(),
          ));
        }
      }
    }
  }

  // بقية الدوال المساعدة الأخرى...
  // (نفس الكود الأصلي)
}

// Video Preview Screen
/// يمثل هذا الكلاس _VideoPreviewScreen البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for _VideoPreviewScreen in the admin unit workflow.
class _VideoPreviewScreen extends StatelessWidget {
  /// This field keeps the videoUrl value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة videoUrl التي يعتمد عليها مسار إدارة الوحدات.
  final String videoUrl;

  /// يحتفظ هذا الحقل بقيمة isLocal التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isLocal value used by the admin unit workflow.
  final bool isLocal;

  /// ينشئ هذا المُنشئ مثيلاً من _VideoPreviewScreen.
  /// This constructor creates an instance of _VideoPreviewScreen.
  const _VideoPreviewScreen({
    required this.videoUrl,
    required this.isLocal,
  });

  /// ينفذ هذا الأسلوب عملية build ضمن مسار إدارة الوحدات.
  /// This method performs the build operation in the admin unit workflow.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          Center(
            child: VideoPlayerWidget(
              videoPath: videoUrl,
              isLocal: isLocal,
              showControls: true,
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Local Media Options Sheet
/// يمثل هذا الكلاس _LocalMediaOptionsSheet البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for _LocalMediaOptionsSheet in the admin unit workflow.
class _LocalMediaOptionsSheet extends StatelessWidget {
  /// This field keeps the mediaPath value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة mediaPath التي يعتمد عليها مسار إدارة الوحدات.
  final String mediaPath;

  /// يحتفظ هذا الحقل بقيمة index التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the index value used by the admin unit workflow.
  final int index;

  /// يحتفظ هذا الحقل بقيمة isVideo التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isVideo value used by the admin unit workflow.
  final bool isVideo;

  /// يحتفظ هذا الحقل بقيمة isPrimary التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isPrimary value used by the admin unit workflow.
  final bool isPrimary;

  /// يحتفظ هذا الحقل بقيمة onSetPrimary التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the onSetPrimary value used by the admin unit workflow.
  final VoidCallback? onSetPrimary;

  /// يحتفظ هذا الحقل بقيمة onDelete التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the onDelete value used by the admin unit workflow.
  final VoidCallback onDelete;

  /// يحتفظ هذا الحقل بقيمة onView التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the onView value used by the admin unit workflow.
  final VoidCallback onView;

  /// ينشئ هذا المُنشئ مثيلاً من _LocalMediaOptionsSheet.
  /// This constructor creates an instance of _LocalMediaOptionsSheet.
  const _LocalMediaOptionsSheet({
    required this.mediaPath,
    required this.index,
    required this.isVideo,
    required this.isPrimary,
    this.onSetPrimary,
    required this.onDelete,
    required this.onView,
  });

  /// ينفذ هذا الأسلوب عملية build ضمن مسار إدارة الوحدات.
  /// This method performs the build operation in the admin unit workflow.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: AppTheme.darkBorder.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isVideo ? 'خيارات الفيديو' : 'خيارات الصورة',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 20),
          _buildOption(
            icon:
                isVideo ? Icons.play_arrow_rounded : Icons.visibility_outlined,
            title: isVideo ? 'تشغيل الفيديو' : 'عرض الصورة',
            onTap: onView,
          ),
          if (!isVideo && !isPrimary && onSetPrimary != null) ...[
            const SizedBox(height: 8),
            _buildOption(
              icon: Icons.star_outline_rounded,
              title: 'تعيين كصورة رئيسية',
              onTap: onSetPrimary!,
              color: AppTheme.warning,
            ),
          ],
          const SizedBox(height: 8),
          _buildOption(
            icon: Icons.delete_outline_rounded,
            title: isVideo ? 'حذف الفيديو' : 'حذف الصورة',
            onTap: onDelete,
            color: AppTheme.error,
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildOption ضمن مسار إدارة الوحدات.
  /// This method performs the _buildOption operation in the admin unit workflow.
  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color?.withValues(alpha: 0.1) ??
              AppTheme.darkCard.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color?.withValues(alpha: 0.8) ??
                  AppTheme.primaryBlue.withValues(alpha: 0.8),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: color ?? AppTheme.textWhite.withValues(alpha: 0.9),
                fontWeight: FontWeight.w300,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textMuted.withValues(alpha: 0.3),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

/// يمثل هذا الكلاس _DeleteConfirmationDialog البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for _DeleteConfirmationDialog in the admin unit workflow.
class _DeleteConfirmationDialog extends StatelessWidget {
  /// This field keeps the count value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة count التي يعتمد عليها مسار إدارة الوحدات.
  final int count;

  /// يحتفظ هذا الحقل بقيمة onConfirm التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the onConfirm value used by the admin unit workflow.
  final VoidCallback onConfirm;

  /// ينشئ هذا المُنشئ مثيلاً من _DeleteConfirmationDialog.
  /// This constructor creates an instance of _DeleteConfirmationDialog.
  const _DeleteConfirmationDialog({
    required this.count,
    required this.onConfirm,
  });

  /// ينفذ هذا الأسلوب عملية build ضمن مسار إدارة الوحدات.
  /// This method performs the build operation in the admin unit workflow.
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.error.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.error.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppTheme.error.withValues(alpha: 0.8),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'تأكيد الحذف',
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                count > 1
                    ? 'هل أنت متأكد من حذف $count صور؟'
                    : 'هل أنت متأكد من حذف هذه الصورة؟',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.darkBorder.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'إلغاء',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: AppTheme.textLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: onConfirm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'حذف',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    );
  }
}

// 29. _MinimalistImagePickerSheet
/// يمثل هذا الكلاس _MinimalistImagePickerSheet البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for _MinimalistImagePickerSheet in the admin unit workflow.
class _MinimalistImagePickerSheet extends StatelessWidget {
  /// This field keeps the onCameraSelected value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة onCameraSelected التي يعتمد عليها مسار إدارة الوحدات.
  final VoidCallback? onCameraSelected;

  /// يحتفظ هذا الحقل بقيمة onGallerySelected التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the onGallerySelected value used by the admin unit workflow.
  final VoidCallback? onGallerySelected;

  /// يحتفظ هذا الحقل بقيمة onMultipleSelected التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the onMultipleSelected value used by the admin unit workflow.
  final VoidCallback? onMultipleSelected;

  /// يحتفظ هذا الحقل بقيمة onVideoSelected التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the onVideoSelected value used by the admin unit workflow.
  final VoidCallback? onVideoSelected;

  /// ينشئ هذا المُنشئ مثيلاً من _MinimalistImagePickerSheet.
  /// This constructor creates an instance of _MinimalistImagePickerSheet.
  const _MinimalistImagePickerSheet({
    this.onCameraSelected,
    this.onGallerySelected,
    this.onMultipleSelected,
    this.onVideoSelected,
  });

  /// ينفذ هذا الأسلوب عملية build ضمن مسار إدارة الوحدات.
  /// This method performs the build operation in the admin unit workflow.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: AppTheme.darkBorder.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(height: 24),
          if (onCameraSelected != null)
            _buildOption(
              icon: Icons.camera_alt_outlined,
              title: 'الكاميرا',
              onTap: onCameraSelected!,
              disabled: false,
            ),
          if (onCameraSelected != null) const SizedBox(height: 8),
          if (onGallerySelected != null)
            _buildOption(
              icon: Icons.photo_outlined,
              title: 'صورة واحدة',
              onTap: onGallerySelected!,
              disabled: false,
            ),
          if (onGallerySelected != null) const SizedBox(height: 8),
          if (onMultipleSelected != null)
            _buildOption(
              icon: Icons.collections_outlined,
              title: 'عدة صور',
              onTap: onMultipleSelected!,
              disabled: false,
            ),
          if (onVideoSelected != null) ...[
            const SizedBox(height: 8),
            _buildOption(
              icon: Icons.video_library_outlined,
              title: 'فيديو',
              onTap: onVideoSelected!,
              disabled: false,
            ),
          ],
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildOption ضمن مسار إدارة الوحدات.
  /// This method performs the _buildOption operation in the admin unit workflow.
  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: disabled
              ? AppTheme.darkCard.withValues(alpha: 0.1)
              : AppTheme.darkCard.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: disabled
                  ? AppTheme.textMuted.withValues(alpha: 0.3)
                  : AppTheme.primaryBlue.withValues(alpha: 0.8),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: disabled
                    ? AppTheme.textMuted.withValues(alpha: 0.5)
                    : AppTheme.textWhite.withValues(alpha: 0.9),
                fontWeight: FontWeight.w300,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: disabled
                  ? AppTheme.textMuted.withValues(alpha: 0.2)
                  : AppTheme.textMuted.withValues(alpha: 0.3),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// 31. _MinimalistLocalImagePreview
/// يمثل هذا الكلاس _MinimalistLocalImagePreview البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for _MinimalistLocalImagePreview in the admin unit workflow.
class _MinimalistLocalImagePreview extends StatelessWidget {
  /// This field keeps the imagePath value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة imagePath التي يعتمد عليها مسار إدارة الوحدات.
  final String imagePath;

  /// ينشئ هذا المُنشئ مثيلاً من _MinimalistLocalImagePreview.
  /// This constructor creates an instance of _MinimalistLocalImagePreview.
  const _MinimalistLocalImagePreview({required this.imagePath});

  /// ينفذ هذا الأسلوب عملية build ضمن مسار إدارة الوحدات.
  /// This method performs the build operation in the admin unit workflow.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          Center(
            child: imagePath.startsWith('http')
                ? Image.network(imagePath, fit: BoxFit.contain)
                : Image.file(File(imagePath), fit: BoxFit.contain),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 33. _MediaOptionsSheet
/// يمثل هذا الكلاس _MediaOptionsSheet البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for _MediaOptionsSheet in the admin unit workflow.
class _MediaOptionsSheet extends StatelessWidget {
  /// This field keeps the media value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة media التي يعتمد عليها مسار إدارة الوحدات.
  final UnitImage media;

  /// يحتفظ هذا الحقل بقيمة index التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the index value used by the admin unit workflow.
  final int index;

  /// يحتفظ هذا الحقل بقيمة isPrimary التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isPrimary value used by the admin unit workflow.
  final bool isPrimary;

  /// يحتفظ هذا الحقل بقيمة isVideo التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isVideo value used by the admin unit workflow.
  final bool isVideo;

  /// يحتفظ هذا الحقل بقيمة onSetPrimary التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the onSetPrimary value used by the admin unit workflow.
  final VoidCallback? onSetPrimary;

  /// يحتفظ هذا الحقل بقيمة onDelete التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the onDelete value used by the admin unit workflow.
  final VoidCallback onDelete;

  /// يحتفظ هذا الحقل بقيمة onView التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the onView value used by the admin unit workflow.
  final VoidCallback onView;

  /// ينشئ هذا المُنشئ مثيلاً من _MediaOptionsSheet.
  /// This constructor creates an instance of _MediaOptionsSheet.
  const _MediaOptionsSheet({
    required this.media,
    required this.index,
    required this.isPrimary,
    required this.isVideo,
    this.onSetPrimary,
    required this.onDelete,
    required this.onView,
  });

  /// ينفذ هذا الأسلوب عملية build ضمن مسار إدارة الوحدات.
  /// This method performs the build operation in the admin unit workflow.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: AppTheme.darkBorder.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isVideo ? 'خيارات الفيديو' : 'خيارات الصورة',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 20),
          _buildOption(
            icon:
                isVideo ? Icons.play_arrow_rounded : Icons.visibility_outlined,
            title: isVideo ? 'تشغيل الفيديو' : 'عرض الصورة',
            onTap: onView,
          ),
          if (!isVideo && !isPrimary && onSetPrimary != null) ...[
            const SizedBox(height: 8),
            _buildOption(
              icon: Icons.star_outline_rounded,
              title: 'تعيين كصورة رئيسية',
              onTap: onSetPrimary!,
              color: AppTheme.warning,
            ),
          ],
          const SizedBox(height: 8),
          _buildOption(
            icon: Icons.delete_outline_rounded,
            title: isVideo ? 'حذف الفيديو' : 'حذف الصورة',
            onTap: onDelete,
            color: AppTheme.error,
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildOption ضمن مسار إدارة الوحدات.
  /// This method performs the _buildOption operation in the admin unit workflow.
  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color?.withValues(alpha: 0.1) ??
              AppTheme.darkCard.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color?.withValues(alpha: 0.8) ??
                  AppTheme.primaryBlue.withValues(alpha: 0.8),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: color ?? AppTheme.textWhite.withValues(alpha: 0.9),
                fontWeight: FontWeight.w300,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textMuted.withValues(alpha: 0.3),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

/// يمثل هذا الكلاس _MinimalistImagePreview البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for _MinimalistImagePreview in the admin unit workflow.
class _MinimalistImagePreview extends StatelessWidget {
  /// This field keeps the image value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة image التي يعتمد عليها مسار إدارة الوحدات.
  final UnitImage image;

  /// ينشئ هذا المُنشئ مثيلاً من _MinimalistImagePreview.
  /// This constructor creates an instance of _MinimalistImagePreview.
  const _MinimalistImagePreview({required this.image});

  /// ينفذ هذا الأسلوب عملية build ضمن مسار إدارة الوحدات.
  /// This method performs the build operation in the admin unit workflow.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          Center(
            child: CachedNetworkImage(
              imageUrl: image.url,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
