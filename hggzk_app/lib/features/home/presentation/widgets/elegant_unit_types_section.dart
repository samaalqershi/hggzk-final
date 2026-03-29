import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../domain/entities/unit_type.dart';

/// يعرض شريط اختيار نوع الوحدة بعد اختيار نوع العقار، ويضبط بقية الفلاتر
/// والحقول المرتبطة بذلك النوع.
/// Renders the unit-type selector after a property type is chosen and drives
/// the remaining filters and fields tied to that context.
class ElegantUnitTypesSection extends StatefulWidget {
  /// أنواع الوحدات المتاحة في السياق الحالي.
  /// Unit types available in the current context.
  final List<UnitType> unitTypes;

  /// معرّف نوع الوحدة المحدد حاليًا إذا كانت هناك قيمة نشطة.
  /// Identifier of the currently selected unit type when an active value
  /// exists.
  final String? selectedUnitTypeId;

  /// الاستدعاء الذي يخبر الطبقة الأعلى بأن المستخدم غيّر نوع الوحدة.
  /// Callback that informs higher-level state that the user changed the unit
  /// type.
  final Function(String?) onUnitTypeSelected;

  /// ينشئ أداة اختيار نوع الوحدة بالبيانات الحالية ومنطق التغيير الخارجي.
  /// Creates the unit-type selector with the current data and external change
  /// logic.
  const ElegantUnitTypesSection({
    super.key,
    required this.unitTypes,
    this.selectedUnitTypeId,
    required this.onUnitTypeSelected,
  });

  /// ينشئ كائن الحالة الذي يدير الحركة وسلوك التفاعل داخل القسم.
  /// Creates the state object that manages animation and interaction inside
  /// the section.
  @override
  State<ElegantUnitTypesSection> createState() =>
      _ElegantUnitTypesSectionState();
}

/// تدير حركات الظهور والنبض وسلوك فتح القائمة واختيار نوع الوحدة.
/// Manages the entrance, pulse, picker, and unit-type selection behavior.
class _ElegantUnitTypesSectionState extends State<ElegantUnitTypesSection>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  /// تجهز الحركات وتبدأ تسلسل الظهور الافتتاحي.
  /// Prepares the animations and starts the entrance sequence.
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  /// تهيئ حركات الظهور والنبض التي يعتمد عليها القسم عند العرض.
  /// Configures the entrance and pulse animations used by the section.
  void _initializeAnimations() {
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  /// تبدأ الحركة بعد تأخير بسيط حتى يظهر القسم بسلاسة أكبر عند فتح الصفحة.
  /// Starts the animation after a short delay so the section reveals more
  /// smoothly on page load.
  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  /// يحرر متحكمات الحركة عندما تُزال الأداة من الشجرة.
  /// Releases the animation controllers when the widget is removed from the
  /// tree.
  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// يبني واجهة اختيار نوع الوحدة بالاعتماد على الخيارات الحالية والاختيار
  /// النشط.
  /// Builds the unit-type selector using the current options and active
  /// selection.
  @override
  Widget build(BuildContext context) {
    if (widget.unitTypes.isEmpty) return const SizedBox.shrink();

    UnitType? selectedUnitType;
    if (widget.selectedUnitTypeId != null) {
      for (final u in widget.unitTypes) {
        if (u.id == widget.selectedUnitTypeId) {
          selectedUnitType = u;
          break;
        }
      }
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHintMessage(),
              const SizedBox(height: 12),
              _buildPickerButton(context, selectedUnitType),
            ],
          ),
        ),
      ),
    );
  }

  /// يعرض رسالة موجزة تشرح للمستخدم أن هذه الخطوة مطلوبة قبل متابعة التصفح
  /// الدقيق.
  /// Shows a short hint explaining that this step is required before deeper
  /// browsing can continue.
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
              context.tr('home.unitTypes.hint'),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted.withOpacity(0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// يبني الزر الرئيسي الذي يعرض النوع الحالي ويفتح لوحة اختيار الوحدات.
  /// Builds the main launcher button that shows the current type and opens the
  /// unit picker sheet.
  Widget _buildPickerButton(
    BuildContext context,
    UnitType? selectedUnitType,
  ) {
    final bool isSelected = selectedUnitType != null;
    final Color baseColor = AppTheme.darkCard.withOpacity(0.35);
    final Color borderColor = isSelected
        ? AppTheme.primaryPurple.withOpacity(0.30)
        : AppTheme.darkBorder.withOpacity(0.18);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.selectionClick();
          _showUnitTypePickerSheet(context, selectedUnitType);
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
                      ? AppTheme.primaryPurple.withOpacity(0.12)
                      : AppTheme.darkCard.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryPurple.withOpacity(0.20)
                        : AppTheme.darkBorder.withOpacity(0.16),
                    width: 1,
                  ),
                ),
                child: Icon(
                  isSelected
                      ? IconMapper.getIconFromString(selectedUnitType!.icon)
                      : Icons.meeting_room_rounded,
                  size: 18,
                  color: isSelected
                      ? AppTheme.primaryPurple.withOpacity(0.95)
                      : AppTheme.textMuted.withOpacity(0.75),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('home.unitTypes.label'),
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedUnitType?.name ?? context.tr('common.dash'),
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

  /// يفتح اللوحة السفلية التي تسمح باستعراض أنواع الوحدات واختيار أحدها من
  /// قائمة قابلة للتمرير.
  /// Opens the bottom sheet that lets the user browse unit types and choose
  /// one from a scrollable list.
  Future<void> _showUnitTypePickerSheet(
    BuildContext context,
    UnitType? selectedUnitType,
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
                            context.tr('home.unitTypes.choose'),
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
                            context.tr('common.close'),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppTheme.primaryPurple.withOpacity(0.9),
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
                          child:
                              _buildUnitTypesList(sheetContext: sheetContext),
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

  Widget _buildUnitTypesList({BuildContext? sheetContext}) {
    return Column(
      children: widget.unitTypes.map((u) {
        final bool isSelected = widget.selectedUnitTypeId == u.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _handleSelection(u.id, popContext: sheetContext),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryPurple.withOpacity(0.12)
                      : AppTheme.darkCard.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryPurple.withOpacity(0.28)
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
                            ? AppTheme.primaryPurple.withOpacity(0.14)
                            : AppTheme.darkBackground.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryPurple.withOpacity(0.22)
                              : AppTheme.darkBorder.withOpacity(0.16),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        IconMapper.getIconFromString(u.icon),
                        size: 18,
                        color: isSelected
                            ? AppTheme.primaryPurple.withOpacity(0.95)
                            : AppTheme.textMuted.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppTheme.textWhite.withOpacity(0.95),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            u.description,
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
                        color: AppTheme.primaryPurple.withOpacity(0.95),
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

  void _handleSelection(String unitTypeId, {BuildContext? popContext}) {
    HapticFeedback.selectionClick();
    if (widget.selectedUnitTypeId == unitTypeId) return;
    widget.onUnitTypeSelected(unitTypeId);

    if (popContext != null) {
      Navigator.of(popContext).pop();
    }
  }
}
