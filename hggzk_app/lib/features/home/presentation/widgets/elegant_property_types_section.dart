import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../domain/entities/property_type.dart';

/// يعرض شريط اختيار نوع العقار في الصفحة الرئيسية، ويعمل كنقطة البداية التي
/// تحدد بقية الفلاتر والحقول والسياق المعروض للمستخدم.
/// Renders the property-type selector on the home screen and acts as the
/// starting control that drives downstream filters, fields, and browsing
/// context.
class ElegantPropertyTypesSection extends StatefulWidget {
  /// أنواع العقارات المتاحة للاختيار في هذه الجلسة.
  /// Property types available for selection in the current session.
  final List<PropertyType> propertyTypes;

  /// معرّف النوع المحدد حاليًا إذا كانت هناك قيمة مستعادة أو اختيار سابق.
  /// Identifier of the currently selected type when a previous or restored
  /// value exists.
  final String? selectedTypeId;

  /// الاستدعاء الذي يحدّث الحالة العليا عندما يختار المستخدم نوعًا مختلفًا.
  /// Callback that updates higher-level state when the user chooses a
  /// different type.
  final Function(String?) onTypeSelected;

  /// ينشئ أداة الاختيار مع البيانات الحالية وربطها بمنطق التغيير الخارجي.
  /// Creates the selector with the current data and wires it to external
  /// selection logic.
  const ElegantPropertyTypesSection({
    super.key,
    required this.propertyTypes,
    this.selectedTypeId,
    required this.onTypeSelected,
  });

  /// ينشئ حالة الأداة التي تدير الحركات والانتقالات الخاصة بالقسم.
  /// Creates the widget state that manages the section's animations and
  /// transitions.
  @override
  State<ElegantPropertyTypesSection> createState() =>
      _ElegantPropertyTypesSectionState();
}

/// تدير الحركات الافتتاحية وسلوك فتح القائمة واختيار نوع العقار داخل القسم.
/// Manages the entrance animation, picker opening, and property-type selection
/// behavior inside the section.
class _ElegantPropertyTypesSectionState
    extends State<ElegantPropertyTypesSection> with TickerProviderStateMixin {
  /// متحكم الحركة الذي يطلق دخول القسم إلى الشاشة.
  /// Animation controller that drives the section entrance.
  late AnimationController _entranceController;

  /// متحكم اللمعان الخفيف المستخدم لإضافة حياة إلى الخلفية.
  /// Controller for the subtle shimmer that adds motion to the background.
  late AnimationController _shimmerController;

  /// حركة الشفافية التي تجعل القسم يظهر تدريجيًا.
  /// Fade animation that reveals the section progressively.
  late Animation<double> _fadeAnimation;

  /// حركة الانزلاق التي ترفع القسم إلى موضعه النهائي.
  /// Slide animation that lifts the section into its final position.
  late Animation<Offset> _slideAnimation;

  /// يجهز الحالة ويبدأ تسلسل الحركة فور إنشاء الأداة.
  /// Prepares state and starts the animation sequence as soon as the widget is
  /// created.
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  /// يهيئ جميع الحركات التي يعتمد عليها القسم عند الظهور.
  /// Configures the animations used when the section first appears.
  void _initializeAnimations() {
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuart),
    ));
  }

  /// يطلق الحركة بعد تأخير بسيط حتى لا يظهر القسم بشكل حاد عند فتح الصفحة.
  /// Starts the entrance animation after a short delay so the section does not
  /// appear too abruptly on page load.
  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  /// يحرر متحكمات الحركة عندما تغادر الأداة الشجرة.
  /// Releases the animation controllers when the widget leaves the tree.
  @override
  void dispose() {
    _entranceController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  /// يبني واجهة اختيار نوع العقار بالاعتماد على الأنواع الحالية والاختيار
  /// المفعّل.
  /// Builds the property-type selector using the available types and the
  /// currently active selection.
  @override
  Widget build(BuildContext context) {
    if (widget.propertyTypes.isEmpty) return const SizedBox.shrink();

    PropertyType? selectedProperty;
    if (widget.selectedTypeId != null) {
      for (final p in widget.propertyTypes) {
        if (p.id == widget.selectedTypeId) {
          selectedProperty = p;
          break;
        }
      }
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHintMessage(),
              const SizedBox(height: 12),
              _buildPickerButton(context, selectedProperty),
            ],
          ),
        ),
      ),
    );
  }

  /// يعرض رسالة قصيرة تشرح للمستخدم أن هذا الجزء يحدد مدخل التصفح الأساسي.
  /// Shows a brief hint telling the user that this control defines the primary
  /// browsing entry point.
  Widget _buildHintMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.18),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppTheme.textMuted.withOpacity(0.85),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'يرجى تحديد نوع العقار',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted.withOpacity(0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// يبني الزر الرئيسي الذي يعرض النوع الحالي ويفتح لوحة الاختيار التفصيلية.
  /// Builds the main launcher button that shows the current type and opens the
  /// detailed picker sheet.
  Widget _buildPickerButton(
    BuildContext context,
    PropertyType? selectedProperty,
  ) {
    final bool isSelected = selectedProperty != null;
    final Color baseColor = AppTheme.darkCard.withOpacity(0.35);
    final Color borderColor = isSelected
        ? AppTheme.primaryBlue.withOpacity(0.35)
        : AppTheme.darkBorder.withOpacity(0.18);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.selectionClick();
          _showPropertyTypePickerSheet(context, selectedProperty);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryBlue.withOpacity(0.12)
                      : AppTheme.darkCard.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryBlue.withOpacity(0.22)
                        : AppTheme.darkBorder.withOpacity(0.16),
                    width: 1,
                  ),
                ),
                child: Icon(
                  isSelected
                      ? IconMapper.getIconFromString(selectedProperty!.icon)
                      : Icons.category_rounded,
                  size: 18,
                  color: isSelected
                      ? AppTheme.primaryBlue.withOpacity(0.95)
                      : AppTheme.textMuted.withOpacity(0.75),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نوع العقار',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedProperty?.name ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textWhite.withOpacity(0.95),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.textMuted.withOpacity(0.75),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// يفتح اللوحة السفلية التي تسمح باستعراض جميع أنواع العقارات واختيار
  /// أحدها من قائمة قابلة للتمرير.
  /// Opens the bottom sheet that lets the user browse all property types and
  /// choose one from a scrollable list.
  Future<void> _showPropertyTypePickerSheet(
    BuildContext context,
    PropertyType? selectedProperty,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final ScrollController scrollController = ScrollController();
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.darkBackground.withOpacity(0.92),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              border: Border.all(
                color: AppTheme.darkBorder.withOpacity(0.18),
                width: 1,
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppTheme.textMuted.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'اختر نوع العقار',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppTheme.textWhite,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            Navigator.of(sheetContext).pop();
                          },
                          child: Text(
                            '',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppTheme.primaryBlue.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight:
                            MediaQuery.of(sheetContext).size.height * 0.62,
                      ),
                      child: Scrollbar(
                        controller: scrollController,
                        thumbVisibility: true,
                        radius: const Radius.circular(99),
                        thickness: 4,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: _buildPropertyTypesList(
                              sheetContext: sheetContext),
                        ),
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

  /// يبني قائمة الأنواع داخل اللوحة المنبثقة مع إبراز الاختيار الحالي.
  /// Builds the list of property types inside the picker sheet and highlights
  /// the current selection.
  Widget _buildPropertyTypesList({BuildContext? sheetContext}) {
    return Column(
      children: widget.propertyTypes.map((p) {
        final bool isSelected = widget.selectedTypeId == p.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _handleSelection(p, popContext: sheetContext),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryBlue.withOpacity(0.12)
                      : AppTheme.darkCard.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryBlue.withOpacity(0.28)
                        : AppTheme.darkBorder.withOpacity(0.18),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryBlue.withOpacity(0.14)
                            : AppTheme.darkBackground.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryBlue.withOpacity(0.22)
                              : AppTheme.darkBorder.withOpacity(0.16),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        IconMapper.getIconFromString(p.icon),
                        size: 18,
                        color: isSelected
                            ? AppTheme.primaryBlue.withOpacity(0.95)
                            : AppTheme.textMuted.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppTheme.textWhite.withOpacity(0.95),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: AppTheme.textMuted.withOpacity(0.72),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: AppTheme.primaryBlue.withOpacity(0.95),
                      )
                    else
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppTheme.textMuted.withOpacity(0.55),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// يطبق اختيار نوع العقار ويرسل النتيجة إلى الطبقة الأعلى ثم يغلق اللوحة
  /// عند الحاجة.
  /// Applies the property-type selection, forwards it to higher-level state,
  /// and closes the sheet when appropriate.
  void _handleSelection(PropertyType type, {BuildContext? popContext}) {
    HapticFeedback.selectionClick();
    if (widget.selectedTypeId == type.id) return;
    widget.onTypeSelected(type.id);

    if (popContext != null) {
      Navigator.of(popContext).pop();
    }
  }
}

/// تمثل بطاقة اختيار تفاعلية لنوع عقار واحد داخل لوحة الاختيار.
/// Represents an interactive selection card for a single property type inside
/// the picker sheet.
class _ElegantPropertyTypeCard extends StatefulWidget {
  /// نوع العقار الذي تعرضه البطاقة.
  /// Property type rendered by this card.
  final PropertyType propertyType;

  /// يحدد ما إذا كانت البطاقة تمثل الاختيار الحالي للمستخدم.
  /// Indicates whether the card represents the user's current selection.
  final bool isSelected;

  /// الاستدعاء الذي ينفذ عند الضغط على البطاقة.
  /// Callback executed when the card is tapped.
  final VoidCallback onTap;

  /// تأخير بسيط يوزع ظهور البطاقات بشكل متدرج داخل اللوحة.
  /// Small delay used to stagger card entrance inside the sheet.
  final Duration animationDelay;

  /// ينشئ البطاقة مع بيانات النوع وسلوك النقر الخاص بها.
  /// Creates the card with its type data and tap behavior.
  const _ElegantPropertyTypeCard({
    required this.propertyType,
    required this.isSelected,
    required this.onTap,
    this.animationDelay = Duration.zero,
  });

  /// ينشئ حالة البطاقة التي تدير الحركة واللمعان والتفاعل.
  /// Creates the card state that manages motion, shimmer, and interaction.
  @override
  State<_ElegantPropertyTypeCard> createState() =>
      _ElegantPropertyTypeCardState();
}

/// تدير التوهج واللمعان وحالة الضغط داخل بطاقة اختيار نوع العقار.
/// Manages glow, shimmer, and pressed-state behavior inside the property-type
/// selection card.
class _ElegantPropertyTypeCardState extends State<_ElegantPropertyTypeCard>
    with TickerProviderStateMixin {
  /// متحكم التوهج الذي يبرز البطاقة عندما تكون مختارة.
  /// Glow controller that highlights the card when it becomes selected.
  late AnimationController _glowController;

  /// متحكم اللمعان الذي يمر فوق البطاقة لإعطاء إحساس بالحركة.
  /// Shimmer controller that sweeps across the card to keep it visually alive.
  late AnimationController _shimmerController;

  /// قيمة الحركة المستخدمة لحساب شدة التوهج الحالية.
  /// Animation value used to compute the current glow intensity.
  late Animation<double> _glowAnimation;

  /// قيمة الحركة التي تحدد موضع اللمعان على سطح البطاقة.
  /// Animation value that determines the shimmer position on the card surface.
  late Animation<double> _shimmerAnimation;

  /// يحدد ما إذا كانت البطاقة في حالة ضغط لحظية أثناء التفاعل.
  /// Indicates whether the card is in a transient pressed state during touch
  /// interaction.
  bool _isPressed = false;

  /// يهيئ المتحكمات الداخلية ويشغّل التوهج إذا كانت البطاقة مختارة مسبقًا.
  /// Initializes internal controllers and starts the glow when the card is
  /// already selected.
  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOutSine,
    ));

    if (widget.isSelected) {
      _glowController.repeat(reverse: true);
    }
  }

  /// يزامن التوهج مع تغيّر حالة التحديد حتى يبقى الإبراز متوافقًا مع الحالة.
  /// Synchronizes the glow with selection changes so visual emphasis always
  /// matches state.
  @override
  void didUpdateWidget(_ElegantPropertyTypeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
        _glowController.reset();
      }
    }
  }

  /// يحرر متحكمات الحركة عندما تُزال البطاقة من الشجرة.
  /// Releases the animation controllers when the card leaves the tree.
  @override
  void dispose() {
    _glowController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  /// يبني البطاقة بكل طبقاتها البصرية، من الإطار المتوهج حتى حالة الضغط.
  /// Builds the card with its full visual stack, from glowing border to
  /// pressed feedback.
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration:
          Duration(milliseconds: 600 + widget.animationDelay.inMilliseconds),
      curve: Curves.elasticOut,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.5 + 0.5 * animValue,
          child: Opacity(
            opacity: animValue.clamp(0.0, 1.0),
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) {
                setState(() => _isPressed = false);
                widget.onTap();
              },
              onTapCancel: () => setState(() => _isPressed = false),
              child: AnimatedScale(
                scale: _isPressed ? 0.92 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: widget.isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withOpacity(
                                    0.15 + 0.1 * _glowAnimation.value,
                                  ),
                                  blurRadius: 15 + 5 * _glowAnimation.value,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 15,
                            sigmaY: 15,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: widget.isSelected
                                    ? [
                                        AppTheme.primaryBlue.withOpacity(
                                          isDarkMode ? 0.12 : 0.18,
                                        ),
                                        AppTheme.primaryPurple.withOpacity(
                                          isDarkMode ? 0.08 : 0.12,
                                        ),
                                      ]
                                    : [
                                        isDarkMode
                                            ? Colors.white.withOpacity(0.04)
                                            : Colors.white.withOpacity(0.75),
                                        isDarkMode
                                            ? Colors.white.withOpacity(0.02)
                                            : Colors.white.withOpacity(0.55),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: widget.isSelected
                                    ? AppTheme.primaryBlue.withOpacity(
                                        0.4 + 0.2 * _glowAnimation.value,
                                      )
                                    : isDarkMode
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.white.withOpacity(0.6),
                                width: widget.isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                _buildContent(isDarkMode),
                                if (!widget.isSelected)
                                  _buildShimmerOverlay(isDarkMode),
                                if (widget.isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: _buildSelectionBadge(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// يبني المحتوى الأساسي للبطاقة مثل الاسم والوصف والعداد.
  /// Builds the card's core content, such as label, description, and count.
  Widget _buildContent(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(isDarkMode),
          const SizedBox(height: 5),
          Flexible(
            child: Text(
              widget.propertyType.name,
              style: AppTextStyles.caption.copyWith(
                color: widget.isSelected
                    ? AppTheme.primaryBlue
                    : isDarkMode
                        ? AppTheme.textWhite.withOpacity(0.85)
                        : AppTheme.textDark.withOpacity(0.9),
                fontWeight:
                    widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.propertyType.propertiesCount > 0) ...[
            const SizedBox(height: 3),
            _buildCountBadge(isDarkMode),
          ],
        ],
      ),
    );
  }

  /// يبني الحاوية الدائرية التي تعرض أيقونة نوع العقار.
  /// Builds the circular container that displays the property-type icon.
  Widget _buildIcon(bool isDarkMode) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isSelected
              ? [
                  AppTheme.primaryBlue.withOpacity(0.2),
                  AppTheme.primaryPurple.withOpacity(0.15),
                ]
              : [
                  isDarkMode
                      ? AppTheme.darkCard.withOpacity(0.3)
                      : Colors.white.withOpacity(0.6),
                  isDarkMode
                      ? AppTheme.darkCard.withOpacity(0.2)
                      : Colors.white.withOpacity(0.4),
                ],
        ),
        border: Border.all(
          color: widget.isSelected
              ? AppTheme.primaryBlue.withOpacity(0.3)
              : isDarkMode
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: widget.isSelected
            ? [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          IconMapper.getIconFromString(widget.propertyType.icon),
          size: 22,
          color: widget.isSelected
              ? AppTheme.primaryBlue
              : isDarkMode
                  ? AppTheme.textWhite.withOpacity(0.7)
                  : AppTheme.textDark.withOpacity(0.8),
        ),
      ),
    );
  }

  /// يبني الشارة التي تعرض عدد العناصر أو العقارات المرتبطة بهذا النوع.
  /// Builds the badge that shows how many items or properties belong to this
  /// type.
  Widget _buildCountBadge(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isSelected
              ? [
                  AppTheme.primaryBlue.withOpacity(0.2),
                  AppTheme.primaryPurple.withOpacity(0.15),
                ]
              : [
                  isDarkMode
                      ? Colors.white.withOpacity(0.06)
                      : Colors.white.withOpacity(0.5),
                  isDarkMode
                      ? Colors.white.withOpacity(0.04)
                      : Colors.white.withOpacity(0.3),
                ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.isSelected
              ? AppTheme.primaryBlue.withOpacity(0.3)
              : isDarkMode
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Text(
        '${widget.propertyType.propertiesCount}',
        style: AppTextStyles.caption.copyWith(
          color: widget.isSelected
              ? AppTheme.primaryBlue
              : isDarkMode
                  ? AppTheme.textMuted.withOpacity(0.7)
                  : AppTheme.textDark.withOpacity(0.8),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// يبني طبقة اللمعان التي تمر فوق البطاقة عندما لا تكون مختارة.
  /// Builds the shimmer overlay that sweeps across the card when it is not
  /// selected.
  Widget _buildShimmerOverlay(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: CustomPaint(
              painter: _ShimmerPainter(
                shimmerValue: _shimmerAnimation.value,
                isDarkMode: isDarkMode,
              ),
            ),
          ),
        );
      },
    );
  }

  /// يبني شارة التحديد التي تؤكد للمستخدم أن هذا النوع هو الاختيار النشط.
  /// Builds the selection badge that confirms this type is currently active.
  Widget _buildSelectionBadge() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryCyan,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Icon(
        Icons.check_rounded,
        size: 14,
        color: Colors.white,
      ),
    );
  }
}

/// يرسم شريط اللمعان المتحرك الذي يمر فوق البطاقة.
/// Paints the moving shimmer band that sweeps across the card.
class _ShimmerPainter extends CustomPainter {
  /// الموضع الحالي لشريط اللمعان داخل مساحة البطاقة.
  /// Current position of the shimmer band within the card area.
  final double shimmerValue;

  /// يحدد ما إذا كان الرسام يعمل في سياق تصميم داكن.
  /// Indicates whether the painter is rendering in a dark-theme context.
  final bool isDarkMode;

  /// ينشئ الرسام مع الموضع الحالي للمعان والسياق البصري المستخدم.
  /// Creates the painter with the current shimmer position and visual theme
  /// context.
  _ShimmerPainter({
    required this.shimmerValue,
    required this.isDarkMode,
  });

  /// يرسم طبقة اللمعان الحالية فوق مساحة البطاقة.
  /// Paints the current shimmer layer across the card surface.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          isDarkMode
              ? Colors.white.withOpacity(0.02)
              : Colors.white.withOpacity(0.15),
          Colors.transparent,
        ],
        stops: [
          (shimmerValue - 0.3).clamp(0.0, 1.0),
          shimmerValue.clamp(0.0, 1.0),
          (shimmerValue + 0.3).clamp(0.0, 1.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  /// يقرر إعادة الرسم عندما يتغير موضع اللمعان أو السياق البصري.
  /// Decides whether to repaint when shimmer position or visual context
  /// changes.
  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) {
    return shimmerValue != oldDelegate.shimmerValue;
  }
}
