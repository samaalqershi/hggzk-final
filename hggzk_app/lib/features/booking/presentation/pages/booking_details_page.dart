import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:hggzk/app/dependency_injection/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/price_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/enums/booking_status.dart';
import '../../domain/entities/payment.dart';
import '../../../review/domain/entities/review_image.dart';
import '../../../review/domain/usecases/get_property_reviews_usecase.dart';
import '../../../review/presentation/widgets/review_video_player_dialog.dart';
import '../../../review/presentation/widgets/upload_review_image_widget.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../widgets/booking_status_widget.dart';
import '../widgets/cancellation_deadline_has_expired_widget.dart';

class BookingDetailsPage extends StatefulWidget {
  final String bookingId;

  const BookingDetailsPage({
    super.key,
    required this.bookingId,
  });

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage>
    with TickerProviderStateMixin {
  // Animation Controllers - Reduced and optimized
  late AnimationController _backgroundAnimationController;
  late AnimationController _qrAnimationController;
  late AnimationController _fadeController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _qrScaleAnimation;

  // State
  bool _showQRCode = false;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  dynamic _cachedBooking;
  bool _hasChanges = false;
  String? _pendingCancelReason;
  String? _pendingCancelBookingId;
  String? _pendingCancelUserId;
  final Map<String, Future<List<ReviewImage>>> _reviewMediaFutures = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _loadBookingDetails();
    _scrollController.addListener(_onScroll);
  }

  void _initializeAnimations() {
    // Slow background animation for subtlety
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 45),
      vsync: this,
    )..repeat();

    // QR Animation
    _qrAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _qrScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _qrAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Fade Animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
    });
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  void _loadBookingDetails() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<BookingBloc>().add(
            GetBookingDetailsEvent(
              bookingId: widget.bookingId,
              userId: authState.user.userId,
            ),
          );
    }
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _qrAnimationController.dispose();
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hasChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Stack(
          children: [
            // Subtle animated background
            _buildSubtleBackground(),

            // Main Content
            BlocConsumer<BookingBloc, BookingState>(
              listener: (context, state) {
                _handleBookingState(context, state);
              },
              builder: (context, state) {
                if (state is BookingLoading) {
                  return Center(
                    child: _buildMinimalLoader(),
                  );
                }

                if (state is BookingError) {
                  if (_cachedBooking != null) {
                    return _buildContent(_cachedBooking);
                  }
                  return Center(
                    child: _buildMinimalError(state),
                  );
                }

                if (state is BookingDetailsLoaded) {
                  _cachedBooking = state.booking;
                  return _buildContent(state.booking);
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleBookingState(BuildContext context, BookingState state) {
    if (state is BookingCancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('booking.details.cancelledSuccess')),
          backgroundColor: AppTheme.success,
        ),
      );
      _hasChanges = true;
      Navigator.pop(context, true);
      return;
    }

    if (state is BookingError && state.showAsDialog) {
      final code = state.code ?? state.message;
      if (code == 'CANCELLATION_AFTER_CHECKIN') {
        _showPolicyDialog(
          title: context.tr('booking.details.cancellationAfterCheckInTitle'),
          description:
              context.tr('booking.details.cancellationAfterCheckInMessage'),
        );
      } else if (code == 'CANCELLATION_NOT_ALLOWED') {
        _showPolicyDialog(
          title: context.tr('booking.details.cancellationNotAllowedTitle'),
          description:
              context.tr('booking.details.cancellationNotAllowedMessage'),
        );
      } else if (code == 'CANCELLATION_WINDOW_EXCEEDED') {
        _showPolicyDialog(
          title: context.tr('booking.details.cancellationWindowExceededTitle'),
          description:
              context.tr('booking.details.cancellationWindowExceededMessage'),
        );
      } else if (code == 'PAYMENTS_EXIST') {
        _showRefundThenCancelDialog();
      } else if (code == 'REFUND_EXCEEDS_POLICY') {
        _showPolicyDialog(
          title: context.tr('booking.details.refundExceedsPolicyTitle'),
          description: context.tr('booking.details.refundExceedsPolicyMessage'),
        );
      }
    }

    if (state is BookingError && !state.showAsDialog) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _showRefundThenCancelDialog() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      context.go('/login');
      return;
    }

    final bookingId = _pendingCancelBookingId;
    final userId = _pendingCancelUserId ?? authState.user.userId;
    final reason = _pendingCancelReason ?? '';

    if (bookingId == null || bookingId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('booking.details.cancellationRetryFailed')),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierColor: AppTheme.overlayDark,
      builder: (ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.warning.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppTheme.warning, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          context.tr('booking.details.refundCancelTitle'),
                          style: AppTextStyles.h3.copyWith(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('booking.details.refundCancelMessage'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textMuted,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppTheme.darkSurface.withOpacity(0.6),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            context.tr('booking.details.back'),
                            style: AppTextStyles.buttonMedium
                                .copyWith(color: AppTheme.textWhite),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.read<BookingBloc>().add(
                                  CancelBookingEvent(
                                    bookingId: bookingId,
                                    userId: userId,
                                    reason: reason,
                                    refundPayments: true,
                                  ),
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.warning,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            context.tr('booking.details.refundCancelAction'),
                            style: AppTextStyles.buttonMedium
                                .copyWith(color: Colors.white),
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
      },
    );
  }

  Widget _buildTimelineInfoRow({
    required Color lineColor,
    required Widget content,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      lineColor.withOpacity(0.9),
                      lineColor.withOpacity(0.4),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: lineColor.withOpacity(0.35),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              if (!isLast) ...[
                const SizedBox(height: 4),
                Container(
                  width: 2,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        lineColor.withOpacity(0.4),
                        lineColor.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(width: 10),
          Expanded(child: content),
        ],
      ),
    );
  }

  String _localizedNightsLabel(int nights) {
    final key = nights == 1
        ? 'booking.details.nightSingle'
        : 'booking.details.nightPlural';
    return '${nights} ${context.tr(key)}';
  }

  String _localizedGuestSummary({
    required int totalGuests,
    required int adultGuests,
    required int childGuests,
  }) {
    final guestKey = totalGuests == 1
        ? 'booking.details.guestSingle'
        : 'booking.details.guestPlural';
    final adultKey = adultGuests == 1
        ? 'booking.details.adultSingle'
        : 'booking.details.adultPlural';
    final childPart = childGuests > 0
        ? '${context.tr("booking.details.guestSeparator")}$childGuests ${context.tr(childGuests == 1 ? "booking.details.childSingle" : "booking.details.childPlural")}'
        : '';
    return '$totalGuests ${context.tr(guestKey)} ($adultGuests ${context.tr(adultKey)}$childPart)';
  }

  // Visual config for booking policies in the snapshot card
  _BookingPolicyVisual _getBookingPolicyVisual(String type) {
    final lower = type.toLowerCase();
    if (lower == 'cancellation') {
      return _BookingPolicyVisual(
        title: context.tr('booking.policies.cancellation'),
        icon: Icons.cancel_outlined,
        color: AppTheme.warning,
      );
    }
    if (lower == 'payment') {
      return _BookingPolicyVisual(
        title: context.tr('booking.policies.payment'),
        icon: Icons.payment_outlined,
        color: AppTheme.success,
      );
    }
    if (lower == 'checkin' || lower == 'check-in') {
      return _BookingPolicyVisual(
        title: context.tr('booking.policies.checkIn'),
        icon: Icons.login,
        color: AppTheme.info,
      );
    }
    if (lower == 'checkout' || lower == 'check-out') {
      return _BookingPolicyVisual(
        title: context.tr('booking.policies.checkOut'),
        icon: Icons.logout,
        color: AppTheme.info,
      );
    }
    if (lower == 'modification') {
      return _BookingPolicyVisual(
        title: context.tr('booking.details.policyModification'),
        icon: Icons.edit_note_rounded,
        color: AppTheme.primaryPurple,
      );
    }
    if (lower == 'children') {
      return _BookingPolicyVisual(
        title: context.tr('booking.details.policyChildren'),
        icon: Icons.child_care,
        color: AppTheme.primaryBlue,
      );
    }
    if (lower == 'pets') {
      return _BookingPolicyVisual(
        title: context.tr('booking.details.policyPets'),
        icon: Icons.pets,
        color: AppTheme.primaryViolet,
      );
    }

    return _BookingPolicyVisual(
      title: context.tr('booking.policies.other'),
      icon: Icons.policy_outlined,
      color: AppTheme.primaryPurple,
    );
  }

  void _showPolicyDialog({
    required String title,
    required String description,
  }) {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.darkCard.withOpacity(0.96),
                    AppTheme.darkCard.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.warning.withOpacity(0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.warning.withOpacity(0.25),
                    blurRadius: 30,
                    spreadRadius: 4,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.warning.withOpacity(0.25),
                          AppTheme.warning.withOpacity(0.12),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.policy_rounded,
                      color: AppTheme.warning.withOpacity(0.95),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: AppTextStyles.h3.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textMuted.withOpacity(0.9),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(dialogContext).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.warning,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        context.tr('booking.details.ok'),
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtleBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground2,
                AppTheme.darkBackground3,
              ],
            ),
          ),
          child: CustomPaint(
            painter: _SubtleDetailPatternPainter(
              animationValue: _backgroundAnimationController.value,
              scrollOffset: _scrollOffset,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildContent(dynamic booking) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildMinimalAppBar(booking),
        SliverToBoxAdapter(
          child: AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildCompactStatusCard(booking),
                        const SizedBox(height: 12),
                        _buildCompactQRCodeSection(booking),
                        const SizedBox(height: 12),
                        _buildCompactPropertyCard(booking),
                        const SizedBox(height: 12),
                        _buildCompactBookingInfo(booking),
                        const SizedBox(height: 12),
                        _buildCompactGuestInfo(booking),
                        const SizedBox(height: 12),
                        _buildPoliciesCard(booking),
                        if (booking.userReview != null) ...[
                          const SizedBox(height: 12),
                          _buildUserReviewCard(booking),
                        ],
                        if (booking.services.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildCompactServicesCard(booking),
                        ],
                        const SizedBox(height: 12),
                        _buildUnpaidWarning(booking),
                        const SizedBox(height: 12),
                        _buildCompactPaymentInfo(booking),
                        if (booking.canCancel) ...[
                          const SizedBox(height: 12),
                          _buildCancellationPolicy(booking),
                        ],
                        const SizedBox(height: 12),
                        _buildCompactActions(booking),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPoliciesCard(dynamic booking) {
    final snapshot = booking.policySnapshot as String?;
    if (snapshot == null || snapshot.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    List<dynamic> policies = [];
    try {
      final decoded = jsonDecode(snapshot);
      if (decoded is Map<String, dynamic> && decoded['Policies'] is List) {
        policies = decoded['Policies'] as List;
      }
    } catch (_) {
      // ignore malformed JSON, just don't show policies
    }

    if (policies.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildCompactCard(
      title: context.tr('booking.details.policies'),
      icon: Icons.policy_rounded,
      iconColor: AppTheme.primaryBlue.withOpacity(0.8),
      children: policies.where((p) {
        try {
          if (p is! Map) return true;

          final type = (p['Type'] ?? '').toString();
          final normalizedType = type.trim().toLowerCase();
          if (!booking.canCancel && normalizedType == 'cancellation') {
            return false;
          }
        } catch (_) {}
        return true;
      }).map<Widget>((p) {
        final policy = p as Map;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.policy_outlined,
                  size: 18,
                  color: AppTheme.primaryBlue.withOpacity(0.9),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getBookingPolicyVisual(policy['Type']).title,
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textWhite.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      policy['Description'],
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUserReviewCard(dynamic booking) {
    final review = booking.userReview;
    if (review == null) return const SizedBox.shrink();

    final rating = review.averageRating;
    final createdAt = review.createdAt as DateTime;

    final List<Widget> children = [];

    if (review.isDisabled == true) {
      children.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.error.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.error.withOpacity(0.25)),
          ),
          child: Text(
            context.tr('booking.details.reviewDisabled'),
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
      children.add(const SizedBox(height: 10));
    } else if (review.isPendingApproval == true) {
      children.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.info.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.info.withOpacity(0.25)),
          ),
          child: Text(
            context.tr('booking.details.reviewPendingApproval'),
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
      children.add(const SizedBox(height: 10));
    }

    children.add(
      Text(
        review.comment ?? '',
        style: AppTextStyles.caption.copyWith(
          color: AppTheme.textWhite.withOpacity(0.9),
          height: 1.5,
        ),
      ),
    );

    final reviewImages =
        (review.images as List?)?.cast<ReviewImage>() ?? const [];

    if (reviewImages.isNotEmpty) {
      children.add(const SizedBox(height: 12));
      children.add(_buildReviewMediaSection(reviewImages));
    } else {
      children.add(const SizedBox(height: 12));
      children.add(_buildReviewMediaFallback(booking));
    }

    if (review.responseText != null &&
        review.responseText.toString().trim().isNotEmpty) {
      children.add(const SizedBox(height: 12));
      children.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.glassLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.darkBorder.withOpacity(0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('booking.details.adminReply'),
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                review.responseText,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textWhite.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildCompactCard(
      title: context.tr('booking.details.yourReview'),
      icon: Icons.star_rounded,
      iconColor: AppTheme.warning.withOpacity(0.9),
      gradient: LinearGradient(
        colors: [
          AppTheme.primaryBlue.withOpacity(0.10),
          AppTheme.primaryPurple.withOpacity(0.06),
        ],
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('yyyy/MM/dd', 'ar').format(createdAt),
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted.withOpacity(0.75),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.warning.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, size: 14, color: AppTheme.warning),
                  const SizedBox(width: 6),
                  Text(
                    (rating as num).toDouble().toStringAsFixed(1),
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildReviewMediaFallback(dynamic booking) {
    final bookingId = booking.id?.toString() ?? '';
    if (bookingId.isEmpty) {
      return const SizedBox.shrink();
    }

    final future = _reviewMediaFutures.putIfAbsent(
      bookingId,
      () => _loadReviewMediaForBooking(booking),
    );

    return FutureBuilder<List<ReviewImage>>(
      future: future,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <ReviewImage>[];
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }
        return _buildReviewMediaSection(items);
      },
    );
  }

  Widget _buildReviewMediaSection(List<ReviewImage> mediaItems) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: mediaItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final media = mediaItems[index];
          final imageUrl = media.url.toString();
          if (imageUrl.isEmpty) {
            return const SizedBox.shrink();
          }

          return UploadReviewImageWidget(
            imageUrl: imageUrl,
            thumbnailUrl: media.thumbnailUrl,
            mimeType: media.type,
            size: 100,
            onTap: () => _openReviewMedia(media),
          );
        },
      ),
    );
  }

  void _openReviewMedia(dynamic media) {
    final mimeType = media.type?.toString().toLowerCase() ?? '';
    final mediaUrl = (media.url ?? '').toString();
    if (mediaUrl.isEmpty) return;

    if (mimeType.startsWith('video/')) {
      showDialog<void>(
        context: context,
        builder: (_) => ReviewVideoPlayerDialog(videoUrl: mediaUrl),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              mediaUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Future<List<ReviewImage>> _loadReviewMediaForBooking(dynamic booking) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const [];
    }

    final propertyId = booking.userReview?.propertyId?.toString() ??
        booking.propertyId?.toString() ??
        '';
    final bookingId = booking.id?.toString() ?? '';
    final reviewId = booking.userReview?.id?.toString() ?? '';
    if (propertyId.isEmpty || (bookingId.isEmpty && reviewId.isEmpty)) {
      return const [];
    }

    const pageSize = 100;
    var pageNumber = 1;
    var totalPages = 1;

    while (pageNumber <= totalPages) {
      final result = await sl<GetPropertyReviewsUseCase>()(
        GetPropertyReviewsParams(
          propertyId: propertyId,
          pageNumber: pageNumber,
          pageSize: pageSize,
          sortBy: 'date',
          sortDirection: 'desc',
          withImagesOnly: true,
          userId: authState.user.userId,
        ),
      );

      final page = result.fold((_) => null, (paginated) => paginated);
      if (page == null) {
        return const [];
      }

      for (final review in page.items) {
        final matchesBooking =
            bookingId.isNotEmpty && review.bookingId == bookingId;
        final matchesReview = reviewId.isNotEmpty && review.id == reviewId;
        if (matchesBooking || matchesReview) {
          return review.images;
        }
      }

      final calculatedTotalPages =
          page.totalCount <= 0 ? 1 : (page.totalCount / pageSize).ceil();
      totalPages = calculatedTotalPages < 1 ? 1 : calculatedTotalPages;
      pageNumber += 1;
    }

    return const [];
  }

  Widget _buildMinimalAppBar(dynamic booking) {
    final String title = (booking.unitName?.toString().isNotEmpty ?? false)
        ? booking.unitName
        : (booking.propertyName?.toString().isNotEmpty ?? false)
            ? booking.propertyName
            : context.tr('booking.details.title');
    final Color statusColor = _getStatusColor(booking.status);

    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double currentHeight = constraints.maxHeight;
          final double progress =
              ((currentHeight - kToolbarHeight) / (180.0 - kToolbarHeight))
                  .clamp(0.0, 1.0);
          final double mediaTop = MediaQuery.of(context).padding.top;
          final double topPadding = mediaTop + 4 + (8 * progress);
          final double bottomPadding = 4 + (8 * progress);

          return Stack(
            fit: StackFit.expand,
            children: [
              // Gradient background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard.withOpacity(0.7), //
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        statusColor.withOpacity(0.35),
                        AppTheme.darkCard.withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
              ),
              // Blur effect -
              Positioned.fill(
                child: ClipRect(
                  //
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 8, //
                      sigmaY: 8,
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(0.01), //
                    ),
                  ),
                ),
              ),
              //
              Padding(
                padding: EdgeInsets.only(
                  top: topPadding,
                  left: 16,
                  right: 16,
                  bottom: bottomPadding,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Status icon with glow
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              statusColor.withOpacity(0.95),
                              statusColor.withOpacity(0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.35),
                              blurRadius: 18,
                              spreadRadius: 3,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getStatusIcon(booking.status),
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title + status + booking number
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('booking.details.title'),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppTheme.textMuted
                                      .withOpacity(0.8 + (0.1 * progress)),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.h3.copyWith(
                                  color: AppTheme.textWhite
                                      .withOpacity(0.95 + (0.05 * progress)),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  BookingStatusWidget(
                                    status: booking.status,
                                    isPaid: booking.isPaid,
                                    showIcon: false,
                                    animated:
                                        booking.status == BookingStatus.pending,
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      color: AppTheme.darkCard
                                          .withOpacity(0.6 - (0.2 * progress)),
                                      border: Border.all(
                                        color: AppTheme.darkBorder
                                            .withOpacity(0.4),
                                        width: 0.6,
                                      ),
                                    ),
                                    child: Text(
                                      '#${booking.bookingNumber}',
                                      style: AppTextStyles.caption.copyWith(
                                        color:
                                            AppTheme.textLight.withOpacity(0.9),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      leading: _buildMinimalBackButton(),
      actions: [
        _buildMinimalActionButton(
          icon: Icons.share_rounded,
          onPressed: _shareBooking,
        ),
      ],
    );
  }

  Widget _buildMinimalBackButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(children: [
          Container(
            color: AppTheme.darkCard.withOpacity(0.5), //
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), //
            child: Container(
              color: Colors.black.withOpacity(0.01), //
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 16),
            color: AppTheme.textWhite.withOpacity(0.9),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context, _hasChanges);
            },
          ),
        ]),
      ),
    );
  }

  Widget _buildMinimalActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        // child: BackdropFilter(
        //   filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        //   child: Container(
        //     decoration: BoxDecoration(
        //       color: AppTheme.darkCard.withOpacity(0.3),
        //       borderRadius: BorderRadius.circular(10),
        //       border: Border.all(
        //         color: AppTheme.darkBorder.withOpacity(0.2),
        //         width: 0.5,
        //       ),
        //     ),
        //     child: IconButton(
        //       icon: Icon(icon, size: 16),
        //       color: AppTheme.textWhite.withOpacity(0.9),
        //       onPressed: onPressed,
        //     ),
        //   ),
        // ),
      ),
    );
  }

  Widget _buildCompactStatusCard(dynamic booking) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkInDate = DateTime(
      booking.checkInDate.year,
      booking.checkInDate.month,
      booking.checkInDate.day,
    );

    final bool isMissed = today.isAfter(checkInDate) &&
        booking.status != BookingStatus.cancelled &&
        booking.status != BookingStatus.completed &&
        booking.status != BookingStatus.checkedIn;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.darkCard, //
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            _getStatusColor(booking.status).withOpacity(0.16),
            AppTheme.darkCard.withOpacity(0.78),
          ],
        ),
        border: Border.all(
          color: _getStatusColor(booking.status).withOpacity(0.45),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(booking.status).withOpacity(0.16),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          //
          children: [
            Container(
              //
              color: AppTheme.darkCard.withOpacity(0.6),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3), //
              child: Container(
                color: Colors.transparent,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(booking.status),
                      color: _getStatusColor(booking.status),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isMissed)
                          Text(
                            context.tr('booking.details.missed'),
                            style: AppTextStyles.caption.copyWith(
                              color: AppTheme.error.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else
                          BookingStatusWidget(
                            status: booking.status,
                            isPaid: booking.isPaid,
                            showIcon: false,
                            animated: false,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr(
                            'booking.details.bookingNumberValue',
                            params: {'id': booking.bookingNumber},
                          ),
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textWhite.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          context.tr(
                            'booking.details.bookingDateValue',
                            params: {
                              'date': DateFormat('dd/MM/yyyy')
                                  .format(booking.bookingDate),
                            },
                          ),
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.textMuted.withOpacity(0.7),
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
      ),
    );
  }

  Widget _buildCompactQRCodeSection(dynamic booking) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _showQRCode = !_showQRCode;
              if (_showQRCode) {
                _qrAnimationController.forward();
              } else {
                _qrAnimationController.reverse();
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.8),
                  AppTheme.primaryPurple.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _showQRCode
                      ? Icons.qr_code_2_rounded
                      : Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _showQRCode
                      ? context.tr('booking.details.hideQr')
                      : context.tr('booking.details.showQr'),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showQRCode)
          AnimatedBuilder(
            animation: _qrScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _qrScaleAnimation.value,
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withOpacity(0.12),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: QrImageView(
                          data: booking.bookingNumber,
                          version: QrVersions.auto,
                          size: 120.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        context.tr('booking.details.showQrHint'),
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.textMuted.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCompactPropertyCard(dynamic booking) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.5), //
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.14),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            //
            children: [
              Container(
                //
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.03),
                      AppTheme.primaryPurple.withOpacity(0.02),
                    ],
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3), //
                child: Container(
                  color: Colors.transparent,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryBlue.withOpacity(0.2),
                                AppTheme.primaryPurple.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.apartment_rounded,
                            color: AppTheme.primaryBlue.withOpacity(0.9),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.tr('booking.details.property'),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textWhite.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (booking.unitImages.isNotEmpty)
                      _buildCompactPropertyImage(booking),
                    const SizedBox(height: 10),
                    Text(
                      booking.propertyName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textWhite.withOpacity(0.95),
                      ),
                    ),
                    if (booking.unitName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        booking.unitName!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.textMuted.withOpacity(0.7),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppTheme.primaryCyan.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            booking.propertyAddress ??
                                context
                                    .tr('booking.details.addressUnavailable'),
                            style: AppTextStyles.caption.copyWith(
                              color: AppTheme.textMuted.withOpacity(0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildCompactPropertyImage(dynamic booking) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.1),
            AppTheme.primaryPurple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            if (booking.unitImages.isNotEmpty)
              Image.network(
                booking.unitImages.first,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImagePlaceholder(),
              )
            else
              _buildImagePlaceholder(),

            // Subtle gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.primaryBlue.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.apartment_rounded,
          color: AppTheme.primaryBlue.withOpacity(0.3),
          size: 36,
        ),
      ),
    );
  }

  Widget _buildCompactBookingInfo(dynamic booking) {
    final dateFormat = DateFormat('dd MMM yyyy', 'ar');

    final Color checkInColor = AppTheme.primaryBlue.withOpacity(0.85);
    final Color checkOutColor = AppTheme.primaryPurple.withOpacity(0.85);
    final Color nightsColor = AppTheme.primaryCyan.withOpacity(0.85);

    return _buildCompactCard(
      title: context.tr('booking.details.stayInfo'),
      icon: Icons.calendar_today_rounded,
      iconColor: checkInColor,
      showUnderline: true,
      children: [
        _buildTimelineInfoRow(
          lineColor: checkInColor,
          content: _buildCompactInfoRow(
            icon: Icons.calendar_today_rounded,
            label: context.tr('booking.details.checkIn'),
            value: dateFormat.format(booking.checkInDate),
            iconColor: checkInColor,
          ),
        ),
        _buildTimelineInfoRow(
          lineColor: checkOutColor,
          content: _buildCompactInfoRow(
            icon: Icons.calendar_today_outlined,
            label: context.tr('booking.details.checkOut'),
            value: dateFormat.format(booking.checkOutDate),
            iconColor: checkOutColor,
          ),
        ),
        _buildTimelineInfoRow(
          lineColor: nightsColor,
          isLast: true,
          content: _buildCompactInfoRow(
            icon: Icons.nights_stay_rounded,
            label: context.tr('booking.details.nights'),
            value: _localizedNightsLabel(booking.numberOfNights),
            iconColor: nightsColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactGuestInfo(dynamic booking) {
    final Color guestColor = AppTheme.success.withOpacity(0.9);
    final Color noteColor = AppTheme.warning.withOpacity(0.85);
    final bool hasSpecialRequests = booking.specialRequests != null;

    return _buildCompactCard(
      title: context.tr('booking.details.guestsInfo'),
      icon: Icons.people_outline_rounded,
      iconColor: guestColor,
      showUnderline: true,
      children: [
        _buildTimelineInfoRow(
          lineColor: guestColor,
          content: _buildCompactInfoRow(
            icon: Icons.person_outline_rounded,
            label: context.tr('booking.details.guestName'),
            value: booking.userName,
            iconColor: guestColor,
          ),
        ),
        _buildTimelineInfoRow(
          lineColor: guestColor,
          isLast: !hasSpecialRequests,
          content: _buildCompactInfoRow(
            icon: Icons.people_outline_rounded,
            label: context.tr('booking.details.guestCount'),
            value: _localizedGuestSummary(
              totalGuests: booking.totalGuests,
              adultGuests: booking.adultGuests,
              childGuests: booking.childGuests,
            ),
            iconColor: guestColor,
          ),
        ),
        if (hasSpecialRequests)
          _buildTimelineInfoRow(
            lineColor: noteColor,
            isLast: true,
            content: _buildCompactInfoRow(
              icon: Icons.note_rounded,
              label: context.tr('booking.details.specialRequests'),
              value: booking.specialRequests!,
              iconColor: noteColor,
            ),
          ),
      ],
    );
  }

  Widget _buildCompactServicesCard(dynamic booking) {
    return _buildCompactCard(
      title: context.tr('booking.details.services'),
      icon: Icons.room_service_rounded,
      iconColor: AppTheme.primaryViolet.withOpacity(0.8),
      children: booking.services
          .map<Widget>((service) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryViolet.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${service.serviceName} x${service.quantity}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.textWhite.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    PriceWidget(
                      price: service.totalPrice,
                      currency: service.currency,
                      displayType: PriceDisplayType.compact,
                      priceStyle: AppTextStyles.caption.copyWith(
                        color: AppTheme.primaryViolet.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCompactPaymentInfo(dynamic booking) {
    // Calculate paid and remaining
    final double total = (booking.totalAmount ?? 0).toDouble();
    final String currency = booking.currency ?? 'YER';
    double paid = 0.0;
    if (booking.payments != null &&
        booking.payments is List &&
        booking.payments.isNotEmpty) {
      for (final p in booking.payments) {
        try {
          if (p.status == PaymentStatus.completed) {
            paid += (p.amount ?? 0).toDouble();
          }
        } catch (_) {}
      }
    }
    final double remaining = (total - paid) > 0 ? (total - paid) : 0.0;
    final bool isFullyPaid = (booking.isPaid == true) || remaining <= 0.0;
    final bool isPartiallyPaid = !isFullyPaid && paid > 0.0;

    final Color headerColor = AppTheme.success.withOpacity(0.8);
    final Color statusColor = isFullyPaid
        ? AppTheme.success
        : isPartiallyPaid
            ? AppTheme.info
            : AppTheme.warning;

    return _buildCompactCard(
      title: context.tr('booking.details.paymentInfo'),
      icon: Icons.payment_rounded,
      iconColor: headerColor,
      gradient: LinearGradient(
        colors: [
          AppTheme.success.withOpacity(0.05),
          AppTheme.success.withOpacity(0.02),
        ],
      ),
      borderColor: AppTheme.success.withOpacity(0.2),
      showUnderline: true,
      children: [
        _buildTimelineInfoRow(
          lineColor: statusColor,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('booking.details.paymentStatus'),
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted.withOpacity(0.8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isFullyPaid
                      ? AppTheme.success.withOpacity(0.08)
                      : isPartiallyPaid
                          ? AppTheme.info.withOpacity(0.08)
                          : AppTheme.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isFullyPaid
                        ? AppTheme.success.withOpacity(0.3)
                        : isPartiallyPaid
                            ? AppTheme.info.withOpacity(0.3)
                            : AppTheme.warning.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  isFullyPaid
                      ? context.tr('booking.details.fullyPaid')
                      : isPartiallyPaid
                          ? context.tr('booking.details.partiallyPaid')
                          : context.tr('booking.details.unpaid'),
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isFullyPaid
                        ? AppTheme.success.withOpacity(0.9)
                        : isPartiallyPaid
                            ? AppTheme.info.withOpacity(0.9)
                            : AppTheme.warning.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildTimelineInfoRow(
          lineColor: AppTheme.success,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('booking.details.totalAmount'),
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted.withOpacity(0.8),
                ),
              ),
              PriceWidget(
                price: total,
                currency: currency,
                displayType: PriceDisplayType.compact,
                priceStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppTheme.success.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        _buildTimelineInfoRow(
          lineColor: AppTheme.info,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('booking.details.paidAmount'),
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted.withOpacity(0.8),
                ),
              ),
              PriceWidget(
                price: paid,
                currency: currency,
                displayType: PriceDisplayType.compact,
                priceStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.info.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _buildTimelineInfoRow(
          lineColor: AppTheme.error,
          isLast: true,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('booking.details.remainingAmount'),
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted.withOpacity(0.8),
                ),
              ),
              PriceWidget(
                price: remaining,
                currency: currency,
                displayType: PriceDisplayType.compact,
                priceStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.error.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnpaidWarning(dynamic booking) {
    if (booking.isPaid == true) return const SizedBox.shrink();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkInDate = DateTime(
      booking.checkInDate.year,
      booking.checkInDate.month,
      booking.checkInDate.day,
    );
    final bool isMissed = today.isAfter(checkInDate) &&
        booking.status != BookingStatus.cancelled &&
        booking.status != BookingStatus.completed &&
        booking.status != BookingStatus.checkedIn;

    final bool isPending = booking.status == BookingStatus.pending;

    final String title;
    final String message;

    if (isMissed) {
      title = context.tr('booking.details.missed');
      message = context.tr('booking.details.missedLongMessage');
    } else if (isPending) {
      title = context.tr('booking.details.pendingPayment');
      message = context.tr('booking.details.pendingPaymentLongMessage');
    } else {
      title = context.tr('booking.details.pendingPayment');
      message = context.tr('booking.details.pendingPaymentLongMessage');
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.warning.withOpacity(0.25),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_empty_rounded,
              color: AppTheme.warning.withOpacity(0.9),
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textWhite.withOpacity(0.95),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationPolicy(dynamic booking) {
    final now = DateTime.now();
    final cancellationDeadline =
        booking.checkInDate.subtract(const Duration(hours: 24));
    final canCancelFree = now.isBefore(cancellationDeadline);

    return CancellationDeadlineHasExpiredWidget(
      hasExpired: !canCancelFree,
      deadline: cancellationDeadline,
    );
  }

  Widget _buildCompactActions(dynamic booking) {
    final double total = (booking.totalAmount ?? 0).toDouble();
    double paid = 0.0;
    if (booking.payments != null &&
        booking.payments is List &&
        booking.payments.isNotEmpty) {
      for (final p in booking.payments) {
        try {
          if (p.status == PaymentStatus.completed) {
            paid += (p.amount ?? 0).toDouble();
          }
        } catch (_) {}
      }
    }
    final double remaining = total - paid;
    final bool isFullyPaid = remaining <= 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkInDate = DateTime(
      booking.checkInDate.year,
      booking.checkInDate.month,
      booking.checkInDate.day,
    );
    final bool isMissed = today.isAfter(checkInDate) &&
        booking.status != BookingStatus.cancelled &&
        booking.status != BookingStatus.completed &&
        booking.status != BookingStatus.checkedIn;

    final bool canShowPayButton = !isFullyPaid &&
        !isMissed &&
        booking.status != BookingStatus.cancelled &&
        booking.status != BookingStatus.completed;

    return Column(
      children: [
        _buildCompactActionButton(
          icon: Icons.apartment_rounded,
          label: context.tr('booking.details.property'),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryBlue.withOpacity(0.8),
              AppTheme.primaryCyan.withOpacity(0.6),
            ],
          ),
          onPressed: () => _openPropertyDetails(booking),
        ),
        const SizedBox(height: 8),
        if (canShowPayButton)
          _buildCompactActionButton(
            icon: Icons.payment_rounded,
            label: context.tr('booking.details.payNow'),
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryBlue.withOpacity(0.8),
                AppTheme.primaryPurple.withOpacity(0.6),
              ],
            ),
            onPressed: () => _goToPayment(booking),
          ),
        if (canShowPayButton) const SizedBox(height: 8),
        if (booking.canModify)
          _buildCompactActionButton(
            icon: Icons.edit_rounded,
            label: context.tr('booking.details.editBooking'),
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryPurple.withOpacity(0.8),
                AppTheme.primaryViolet.withOpacity(0.6),
              ],
            ),
            onPressed: () => _modifyBooking(booking),
          ),
        if (booking.canCancel) ...[
          const SizedBox(height: 8),
          _buildCompactActionButton(
            icon: Icons.cancel_rounded,
            label: context.tr('booking.details.cancelBooking'),
            gradient: LinearGradient(
              colors: [
                AppTheme.error.withOpacity(0.8),
                AppTheme.error.withOpacity(0.6),
              ],
            ),
            onPressed: () => _cancelBooking(booking),
          ),
        ],
        if (!booking.canCancel &&
            booking.status == BookingStatus.confirmed &&
            (booking.cancelNotAllowedReason != null &&
                booking.cancelNotAllowedReason.toString().isNotEmpty)) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.warning.withOpacity(0.35),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.warning,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking.cancelNotAllowedReason,
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textWhite.withOpacity(0.95),
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (booking.status == BookingStatus.completed && booking.canReview) ...[
          const SizedBox(height: 8),
          _buildCompactActionButton(
            icon: Icons.rate_review_rounded,
            label: context.tr('booking.details.writeReview'),
            gradient: LinearGradient(
              colors: [
                AppTheme.warning.withOpacity(0.8),
                AppTheme.warning.withOpacity(0.6),
              ],
            ),
            onPressed: () => _writeReview(booking),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
    LinearGradient? gradient,
    Color? borderColor,
    bool showUnderline = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (borderColor ?? iconColor).withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Padding(
        //
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textWhite.withOpacity(0.9),
                        ),
                      ),
                      if (showUnderline) ...[
                        const SizedBox(height: 4),
                        Container(
                          height: 2,
                          width: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                AppTheme.primaryBlue.withOpacity(0.9),
                                AppTheme.primaryPurple.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 12,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textWhite.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActionButton({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTapDown: (_) => HapticFeedback.selectionClick(),
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 42,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  Widget _buildMinimalLoader() {
    return LoadingWidget(
      type: LoadingType.futuristic,
      message: context.tr('booking.details.loading'),
    );
  }

  Widget _buildMinimalError(BookingError state) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.error.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 24,
              color: AppTheme.error.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('booking.details.errorTitle'),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.error.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.error.withOpacity(0.7),
                  AppTheme.error.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _loadBookingDetails,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        context.tr('booking.details.retry'),
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return AppTheme.success.withOpacity(0.8);
      case BookingStatus.pending:
        return AppTheme.warning.withOpacity(0.8);
      case BookingStatus.cancelled:
        return AppTheme.error.withOpacity(0.8);
      case BookingStatus.completed:
        return AppTheme.info.withOpacity(0.8);
      case BookingStatus.checkedIn:
        return AppTheme.primaryBlue.withOpacity(0.8);
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Icons.check_circle_rounded;
      case BookingStatus.pending:
        return Icons.hourglass_empty_rounded;
      case BookingStatus.cancelled:
        return Icons.cancel_rounded;
      case BookingStatus.completed:
        return Icons.done_all_rounded;
      case BookingStatus.checkedIn:
        return Icons.login_rounded;
    }
  }

  void _shareBooking() {
    HapticFeedback.selectionClick();
    // Implementation
  }

  void _modifyBooking(dynamic booking) {
    HapticFeedback.selectionClick();
    // Navigate to modify booking
  }

  void _cancelBooking(dynamic booking) {
    HapticFeedback.mediumImpact();
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      context.go('/login');
      return;
    }

    final reasonController = TextEditingController();
    showDialog(
      context: context,
      barrierColor: AppTheme.overlayDark,
      builder: (ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.error.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cancel_rounded,
                          color: AppTheme.error, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          context.tr('booking.details.cancelConfirmTitle'),
                          style: AppTextStyles.h3.copyWith(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('booking.details.cancelConfirmMessage'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textMuted,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: reasonController,
                    maxLines: 2,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppTheme.textWhite),
                    decoration: InputDecoration(
                      hintText: context.tr('booking.details.cancelReasonHint'),
                      hintStyle: AppTextStyles.bodySmall
                          .copyWith(color: AppTheme.textMuted),
                      filled: true,
                      fillColor: AppTheme.darkCard.withOpacity(0.6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.darkBorder.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.darkBorder.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppTheme.darkSurface.withOpacity(0.6),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            context.tr('booking.details.back'),
                            style: AppTextStyles.buttonMedium
                                .copyWith(color: AppTheme.textWhite),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _pendingCancelBookingId = booking.id;
                            _pendingCancelUserId = authState.user.userId;
                            _pendingCancelReason = reasonController.text.trim();
                            context.read<BookingBloc>().add(
                                  CancelBookingEvent(
                                    bookingId: booking.id,
                                    userId: authState.user.userId,
                                    reason: reasonController.text.trim(),
                                    refundPayments: false,
                                  ),
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.error,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            context.tr('booking.details.cancelBooking'),
                            style: AppTextStyles.buttonMedium
                                .copyWith(color: Colors.white),
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
      },
    ).then((_) => reasonController.dispose());
  }

  void _writeReview(dynamic booking) {
    HapticFeedback.selectionClick();
    context.push('/review/write', extra: {
      'bookingId': booking.id,
      'propertyId': booking.propertyId,
      'propertyName': booking.propertyName,
    });
  }

  void _openPropertyDetails(dynamic booking) {
    HapticFeedback.selectionClick();
    context.push('/property/${booking.propertyId}');
  }

  Future<void> _goToPayment(dynamic booking) async {
    HapticFeedback.selectionClick();

    final int nights = booking.numberOfNights;
    double servicesTotal = 0.0;
    try {
      for (final s in booking.services) {
        servicesTotal += (s.totalPrice).toDouble();
      }
    } catch (_) {}

    double pricePerNight = 0.0;
    if (nights > 0) {
      final totalAmount = (booking.totalAmount).toDouble();
      pricePerNight = (totalAmount - servicesTotal) / nights;
    }
    if (pricePerNight.isNaN || pricePerNight.isInfinite || pricePerNight < 0) {
      pricePerNight = 0.0;
    }

    final selectedServices = booking.services
        .map<Map<String, dynamic>>((s) => {
              'name': s.serviceName,
              'price': s.totalPrice,
            })
        .toList();

    final bookingData = {
      'propertyId': booking.propertyId,
      'propertyName': booking.propertyName,
      'unitId': booking.unitId,
      'unitName': booking.unitName,
      'unitImages': booking.unitImages,
      'currency': booking.currency,
      'checkIn': booking.checkInDate,
      'checkOut': booking.checkOutDate,
      'adultsCount': booking.adultGuests,
      'childrenCount': booking.childGuests,
      'selectedServices': selectedServices,
      'specialRequests': booking.specialRequests ?? '',
      'pricePerNight': pricePerNight,
      'totalAmount': booking.totalAmount,
      'bookingId': booking.id,
      'returnToPrevious': true,
    };

    final paid =
        await context.push<bool>('/booking/payment', extra: bookingData);
    if (!mounted) return;
    if (paid == true) {
      _hasChanges = true;
      _loadBookingDetails();
    }
  }
}

// Subtle Detail Pattern Painter
class _SubtleDetailPatternPainter extends CustomPainter {
  final double animationValue;
  final double scrollOffset;

  _SubtleDetailPatternPainter({
    required this.animationValue,
    required this.scrollOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.2;

    // Draw subtle grid
    const spacing = 40.0;
    final offset = scrollOffset * 0.02 % spacing;

    for (double x = -spacing + offset; x < size.width + spacing; x += spacing) {
      paint.color = AppTheme.primaryBlue.withOpacity(0.02);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = -spacing + offset;
        y < size.height + spacing;
        y += spacing) {
      paint.color = AppTheme.primaryPurple.withOpacity(0.02);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _BookingPolicyVisual {
  final String title;
  final IconData icon;
  final Color color;

  const _BookingPolicyVisual({
    required this.title,
    required this.icon,
    required this.color,
  });
}
