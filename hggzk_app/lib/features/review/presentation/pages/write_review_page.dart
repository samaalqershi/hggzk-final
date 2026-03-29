import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hggzk/core/error/failure_localizer.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
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
    if (_isLoadingBookingDetails) {
      return Scaffold(
        backgroundColor: Colors.transparent,
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
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
                    color: Colors.white,
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          _buildFuturisticBackground(),
          BlocConsumer<ReviewBloc, ReviewState>(
            listener: (context, state) {
              if (state is ReviewCreated) {
                _showSuccessDialog(context);
              } else if (state is ReviewCreateError) {
                _showErrorSnackBar(context, state.message);
              }
            },
            builder: (context, state) {
              if (state is ReviewCreating) {
                return Center(
                  child: LoadingWidget(
                    type: LoadingType.circular,
                    message: context.tr(
                      'reviews.sendingReview',
                    ),
                  ),
                );
              }

              return SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPropertyInfo(context),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _buildFormCard(context),
                    ],
                  ),
                ),
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
          context.tr(
            'reviews.writeReviewTitle',
          ),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppTheme.primaryBlue.withOpacity(0.28),
            AppTheme.primaryPurple.withOpacity(0.24),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.35),
          width: 0.7,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.35),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.rate_review_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(
                          'reviews.reviewExperienceTitle',
                        ),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.textWhite.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        propertyName,
                        style: AppTextStyles.h2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
  }

  /// Builds the form card.
  /// العربية: يبني form card.
  Widget _buildFormCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.darkCard.withOpacity(0.92),
            AppTheme.darkCard.withOpacity(0.78),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.7),
          width: 0.7,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.stars_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    Expanded(
                      child: Text(
                        context.tr('reviews.reviewExperienceHint'),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.transparent),
              ReviewFormWidget(
                onSubmit: (ratings, comment, _) {
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
                          imagesBase64: null,
                        ),
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the futuristic background.
  /// العربية: يبني futuristic background.
  Widget _buildFuturisticBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.darkBackground,
            AppTheme.darkBackground2,
            AppTheme.darkBackground3,
          ],
        ),
      ),
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
