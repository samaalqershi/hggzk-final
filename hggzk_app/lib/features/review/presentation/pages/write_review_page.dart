import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hggzk/core/error/failure_localizer.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:hggzk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hggzk/features/auth/presentation/bloc/auth_state.dart';
import 'package:hggzk/features/booking/domain/usecases/get_booking_details_usecase.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import 'package:hggzk/app/dependency_injection/injection_container.dart';
import '../bloc/review_bloc.dart';
import '../bloc/review_event.dart';
import '../bloc/review_state.dart';
import '../widgets/review_form_widget.dart';

/// Hosts the review form used after a completed booking.
/// يستضيف نموذج المراجعة المستخدم بعد انتهاء الحجز.
class WriteReviewPage extends StatefulWidget {
  /// Booking that the new review belongs to.
  /// الحجز الذي ستنتمي إليه المراجعة الجديدة.
  final String bookingId;

  /// Property being reviewed.
  /// العقار محل المراجعة.
  final String propertyId;

  /// Property name shown in the page header.
  /// اسم العقار الظاهر في ترويسة الصفحة.
  final String propertyName;

  /// Builds the page used to submit a new review.
  /// ينشئ الصفحة المستخدمة لإرسال مراجعة جديدة.
  const WriteReviewPage({
    super.key,
    required this.bookingId,
    required this.propertyId,
    required this.propertyName,
  });

  /// Creates the state object that loads booking context when needed.
  /// ينشئ كائن الحالة الذي يجلب سياق الحجز عند الحاجة.
  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

/// Resolves the booking context and orchestrates review submission.
/// يحل سياق الحجز وينسق عملية إرسال المراجعة.
class _WriteReviewPageState extends State<WriteReviewPage> {
  /// Property id resolved from the booking when needed.
  /// معرّف العقار الذي يتم حله من الحجز عند الحاجة.
  late String _propertyId;

  /// Property name resolved from the booking when needed.
  /// اسم العقار الذي يتم حله من الحجز عند الحاجة.
  late String _propertyName;

  /// True while booking details are still being fetched.
  /// تكون صحيحة أثناء استمرار جلب تفاصيل الحجز.
  bool _isLoadingBookingDetails = false;

  /// User-facing error message when booking lookup fails.
  /// رسالة خطأ موجهة للمستخدم عندما يفشل جلب الحجز.
  String? _bookingDetailsError;

  /// Prepares the page state and resolves booking data if needed.
  /// يجهز حالة الصفحة ويحل بيانات الحجز عند الحاجة.
  @override
  void initState() {
    super.initState();
    _propertyId = widget.propertyId;
    _propertyName = widget.propertyName;

    if (_propertyId.trim().isEmpty) {
      _loadBookingDetails();
    }
  }

  /// Loads the booking details needed to infer the property context.
  /// يحمل تفاصيل الحجز اللازمة لاستنتاج سياق العقار.
  Future<void> _loadBookingDetails() async {
    setState(() {
      _isLoadingBookingDetails = true;
      _bookingDetailsError = null;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _bookingDetailsError = context.tr(
            'reviews.loginRequiredFirst',
          );
        });
        return;
      }

      final result = await sl<GetBookingDetailsUseCase>()(
        GetBookingDetailsParams(
          bookingId: widget.bookingId,
          userId: authState.user.userId,
        ),
      );

      result.fold(
        (failure) {
          setState(() {
            _bookingDetailsError = FailureLocalizer.localize(failure);
          });
        },
        (booking) {
          setState(() {
            _propertyId = booking.propertyId;
            if (_propertyName.trim().isEmpty) {
              _propertyName = booking.propertyName;
            }
          });
        },
      );
    } catch (e) {
      setState(() {
        _bookingDetailsError = context.tr('common.unexpectedError');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBookingDetails = false;
        });
      }
    }
  }

  /// Builds the widget tree for this component.
  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoadingBookingDetails) {
      return Scaffold(
        backgroundColor:
            isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        body: Center(
          child: LoadingWidget(
            type: LoadingType.circular,
            message: context.tr(
              'reviews.loadingBookingDetails',
            ),
          ),
        ),
      );
    }

    if (_bookingDetailsError != null) {
      return Scaffold(
        backgroundColor:
            isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: AppTheme.textWhite),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _bookingDetailsError!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loadBookingDetails,
                    child: Text(
                      context.tr(
                        'reviews.retry',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) => sl<ReviewBloc>(),
      child: _WriteReviewView(
        bookingId: widget.bookingId,
        propertyId: _propertyId,
        propertyName: _propertyName,
      ),
    );
  }
}

/// Describes `WriteReviewView`.
/// العربية: يمثل `WriteReviewView`.
class _StarryBackground extends StatelessWidget {
  final bool isDark;

  const _StarryBackground({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarryBackgroundPainter(isDark: isDark),
    );
  }
}

class _StarryBackgroundPainter extends CustomPainter {
  static const int _starCount = 42;
  final bool isDark;

  const _StarryBackgroundPainter({
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [
                Color(0xFF050816),
                Color(0xFF050816),
              ]
            : const [
                Color(0xFFF8FBFF),
                Color(0xFFF1F7FF),
              ],
      ).createShader(rect);

    canvas.drawRect(rect, backgroundPaint);

    final random = math.Random(7);
    final starPaint = Paint()
      ..color = (isDark ? Colors.white : AppTheme.primaryBlue)
          .withOpacity(isDark ? 0.32 : 0.08)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < _starCount; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = 0.4 + random.nextDouble() * 1.3;
      canvas.drawCircle(Offset(dx, dy), radius, starPaint);
    }

    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    final glowColors = [
      AppTheme.primaryBlue.withOpacity(isDark ? 0.18 : 0.1),
      AppTheme.primaryPurple.withOpacity(isDark ? 0.16 : 0.08),
      AppTheme.primaryCyan.withOpacity(isDark ? 0.14 : 0.07),
    ];

    for (final color in glowColors) {
      glowPaint.color = color;
      final dx = (0.2 + random.nextDouble() * 0.6) * size.width;
      final dy = (0.1 + random.nextDouble() * 0.6) * size.height;
      final radius = size.shortestSide * (0.25 + random.nextDouble() * 0.2);
      canvas.drawCircle(Offset(dx, dy), radius, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WriteReviewView extends StatelessWidget {
  /// Keeps the `bookingId` value.
  /// العربية: يخزن القيمة `bookingId`.
  final String bookingId;

  /// Keeps the `propertyId` value.
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;

  /// Keeps the `propertyName` value.
  /// العربية: يخزن القيمة `propertyName`.
  final String propertyName;

  /// Builds a new `WriteReviewView` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `WriteReviewView`.
  const _WriteReviewView({
    required this.bookingId,
    required this.propertyId,
    required this.propertyName,
  });

  /// Builds the widget tree for this component.
  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          _buildFuturisticBackground(context),
          BlocConsumer<ReviewBloc, ReviewState>(
            listener: (context, state) {
              if (state is ReviewCreated) {
                _showSuccessDialog(context);
              } else if (state is ReviewCreateError) {
                _showErrorSnackBar(context, state.message);
              }
            },
            builder: (context, state) {
              final isCreating = state is ReviewCreating;
              final progress = isCreating ? state.progress : 0.0;

              return Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSmall,
                      vertical: AppDimensions.paddingMedium,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPropertyInfo(context),
                        const SizedBox(height: AppDimensions.spacingMd),
                        _buildFormCard(context),
                      ],
                    ),
                  ),
                  if (isCreating)
                    Positioned.fill(
                      child: Container(
                        color: AppTheme.overlayDark.withOpacity(0.28),
                        alignment: Alignment.center,
                        child: Container(
                          margin: const EdgeInsets.all(24),
                          padding: const EdgeInsets.all(
                            AppDimensions.paddingMedium,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.darkSurface.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusLg,
                            ),
                            border: Border.all(
                              color: AppTheme.primaryBlue.withOpacity(0.24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withOpacity(0.14),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('reviews.sendingReview'),
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppTheme.textWhite,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spacingSm),
                              LinearProgressIndicator(
                                value: progress > 0 ? progress : null,
                                minHeight: 8,
                                backgroundColor:
                                    AppTheme.darkBorder.withOpacity(0.6),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryBlue,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              const SizedBox(height: AppDimensions.spacingSm),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  progress > 0
                                      ? '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%'
                                      : '...',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppTheme.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds the app bar.
  /// العربية: يبني app bar.
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.close,
          color: Colors.white,
        ),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.98),
              AppTheme.darkCard.withOpacity(0.9),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
      ),
      title: ShaderMask(
        shaderCallback: (bounds) =>
            AppTheme.primaryGradient.createShader(bounds),
        child: Text(
          context.tr('reviews.writeReviewTitle'),
          style: AppTextStyles.h2.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppTheme.primaryBlue.withOpacity(0.25),
        ),
      ),
    );
  }

  /// Builds the property info.
  /// العربية: يبني property info.
  Widget _buildPropertyInfo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.45),
          width: 0.8,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard.withOpacity(0.98),
            AppTheme.darkSurface.withOpacity(0.98),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('reviews.experienceAt'),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 2,
                      width: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            AppTheme.primaryCyan.withOpacity(0.9),
                            AppTheme.primaryPurple.withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.45),
                    width: 0.8,
                  ),
                ),
                child: const Icon(
                  Icons.rate_review_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            propertyName,
            style: AppTextStyles.h2.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the form card.
  /// العربية: يبني form card.
  Widget _buildFormCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppDimensions.borderRadiusLg,
        ),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.5),
          width: 0.9,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard.withOpacity(0.96),
            AppTheme.darkSurface.withOpacity(0.96),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.22),
            blurRadius: 26,
            spreadRadius: 1,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          AppDimensions.borderRadiusLg,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.all(
              AppDimensions.paddingMedium,
            ),
            child: ReviewFormWidget(
              onSubmit: (ratings, comment, images) {
                if (propertyId.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.tr('reviews.cannotDetermineProperty'),
                      ),
                    ),
                  );
                  return;
                }
                context.read<ReviewBloc>().add(
                      CreateReviewEvent(
                        bookingId: bookingId,
                        propertyId: propertyId,
                        cleanliness: ratings['cleanliness']!,
                        service: ratings['service']!,
                        location: ratings['location']!,
                        value: ratings['value']!,
                        comment: comment,
                        imagesBase64: images,
                      ),
                    );
              },
              onSubmitWithMedia: (
                ratings,
                comment,
                images,
                videoBase64,
                videoThumbnailBase64,
              ) {
                if (propertyId.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.tr('reviews.cannotDetermineProperty'),
                      ),
                    ),
                  );
                  return;
                }
                context.read<ReviewBloc>().add(
                      CreateReviewEvent(
                        bookingId: bookingId,
                        propertyId: propertyId,
                        cleanliness: ratings['cleanliness']!,
                        service: ratings['service']!,
                        location: ratings['location']!,
                        value: ratings['value']!,
                        comment: comment,
                        imagesBase64: images,
                        videoBase64: videoBase64,
                        videoThumbnailBase64: videoThumbnailBase64,
                      ),
                    );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the futuristic background.
  /// العربية: يبني futuristic background.
  Widget _buildFuturisticBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned.fill(
      child: _StarryBackground(isDark: isDark),
    );
  }

  /// Shows the success dialog.
  /// العربية: يعرض success dialog.
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
          ),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppTheme.success,
                    size: 48,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                Text(
                  context.tr(
                    'reviews.thanks',
                  ),
                  style: AppTextStyles.h2.copyWith(
                    color: AppTheme.textWhite,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  context.tr(
                    'reviews.reviewSubmittedMessage',
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacingXl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.pop(true); // Return true to indicate success
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingMedium,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusMd,
                        ),
                      ),
                    ),
                    child: Text(
                      context.tr(
                        'reviews.ok',
                      ),
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: AppTheme.textWhite,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Shows the error snack bar.
  /// العربية: يعرض error snack bar.
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSm),
        ),
      ),
    );
  }
}
