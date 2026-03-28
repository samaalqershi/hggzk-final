import 'package:hggzkportal/features/admin_reviews/domain/repositories/reviews_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/booking_details.dart';
import '../../../../../../core/error/failures.dart';
import '../../../domain/usecases/bookings/get_booking_by_id_usecase.dart';
import '../../../domain/usecases/bookings/cancel_booking_usecase.dart';
import '../../../domain/usecases/bookings/update_booking_usecase.dart';
import '../../../domain/usecases/bookings/confirm_booking_usecase.dart';
import '../../../domain/usecases/bookings/check_in_usecase.dart';
import '../../../domain/usecases/bookings/check_out_usecase.dart';
import '../../../domain/usecases/services/add_service_to_booking_usecase.dart';
import '../../../domain/usecases/services/remove_service_from_booking_usecase.dart';
import '../../../domain/usecases/services/get_booking_services_usecase.dart';
import '../../../domain/repositories/bookings_repository.dart';
import 'booking_details_event.dart';
import 'booking_details_state.dart';
import '../../../../../../core/utils/invoice_pdf.dart';
import '../../../../../../core/utils/pdf_helper.dart';

/// العربية: يدير تفاصيل الحجز الكاملة من التحميل والتعديل حتى الطباعة والمشاركة وإرسال التأكيد.
/// English: Manages the full booking-details flow from loading and editing to printing, sharing, and sending confirmations.
class BookingDetailsBloc
    extends Bloc<BookingDetailsEvent, BookingDetailsState> {
  /// العربية: يجلب تفاصيل الحجز الأساسية من مصدرها الرئيسي.
  /// English: Fetches the primary booking record from its source.
  final GetBookingByIdUseCase getBookingByIdUseCase;

  /// العربية: ينفذ إلغاء الحجز مع سبب الإلغاء وخيارات الاسترجاع.
  /// English: Cancels a booking with reason handling and refund options.
  final CancelBookingUseCase cancelBookingUseCase;

  /// العربية: ينفذ تحديث التواريخ أو عدد الضيوف للحجز.
  /// English: Applies date or guest-count updates to the booking.
  final UpdateBookingUseCase updateBookingUseCase;

  /// العربية: يعتمد الحجز عند الحاجة إلى تأكيده.
  /// English: Confirms the booking when it needs approval.
  final ConfirmBookingUseCase confirmBookingUseCase;

  /// العربية: ينفذ تسجيل الوصول للحجز المحدد.
  /// English: Performs check-in for the selected booking.
  final CheckInUseCase checkInUseCase;

  /// العربية: ينفذ تسجيل المغادرة للحجز المحدد.
  /// English: Performs check-out for the selected booking.
  final CheckOutUseCase checkOutUseCase;

  /// العربية: يضيف خدمة إلى الحجز عند اختيار المستخدم لها.
  /// English: Adds a service to the booking when the user selects one.
  final AddServiceToBookingUseCase addServiceToBookingUseCase;

  /// العربية: يزيل خدمة من الحجز عند طلب المستخدم.
  /// English: Removes a service from the booking when requested by the user.
  final RemoveServiceFromBookingUseCase removeServiceFromBookingUseCase;

  /// العربية: يجلب الخدمات المرتبطة بالحجز لتحديث العرض.
  /// English: Fetches the services attached to the booking to refresh the view.
  final GetBookingServicesUseCase getBookingServicesUseCase;

  /// العربية: يتعامل مع عمليات التخزين والاستعلام الخاصة بالحجوزات عند الحاجة.
  /// English: Handles repository-level booking interactions when needed.
  final BookingsRepository repository;

  /// العربية: يتيح جلب التقييم المرتبط بالحجز لعرضه ضمن التفاصيل.
  /// English: Allows loading the review associated with a booking for the details view.
  final ReviewsRepository reviewsRepository;

  /// العربية: يحفظ معرّف الحجز الجاري عرضه حتى يمكن إعادة تحميله بعد العمليات.
  /// English: Stores the currently displayed booking id so it can be reloaded after actions.
  String? _currentBookingId;

  /// العربية: يحوّل أي حالة عملية إلى لقطة تفاصيل قابلة لإعادة الاستخدام في المعالجات التالية.
  /// English: Converts operation states into a reusable loaded snapshot for later handlers.
  BookingDetailsLoaded? _currentLoadedLike() {
    final s = state;
    if (s is BookingDetailsLoaded) return s;
    if (s is BookingDetailsOperationFailure) {
      return BookingDetailsLoaded(
        booking: s.booking,
        bookingDetails: s.bookingDetails,
        services: s.services,
        isRefreshing: false,
      );
    }
    if (s is BookingDetailsOperationSuccess) {
      return BookingDetailsLoaded(
        booking: s.booking,
        bookingDetails: s.bookingDetails,
        services: s.services,
        isRefreshing: false,
      );
    }
    return null;
  }

  /// العربية: ينشئ BLoC تفاصيل الحجز ويربط جميع الأحداث بمعالجاتها.
  /// English: Creates the booking-details bloc and wires every event to its handler.
  BookingDetailsBloc({
    required this.getBookingByIdUseCase,
    required this.cancelBookingUseCase,
    required this.updateBookingUseCase,
    required this.confirmBookingUseCase,
    required this.checkInUseCase,
    required this.checkOutUseCase,
    required this.addServiceToBookingUseCase,
    required this.removeServiceFromBookingUseCase,
    required this.getBookingServicesUseCase,
    required this.repository,
    required this.reviewsRepository,
  }) : super(BookingDetailsInitial()) {
    on<LoadBookingDetailsEvent>(_onLoadBookingDetails);
    on<RefreshBookingDetailsEvent>(_onRefreshBookingDetails);
    on<UpdateBookingDetailsEvent>(_onUpdateBookingDetails);
    on<CancelBookingDetailsEvent>(_onCancelBookingDetails);
    on<ConfirmBookingDetailsEvent>(_onConfirmBookingDetails);
    on<CheckInBookingDetailsEvent>(_onCheckInBookingDetails);
    on<CheckOutBookingDetailsEvent>(_onCheckOutBookingDetails);
    on<AddServiceEvent>(_onAddService);
    on<RemoveServiceEvent>(_onRemoveService);
    on<LoadBookingServicesEvent>(_onLoadBookingServices);
    on<LoadBookingActivitiesEvent>(_onLoadBookingActivities);
    on<LoadBookingPaymentsEvent>(_onLoadBookingPayments);
    on<PrintBookingDetailsEvent>(_onPrintBookingDetails);
    on<ShareBookingDetailsEvent>(_onShareBookingDetails);
    on<SendBookingConfirmationEvent>(_onSendBookingConfirmation);
  }

  /// العربية: يجلب الحجز والتفاصيل والخدمات والتقييم المرتبط ثم يبني حالة عرض كاملة.
  /// English: Loads the booking, its details, services, and review before building a full view state.
  Future<void> _onLoadBookingDetails(
    LoadBookingDetailsEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    // إذا كانت هذه عملية refresh وليس تحميل أولي، لا نُظهر شاشة loading كاملة
    if (state is! BookingDetailsLoaded) {
      emit(BookingDetailsLoading());
    }
    _currentBookingId = event.bookingId;

    // جلب البيانات الأساسية
    final bookingResult = await getBookingByIdUseCase(
      GetBookingByIdParams(bookingId: event.bookingId),
    );

    await bookingResult.fold(
      (failure) async {
        emit(BookingDetailsError(message: failure.message));
      },
      (booking) async {
        // جلب التفاصيل الإضافية
        final detailsResult = await repository.getBookingDetails(
          bookingId: event.bookingId,
        );

        await detailsResult.fold(
          (failure) async {
            // إذا فشل جلب التفاصيل، عرض البيانات الأساسية فقط
            emit(BookingDetailsLoaded(
              booking: booking,
              bookingDetails: null,
              services: const [],
              isRefreshing: false,
            ));
          },
          (details) async {
            // جلب الخدمات
            final servicesResult = await getBookingServicesUseCase(
              GetBookingServicesParams(bookingId: event.bookingId),
            );

            final services = servicesResult.fold(
              (_) => <Service>[],
              (services) => services,
            );

            // جلب التقييم المرتبط بالحجز (إن وجد)
            final reviewResult =
                await reviewsRepository.getReviewByBooking(event.bookingId);
            final review = reviewResult.fold((_) => null, (r) => r);

            emit(BookingDetailsLoaded(
              booking: booking,
              bookingDetails: details,
              services: services,
              isRefreshing: false,
              review: review,
            ));
          },
        );
      },
    );
  }

  /// العربية: يعيد تنفيذ آخر تحميل للحجز نفسه مع الحفاظ على لقطة العرض الحالية.
  /// English: Replays the last booking load while preserving the current view snapshot.
  Future<void> _onRefreshBookingDetails(
    RefreshBookingDetailsEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    if (_currentBookingId != null) {
      final currentState = _currentLoadedLike();
      if (currentState != null) {
        emit(currentState.copyWith(isRefreshing: true));
      }
      add(LoadBookingDetailsEvent(bookingId: _currentBookingId!));
    }
  }

  /// العربية: يرسل طلب تعديل الحجز ثم يرفع حالة نجاح أو فشل العملية.
  /// English: Sends the booking update request and emits a success or failure state.
  Future<void> _onUpdateBookingDetails(
    UpdateBookingDetailsEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    final currentState = _currentLoadedLike();
    if (currentState != null) {
      emit(BookingDetailsOperationInProgress(
        booking: currentState.booking,
        bookingDetails: currentState.bookingDetails,
        services: currentState.services,
        operation: 'update',
      ));

      final result = await updateBookingUseCase(
        UpdateBookingParams(
          bookingId: event.bookingId,
          checkIn: event.checkIn,
          checkOut: event.checkOut,
          guestsCount: event.guestsCount,
        ),
      );

      await result.fold(
        (failure) async {
          emit(BookingDetailsOperationFailure(
            booking: currentState.booking,
            bookingDetails: currentState.bookingDetails,
            services: currentState.services,
            message: failure.message,
          ));
        },
        (_) async {
          emit(BookingDetailsOperationSuccess(
            booking: currentState.booking,
            bookingDetails: currentState.bookingDetails,
            services: currentState.services,
            message: 'تم تحديث الحجز بنجاح',
          ));
          add(const RefreshBookingDetailsEvent());
        },
      );
    }
  }

  /// العربية: يلغي الحجز مع معالجة رسائل الخادم والحفاظ على البيانات المعروضة.
  /// English: Cancels the booking while handling server messages and keeping visible data intact.
  /// العربية: يلغي الحجز مع معالجة رسائل الخادم والحفاظ على البيانات المعروضة.
  /// English: Cancels the booking while handling server messages and keeping visible data intact.
  Future<void> _onCancelBookingDetails(
    CancelBookingDetailsEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    debugPrint('🔴 [BookingDetailsBloc] بدء إلغاء الحجز: ${event.bookingId}');
    debugPrint(
        '🔴 [BookingDetailsBloc] سبب الإلغاء: ${event.cancellationReason}');

    final currentState = _currentLoadedLike();
    if (currentState != null) {
      debugPrint(
          '🔄 [BookingDetailsBloc] الحالة الحالية: BookingDetailsLoaded');

      emit(BookingDetailsOperationInProgress(
        booking: currentState.booking,
        bookingDetails: currentState.bookingDetails,
        services: currentState.services,
        operation: 'cancel',
      ));

      debugPrint('⏳ [BookingDetailsBloc] استدعاء cancelBookingUseCase...');

      final result = await cancelBookingUseCase(
        CancelBookingParams(
          bookingId: event.bookingId,
          cancellationReason: event.cancellationReason,
          refundPayments: event.refundPayments,
        ),
      );

      await result.fold(
        (failure) async {
          debugPrint('❌ [BookingDetailsBloc] فشل الإلغاء: ${failure.message}');
          String message = failure.message;
          if (failure is ServerFailure && failure.showAsDialog) {
            message = failure.code ?? failure.message;
          }
          emit(BookingDetailsOperationFailure(
            booking: currentState.booking,
            bookingDetails: currentState.bookingDetails,
            services: currentState.services,
            message: message,
          ));
        },
        (_) async {
          debugPrint('✅ [BookingDetailsBloc] نجح الإلغاء');
          emit(BookingDetailsOperationSuccess(
            booking: currentState.booking,
            bookingDetails: currentState.bookingDetails,
            services: currentState.services,
            message: 'تم إلغاء الحجز بنجاح',
          ));
          await Future.delayed(const Duration(milliseconds: 500));
          debugPrint('🔄 [BookingDetailsBloc] إعادة تحميل تفاصيل الحجز...');
          add(LoadBookingDetailsEvent(bookingId: event.bookingId));
        },
      );
    } else {
      debugPrint(
          '⚠️ [BookingDetailsBloc] الحالة الحالية ليست BookingDetailsLoaded: ${state.runtimeType}');
    }
  }

  /// العربية: يعتمد الحجز ويحوّل الفشل المتعلق بالإتاحة إلى رسالة مفهومة للمستخدم.
  /// English: Confirms the booking and translates availability-related failures into a user-friendly message.
  /// العربية: يعتمد الحجز ويحوّل الفشل المتعلق بالإتاحة إلى رسالة مفهومة للمستخدم.
  /// English: Confirms the booking and translates availability-related failures into a user-friendly message.
  Future<void> _onConfirmBookingDetails(
    ConfirmBookingDetailsEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    debugPrint('🔵 [BookingDetailsBloc] بدء تأكيد الحجز: ${event.bookingId}');

    final currentState = _currentLoadedLike();
    if (currentState != null) {
      debugPrint(
          '📋 [BookingDetailsBloc] حالة الحجز الحالية: ${currentState.booking.status}');

      emit(BookingDetailsOperationInProgress(
        booking: currentState.booking,
        bookingDetails: currentState.bookingDetails,
        services: currentState.services,
        operation: 'confirm',
      ));

      debugPrint('⏳ [BookingDetailsBloc] استدعاء confirmBookingUseCase...');

      final result = await confirmBookingUseCase(
        ConfirmBookingParams(bookingId: event.bookingId),
      );

      await result.fold(
        (failure) async {
          debugPrint('❌ [BookingDetailsBloc] فشل التأكيد: ${failure.message}');
          String errorMessage = failure.message;
          if (failure.message.contains('غير متاحة') ||
              failure.message.toLowerCase().contains('not available') ||
              failure.message.toLowerCase().contains('no longer available')) {
            errorMessage = '''الوحدة غير متاحة في التواريخ المحددة.
            
قد يكون السبب:
• تم حجز الوحدة من قبل شخص آخر
• تعارض في التواريخ مع حجز آخر
• الوحدة محظورة أو قيد الصيانة

يرجى التحقق من جدول الإتاحة والمحاولة مرة أخرى.''';
          }
          emit(BookingDetailsOperationFailure(
            booking: currentState.booking,
            bookingDetails: currentState.bookingDetails,
            services: currentState.services,
            message: errorMessage,
          ));
        },
        (_) async {
          debugPrint('✅ [BookingDetailsBloc] نجح التأكيد');
          emit(BookingDetailsOperationSuccess(
            booking: currentState.booking,
            bookingDetails: currentState.bookingDetails,
            services: currentState.services,
            message: 'تم تأكيد الحجز بنجاح',
          ));
          await Future.delayed(const Duration(milliseconds: 500));
          debugPrint('🔄 [BookingDetailsBloc] إعادة تحميل تفاصيل الحجز...');
          add(LoadBookingDetailsEvent(bookingId: event.bookingId));
        },
      );
    } else {
      debugPrint(
          '⚠️ [BookingDetailsBloc] الحالة الحالية ليست BookingDetailsLoaded: ${state.runtimeType}');
    }
  }

  /// العربية: يسجل وصول الضيف ثم يعيد تحميل التفاصيل بعد نجاح العملية.
  /// English: Checks the guest in and reloads the booking details after success.
  /// العربية: يسجل وصول الضيف ثم يعيد تحميل تفاصيل الحجز بعد النجاح.
  /// English: Checks the guest in and reloads the booking details after success.
  Future<void> _onCheckInBookingDetails(
    CheckInBookingDetailsEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    final currentState = _currentLoadedLike();
    if (currentState != null) {
      emit(BookingDetailsOperationInProgress(
        booking: currentState.booking,
        bookingDetails: currentState.bookingDetails,
        services: currentState.services,
        operation: 'checkIn',
      ));

      final result = await checkInUseCase(
        CheckInParams(bookingId: event.bookingId),
      );

      await result.fold(
        (failure) async {
          emit(BookingDetailsOperationFailure(
            booking: currentState.booking,
            bookingDetails: currentState.bookingDetails,
            services: currentState.services,
            message: failure.message,
          ));
        },
        (_) async {
          emit(BookingDetailsOperationSuccess(
            booking: currentState.booking,
            bookingDetails: currentState.bookingDetails,
            services: currentState.services,
            message: 'تم تسجيل الوصول بنجاح',
          ));
          await Future.delayed(const Duration(milliseconds: 500));
          add(LoadBookingDetailsEvent(bookingId: event.bookingId));
        },
      );
    }
  }

  /// العربية: يسجل المغادرة ثم يعيد تحميل التفاصيل بعد نجاح العملية.
  /// English: Checks the guest out and reloads the booking details after success.
  /// العربية: يسجل المغادرة ثم يعيد تحميل تفاصيل الحجز بعد النجاح.
  /// English: Checks the guest out and reloads the booking details after success.
  Future<void> _onCheckOutBookingDetails(
    CheckOutBookingDetailsEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    final currentState = _currentLoadedLike();
    if (currentState != null) {
      emit(BookingDetailsOperationInProgress(
        booking: currentState.booking,
        bookingDetails: currentState.bookingDetails,
        services: currentState.services,
        operation: 'checkOut',
      ));

      final result = await checkOutUseCase(
        CheckOutParams(bookingId: event.bookingId),
      );

      await result.fold(
        (failure) async {
          emit(BookingDetailsOperationFailure(
            booking: currentState.booking,
            bookingDetails: currentState.bookingDetails,
            services: currentState.services,
            message: failure.message,
          ));
        },
        (_) async {
          emit(BookingDetailsOperationSuccess(
            booking: currentState.booking,
            bookingDetails: currentState.bookingDetails,
            services: currentState.services,
            message: 'تم تسجيل المغادرة بنجاح',
          ));
          await Future.delayed(const Duration(milliseconds: 500));
          add(LoadBookingDetailsEvent(bookingId: event.bookingId));
        },
      );
    }
  }

  /// العربية: يضيف خدمة إلى الحجز ثم يحدّث قائمة الخدمات المعروضة.
  /// English: Adds a service to the booking and refreshes the displayed services list.
  /// العربية: يضيف خدمة إلى الحجز ثم يحدّث قائمة الخدمات المعروضة.
  /// English: Adds a service to the booking and refreshes the displayed services list.
  Future<void> _onAddService(
    AddServiceEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    final currentState = _currentLoadedLike();
    if (currentState != null) {
      emit(BookingDetailsOperationInProgress(
        booking: currentState.booking,
        bookingDetails: currentState.bookingDetails,
        services: currentState.services,
        operation: 'addService',
      ));

      final result = await addServiceToBookingUseCase(
        AddServiceToBookingParams(
          bookingId: event.bookingId,
          serviceId: event.serviceId,
        ),
      );

      await result.fold(
        (failure) async {
          emit(BookingDetailsOperationFailure(
            booking: currentState.booking,
            bookingDetails: currentState.bookingDetails,
            services: currentState.services,
            message: failure.message,
          ));
        },
        (_) async {
          emit(BookingDetailsOperationSuccess(
            booking: currentState.booking,
            bookingDetails: currentState.bookingDetails,
            services: currentState.services,
            message: 'تمت إضافة الخدمة بنجاح',
          ));
          add(LoadBookingServicesEvent(bookingId: event.bookingId));
        },
      );
    }
  }

  /// العربية: يزيل خدمة من الحجز ثم يحدّث قائمة الخدمات المعروضة.
  /// English: Removes a service from the booking and refreshes the displayed services list.
  /// العربية: يزيل خدمة من الحجز ثم يحدّث قائمة الخدمات المعروضة.
  /// English: Removes a service from the booking and refreshes the displayed services list.
  Future<void> _onRemoveService(
    RemoveServiceEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    final currentState = _currentLoadedLike();
    if (currentState != null) {
      emit(BookingDetailsOperationInProgress(
        booking: currentState.booking,
        bookingDetails: currentState.bookingDetails,
        services: currentState.services,
        operation: 'removeService',
      ));

      final result = await removeServiceFromBookingUseCase(
        RemoveServiceFromBookingParams(
          bookingId: event.bookingId,
          serviceId: event.serviceId,
        ),
      );

      await result.fold(
        (failure) async {
          emit(BookingDetailsOperationFailure(
            booking: currentState.booking,
            bookingDetails: currentState.bookingDetails,
            services: currentState.services,
            message: failure.message,
          ));
        },
        (_) async {
          emit(BookingDetailsOperationSuccess(
            booking: currentState.booking,
            bookingDetails: currentState.bookingDetails,
            services: currentState.services,
            message: 'تمت إزالة الخدمة بنجاح',
          ));
          add(LoadBookingServicesEvent(bookingId: event.bookingId));
        },
      );
    }
  }

  /// العربية: يجلب الخدمات المرتبطة بالحجز ويستبدلها في حالة العرض الحالية.
  /// English: Fetches the booking's services and replaces them in the current view state.
  /// العربية: يجلب الخدمات المرتبطة بالحجز ويستبدلها في حالة العرض الحالية.
  /// English: Fetches the booking's services and replaces them in the current view state.
  Future<void> _onLoadBookingServices(
    LoadBookingServicesEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    final currentState = _currentLoadedLike();
    if (currentState != null) {
      final result = await getBookingServicesUseCase(
        GetBookingServicesParams(bookingId: event.bookingId),
      );

      result.fold(
        (_) {},
        (services) {
          emit(currentState.copyWith(services: services));
        },
      );
    }
  }

  /// العربية: نقطة جاهزة لربط سجل الأنشطة إذا توفّر endpoint مناسب لاحقًا.
  /// English: Placeholder hook for activity loading when a suitable endpoint becomes available.
  /// العربية: نقطة جاهزة لربط سجل الأنشطة إذا توفّر endpoint مناسب لاحقًا.
  /// English: Placeholder hook for activity loading when a suitable endpoint becomes available.
  Future<void> _onLoadBookingActivities(
    LoadBookingActivitiesEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    // يمكن تنفيذها لاحقاً إذا توفر endpoint للأنشطة
  }

  /// العربية: نقطة جاهزة لربط مدفوعات الحجز إذا توفّر endpoint مناسب لاحقًا.
  /// English: Placeholder hook for loading booking payments when a suitable endpoint becomes available.
  /// العربية: نقطة جاهزة لربط مدفوعات الحجز إذا توفّر endpoint مناسب لاحقًا.
  /// English: Placeholder hook for loading booking payments when a suitable endpoint becomes available.
  Future<void> _onLoadBookingPayments(
    LoadBookingPaymentsEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    // يمكن تنفيذها لاحقاً إذا توفر endpoint للمدفوعات
  }

  /// العربية: ينشئ ملف الفاتورة أو المستند القابل للطباعة ثم يفتحه للمستخدم.
  /// English: Generates the printable invoice or document and opens it for the user.
  /// العربية: ينشئ ملف الفاتورة أو المستند القابل للطباعة ثم يفتحه للمستخدم.
  /// English: Generates the printable invoice or document and opens it for the user.
  Future<void> _onPrintBookingDetails(
    PrintBookingDetailsEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    if (state is BookingDetailsLoaded) {
      final currentState = state as BookingDetailsLoaded;
      emit(BookingDetailsPrinting(
        booking: currentState.booking,
        bookingDetails: currentState.bookingDetails,
        services: currentState.services,
      ));
      // توليد وحفظ ملف الفاتورة PDF مباشرة من التطبيق
      try {
        final details = currentState.bookingDetails ??
            BookingDetails(
              booking: currentState.booking,
              payments: const [],
              services: currentState.services,
            );
        final pdfBytes = await InvoicePdfGenerator.generate(details);
        final fileName =
            PdfHelper.generateInvoiceFileName(currentState.booking.id);
        await PdfHelper.saveAndOpenPdf(
          pdfBytes: pdfBytes,
          fileName: fileName,
        );
      } catch (error, stackTrace) {
        debugPrint(
          'Failed to generate or print invoice for booking ${currentState.booking.id}: $error',
        );
        addError(error, stackTrace);
      }
      emit(currentState);
    }
  }

  /// العربية: يهيئ تفاصيل الحجز للمشاركة ثم يعيد الحالة الأصلية بعد الانتهاء.
  /// English: Prepares the booking details for sharing and then restores the original state.
  /// العربية: يهيئ تفاصيل الحجز للمشاركة ثم يعيد الحالة الأصلية بعد الانتهاء.
  /// English: Prepares the booking details for sharing and then restores the original state.
  Future<void> _onShareBookingDetails(
    ShareBookingDetailsEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    if (state is BookingDetailsLoaded) {
      final currentState = state as BookingDetailsLoaded;
      emit(BookingDetailsSharing(
        booking: currentState.booking,
        bookingDetails: currentState.bookingDetails,
        services: currentState.services,
      ));
      // تنفيذ منطق المشاركة
      await Future.delayed(const Duration(seconds: 1));
      emit(currentState);
    }
  }

  /// العربية: يرسل تأكيد الحجز بشكل تمثيلي ثم يعرض نتيجة النجاح قبل العودة للحالة الأصلية.
  /// English: Sends the booking confirmation in a simulated flow, shows success, and returns to the original state.
  /// العربية: يرسل تأكيد الحجز بشكل تمثيلي ثم يعرض نتيجة النجاح قبل العودة للحالة الأصلية.
  /// English: Sends the booking confirmation in a simulated flow, shows success, and returns to the original state.
  Future<void> _onSendBookingConfirmation(
    SendBookingConfirmationEvent event,
    Emitter<BookingDetailsState> emit,
  ) async {
    if (state is BookingDetailsLoaded) {
      final currentState = state as BookingDetailsLoaded;
      emit(BookingDetailsSendingConfirmation(
        booking: currentState.booking,
        bookingDetails: currentState.bookingDetails,
        services: currentState.services,
      ));
      // تنفيذ منطق إرسال التأكيد
      await Future.delayed(const Duration(seconds: 2));
      emit(BookingDetailsOperationSuccess(
        booking: currentState.booking,
        bookingDetails: currentState.bookingDetails,
        services: currentState.services,
        message: 'تم إرسال تأكيد الحجز بنجاح',
      ));
      await Future.delayed(const Duration(seconds: 2));
      emit(currentState);
    }
  }
}
