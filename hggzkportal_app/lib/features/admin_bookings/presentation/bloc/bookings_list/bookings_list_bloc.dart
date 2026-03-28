import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/models/paginated_result.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/usecases/bookings/cancel_booking_usecase.dart';
import '../../../domain/usecases/bookings/update_booking_usecase.dart';
import '../../../domain/usecases/bookings/confirm_booking_usecase.dart';
import '../../../domain/usecases/bookings/get_bookings_by_date_range_usecase.dart';
import '../../../domain/usecases/bookings/check_in_usecase.dart';
import '../../../domain/usecases/bookings/check_out_usecase.dart';
import 'bookings_list_event.dart';
import 'bookings_list_state.dart';

/// العربية: يدير قائمة الحجوزات وعملياتها المرتبطة مثل التحميل والتحديث والإلغاء والاختيار.
/// English: Manages the booking list and related actions such as loading, refreshing, canceling, and selection.
class BookingsListBloc extends Bloc<BookingsListEvent, BookingsListState> {
  /// العربية: ينفذ إلغاء الحجز مع سبب الإلغاء وخيار استرجاع الدفعات.
  /// English: Executes booking cancellation with a reason and optional payment refunds.
  final CancelBookingUseCase cancelBookingUseCase;

  /// العربية: ينفذ تحديث بيانات الحجز الحالي.
  /// English: Applies updates to the current booking.
  final UpdateBookingUseCase updateBookingUseCase;

  /// العربية: يعتمد الحجز بعد المراجعة أو الموافقة.
  /// English: Confirms a booking after review or approval.
  final ConfirmBookingUseCase confirmBookingUseCase;

  /// العربية: يجلب الحجوزات حسب النطاق الزمني والصفحة والفلاتر الحالية.
  /// English: Fetches bookings by date range, page, and active filters.
  final GetBookingsByDateRangeUseCase getBookingsByDateRangeUseCase;

  /// العربية: ينفذ تسجيل الوصول للحجوزات المؤكدة.
  /// English: Performs check-in for confirmed bookings.
  final CheckInUseCase checkInUseCase;

  /// العربية: ينفذ تسجيل المغادرة للحجوزات النشطة.
  /// English: Performs check-out for active bookings.
  final CheckOutUseCase checkOutUseCase;

  /// العربية: يحتفظ ببداية آخر نطاق بحث حتى يمكن إعادة استخدامه في التحديث والتنقل.
  /// English: Stores the start of the last query so refresh and pagination can reuse it.
  DateTime? _currentStartDate;

  /// العربية: يحتفظ بنهاية آخر نطاق بحث.
  /// English: Stores the end of the last query.
  DateTime? _currentEndDate;

  /// العربية: يحفظ فلتر المستخدم النشط بين الطلبات المتتالية.
  /// English: Preserves the active user filter between requests.
  String? _currentUserId;

  /// العربية: يحفظ اسم الضيف أو بريده المستخدم في البحث الأخير.
  /// English: Preserves the guest name or email from the last search.
  String? _currentGuestNameOrEmail;

  /// العربية: يحفظ فلتر الوحدة النشطة.
  /// English: Preserves the active unit filter.
  String? _currentUnitId;

  /// العربية: يحفظ فلتر مصدر الحجز النشط.
  /// English: Preserves the active booking source filter.
  String? _currentBookingSource;

  /// العربية: يحفظ رقم الصفحة الحالية لتسهيل إعادة التحميل والانتقال.
  /// English: Stores the current page number for refreshes and navigation.
  int _currentPageNumber = 1;

  /// العربية: يحفظ حجم الصفحة الحالي المستخدم في الاستعلامات اللاحقة.
  /// English: Stores the current page size used by subsequent queries.
  int _currentPageSize = 10;

  /// العربية: يمنع إطلاق طلبات تحميل إضافية متداخلة أثناء التحميل التدريجي.
  /// English: Prevents overlapping load-more requests during incremental loading.
  bool _isLoadingMore = false;

  /// العربية: ينشئ BLoC ويصل كل حدث بمعالجه المناسب.
  /// English: Creates the bloc and wires each event to its corresponding handler.
  BookingsListBloc({
    required this.cancelBookingUseCase,
    required this.updateBookingUseCase,
    required this.confirmBookingUseCase,
    required this.getBookingsByDateRangeUseCase,
    required this.checkInUseCase,
    required this.checkOutUseCase,
  }) : super(BookingsListInitial()) {
    on<LoadBookingsEvent>(_onLoadBookings);
    on<RefreshBookingsEvent>(_onRefreshBookings);
    on<CancelBookingEvent>(_onCancelBooking);
    on<UpdateBookingEvent>(_onUpdateBooking);
    on<ConfirmBookingEvent>(_onConfirmBooking);
    on<CheckInBookingEvent>(_onCheckInBooking);
    on<CheckOutBookingEvent>(_onCheckOutBooking);
    on<FilterBookingsEvent>(_onFilterBookings);
    on<SearchBookingsEvent>(_onSearchBookings);
    on<ChangePageEvent>(_onChangePage);
    on<ChangePageSizeEvent>(_onChangePageSize);
    on<SelectBookingEvent>(_onSelectBooking);
    on<DeselectBookingEvent>(_onDeselectBooking);
    on<SelectMultipleBookingsEvent>(_onSelectMultipleBookings);
    on<ClearSelectionEvent>(_onClearSelection);
  }

  /// العربية: يجلب صفحة الحجوزات المطلوبة مع الحفاظ على سياق الفلاتر والتحميل التدريجي.
  /// English: Fetches the requested booking page while preserving filters and incremental loading.
  Future<void> _onLoadBookings(
    LoadBookingsEvent event,
    Emitter<BookingsListState> emit,
  ) async {
    // لا تعرض حالة التحميل إذا كان لدينا بيانات حالية لتجنب الوميض
    final hasExistingData = state is BookingsListLoaded;
    final isLoadMoreRequest = hasExistingData && event.pageNumber > 1;
    if (!hasExistingData) {
      emit(BookingsListLoading());
    } else if (isLoadMoreRequest) {
      // حظر الطلبات المتعددة أثناء التحميل المستمر
      if (_isLoadingMore) return;
      _isLoadingMore = true;
    }

    // حفظ قيم الفلاتر
    _currentStartDate = event.startDate;
    _currentEndDate = event.endDate;
    _currentUserId = event.userId;
    _currentGuestNameOrEmail = event.guestNameOrEmail;
    _currentUnitId = event.unitId;
    _currentBookingSource = event.bookingSource;
    _currentPageNumber = event.pageNumber;
    _currentPageSize = event.pageSize;

    final result = await getBookingsByDateRangeUseCase(
      GetBookingsByDateRangeParams(
        startDate: event.startDate,
        endDate: event.endDate,
        pageNumber: event.pageNumber,
        pageSize: event.pageSize,
        userId: event.userId,
        guestNameOrEmail: event.guestNameOrEmail,
        unitId: event.unitId,
        bookingSource: event.bookingSource,
      ),
    );

    result.fold(
      (failure) {
        _isLoadingMore = false;
        if (hasExistingData) {
          // في حال الفشل ومع وجود بيانات حالية، أبقِ البيانات واظهر فشل العملية
          final current = state as BookingsListLoaded;
          emit(BookingOperationFailure(
            bookings: current.bookings,
            selectedBookings: current.selectedBookings,
            message: failure.message,
          ));
        } else {
          emit(BookingsListError(message: failure.message));
        }
      },
      (bookingsPage) {
        // دمج الاختيار الحالي إن وجد
        final selected = state is BookingsListLoaded
            ? (state as BookingsListLoaded).selectedBookings
            : const <Booking>[];

        PaginatedResult<Booking> effectivePage = bookingsPage;

        if (isLoadMoreRequest) {
          final current = state as BookingsListLoaded;
          // دمج العناصر مع إزالة التكرارات حسب المعرّف
          final List<Booking> combinedItems = <Booking>[
            ...current.bookings.items,
            ...bookingsPage.items.where(
              (nb) => !current.bookings.items.any((cb) => cb.id == nb.id),
            ),
          ];

          effectivePage = PaginatedResult<Booking>(
            items: combinedItems,
            pageNumber: bookingsPage.pageNumber,
            pageSize: bookingsPage.pageSize,
            totalCount: bookingsPage.totalCount,
            metadata: bookingsPage.metadata,
          );
        }

        emit(BookingsListLoaded(
          bookings: effectivePage,
          selectedBookings: selected
              .where((b) => effectivePage.items.any((nb) => nb.id == b.id))
              .toList(),
          filters: BookingFilters(
            startDate: event.startDate,
            endDate: event.endDate,
            userId: event.userId,
            guestNameOrEmail: event.guestNameOrEmail,
            unitId: event.unitId,
            bookingSource: event.bookingSource,
          ),
          stats: (effectivePage.metadata is Map<String, dynamic>)
              ? (effectivePage.metadata as Map<String, dynamic>)
              : null,
        ));

        _isLoadingMore = false;
      },
    );
  }

  /// العربية: يعيد تحميل القائمة باستخدام آخر معايير بحث محفوظة دون تغيير سياق الواجهة.
  /// English: Reloads the list using the last saved query while keeping the UI context intact.
  Future<void> _onRefreshBookings(
    RefreshBookingsEvent event,
    Emitter<BookingsListState> emit,
  ) async {
    // Ensure date range
    if (_currentStartDate == null || _currentEndDate == null) {
      _currentEndDate = DateTime.now();
      _currentStartDate = DateTime.now().subtract(const Duration(days: 30));
    }

    // Show overlay but keep current list
    PaginatedResult<Booking>? currentPage;
    List<Booking> currentSelection = const [];
    if (state is BookingsListLoaded) {
      currentPage = (state as BookingsListLoaded).bookings;
      currentSelection = (state as BookingsListLoaded).selectedBookings;
      emit(BookingOperationInProgress(
        bookings: currentPage,
        selectedBookings: currentSelection,
        operation: 'refresh',
      ));
    }

    final result = await getBookingsByDateRangeUseCase(
      GetBookingsByDateRangeParams(
        startDate: _currentStartDate!,
        endDate: _currentEndDate!,
        pageNumber: _currentPageNumber,
        pageSize: _currentPageSize,
        userId: _currentUserId,
        guestNameOrEmail: _currentGuestNameOrEmail,
        unitId: _currentUnitId,
        bookingSource: _currentBookingSource,
      ),
    );

    result.fold(
      (failure) {
        // Keep existing state on failure; optionally could emit a transient error
        if (currentPage != null) {
          emit(BookingOperationFailure(
            bookings: currentPage,
            selectedBookings: currentSelection,
            message: failure.message,
          ));
        } else {
          emit(BookingsListError(message: failure.message));
        }
      },
      (bookingsPage) {
        emit(BookingsListLoaded(
          bookings: bookingsPage,
          selectedBookings: currentSelection
              .where((b) => bookingsPage.items.any((nb) => nb.id == b.id))
              .toList(),
          filters: BookingFilters(
            startDate: _currentStartDate,
            endDate: _currentEndDate,
            userId: _currentUserId,
            guestNameOrEmail: _currentGuestNameOrEmail,
            unitId: _currentUnitId,
            bookingSource: _currentBookingSource,
          ),
          stats: (bookingsPage.metadata is Map<String, dynamic>)
              ? (bookingsPage.metadata as Map<String, dynamic>)
              : null,
        ));
      },
    );
  }

  /// العربية: يرسل طلب إلغاء الحجز ثم ينعكس النجاح أو الفشل على الحالة الحالية.
  /// English: Sends the booking cancel request and reflects success or failure in the current state.
  Future<void> _onCancelBooking(
    CancelBookingEvent event,
    Emitter<BookingsListState> emit,
  ) async {
    if (state is BookingsListLoaded) {
      final currentState = state as BookingsListLoaded;

      emit(BookingOperationInProgress(
        bookings: currentState.bookings,
        selectedBookings: currentState.selectedBookings,
        operation: 'cancel',
        bookingId: event.bookingId,
      ));

      final result = await cancelBookingUseCase(
        CancelBookingParams(
          bookingId: event.bookingId,
          cancellationReason: event.cancellationReason,
          refundPayments: event.refundPayments,
        ),
      );

      result.fold(
        (failure) {
          String message = failure.message;
          if (failure is ServerFailure && failure.showAsDialog) {
            message = failure.code ?? failure.message;
          }
          emit(BookingOperationFailure(
            bookings: currentState.bookings,
            selectedBookings: currentState.selectedBookings,
            message: message,
            bookingId: event.bookingId,
          ));
        },
        (_) {
          emit(BookingOperationSuccess(
            bookings: currentState.bookings,
            selectedBookings: currentState.selectedBookings,
            message: 'تم إلغاء الحجز بنجاح',
            bookingId: event.bookingId,
          ));
          // إعادة تحميل القائمة
          add(RefreshBookingsEvent());
        },
      );
    }
  }

  /// العربية: يرسل طلب تعديل الحجز ثم يعيد تحميل القائمة لتثبيت التغييرات.
  /// English: Sends the booking update request and reloads the list to reflect the changes.
  Future<void> _onUpdateBooking(
    UpdateBookingEvent event,
    Emitter<BookingsListState> emit,
  ) async {
    if (state is BookingsListLoaded) {
      final currentState = state as BookingsListLoaded;

      emit(BookingOperationInProgress(
        bookings: currentState.bookings,
        selectedBookings: currentState.selectedBookings,
        operation: 'update',
        bookingId: event.bookingId,
      ));

      final result = await updateBookingUseCase(
        UpdateBookingParams(
          bookingId: event.bookingId,
          checkIn: event.checkIn,
          checkOut: event.checkOut,
          guestsCount: event.guestsCount,
        ),
      );

      result.fold(
        (failure) => emit(BookingOperationFailure(
          bookings: currentState.bookings,
          selectedBookings: currentState.selectedBookings,
          message: failure.message,
          bookingId: event.bookingId,
        )),
        (_) {
          emit(BookingOperationSuccess(
            bookings: currentState.bookings,
            selectedBookings: currentState.selectedBookings,
            message: 'تم تحديث الحجز بنجاح',
            bookingId: event.bookingId,
          ));
          // إعادة تحميل القائمة
          add(RefreshBookingsEvent());
        },
      );
    }
  }

  /// العربية: يعتمد الحجز المحدد ثم يعيد القائمة بعد نجاح العملية.
  /// English: Confirms the selected booking and refreshes the list after success.
  Future<void> _onConfirmBooking(
    ConfirmBookingEvent event,
    Emitter<BookingsListState> emit,
  ) async {
    if (state is BookingsListLoaded) {
      final currentState = state as BookingsListLoaded;

      emit(BookingOperationInProgress(
        bookings: currentState.bookings,
        selectedBookings: currentState.selectedBookings,
        operation: 'confirm',
        bookingId: event.bookingId,
      ));

      final result = await confirmBookingUseCase(
        ConfirmBookingParams(bookingId: event.bookingId),
      );

      result.fold(
        (failure) => emit(BookingOperationFailure(
          bookings: currentState.bookings,
          selectedBookings: currentState.selectedBookings,
          message: failure.message,
          bookingId: event.bookingId,
        )),
        (_) {
          emit(BookingOperationSuccess(
            bookings: currentState.bookings,
            selectedBookings: currentState.selectedBookings,
            message: 'تم تأكيد الحجز بنجاح',
            bookingId: event.bookingId,
          ));
          // إعادة تحميل القائمة
          add(RefreshBookingsEvent());
        },
      );
    }
  }

  /// العربية: يسجل وصول الضيف للحجز المحدد مع الحفاظ على الصفحة الحالية أثناء التنفيذ.
  /// English: Checks the guest in while keeping the current page visible during execution.
  Future<void> _onCheckInBooking(
    CheckInBookingEvent event,
    Emitter<BookingsListState> emit,
  ) async {
    if (state is BookingsListLoaded) {
      final currentState = state as BookingsListLoaded;

      emit(BookingOperationInProgress(
        bookings: currentState.bookings,
        selectedBookings: currentState.selectedBookings,
        operation: 'checkIn',
        bookingId: event.bookingId,
      ));

      final result = await checkInUseCase(
        CheckInParams(bookingId: event.bookingId),
      );

      result.fold(
        (failure) => emit(BookingOperationFailure(
          bookings: currentState.bookings,
          selectedBookings: currentState.selectedBookings,
          message: failure.message,
          bookingId: event.bookingId,
        )),
        (_) {
          emit(BookingOperationSuccess(
            bookings: currentState.bookings,
            selectedBookings: currentState.selectedBookings,
            message: 'تم تسجيل الوصول بنجاح',
            bookingId: event.bookingId,
          ));
          // إعادة تحميل القائمة
          add(RefreshBookingsEvent());
        },
      );
    }
  }

  /// العربية: يسجل مغادرة الضيف ثم ينعش القائمة بعد النجاح.
  /// English: Checks the guest out and refreshes the list after success.
  Future<void> _onCheckOutBooking(
    CheckOutBookingEvent event,
    Emitter<BookingsListState> emit,
  ) async {
    if (state is BookingsListLoaded) {
      final currentState = state as BookingsListLoaded;

      emit(BookingOperationInProgress(
        bookings: currentState.bookings,
        selectedBookings: currentState.selectedBookings,
        operation: 'checkOut',
        bookingId: event.bookingId,
      ));

      final result = await checkOutUseCase(
        CheckOutParams(bookingId: event.bookingId),
      );

      result.fold(
        (failure) => emit(BookingOperationFailure(
          bookings: currentState.bookings,
          selectedBookings: currentState.selectedBookings,
          message: failure.message,
          bookingId: event.bookingId,
        )),
        (_) {
          emit(BookingOperationSuccess(
            bookings: currentState.bookings,
            selectedBookings: currentState.selectedBookings,
            message: 'تم تسجيل المغادرة بنجاح',
            bookingId: event.bookingId,
          ));
          // إعادة تحميل القائمة
          add(RefreshBookingsEvent());
        },
      );
    }
  }

  /// العربية: يحول معايير الفلترة إلى تحميل جديد يبدأ من الصفحة الأولى.
  /// English: Converts filter changes into a fresh load request that starts from page one.
  Future<void> _onFilterBookings(
    FilterBookingsEvent event,
    Emitter<BookingsListState> emit,
  ) async {
    add(LoadBookingsEvent(
      startDate: event.startDate ??
          _currentStartDate ??
          DateTime.now().subtract(const Duration(days: 30)),
      endDate: event.endDate ?? _currentEndDate ?? DateTime.now(),
      pageNumber: 1, // Reset to first page when filtering
      pageSize: _currentPageSize,
      userId: event.userId,
      guestNameOrEmail: event.guestNameOrEmail,
      unitId: event.unitId,
      bookingSource: event.bookingSource,
    ));
  }

  /// العربية: يربط البحث النصي بتحميل جديد يبدأ من الصفحة الأولى حتى تظهر النتائج الصحيحة.
  /// English: Turns text search into a fresh load request starting from the first page.
  Future<void> _onSearchBookings(
    SearchBookingsEvent event,
    Emitter<BookingsListState> emit,
  ) async {
    add(LoadBookingsEvent(
      startDate: _currentStartDate ??
          DateTime.now().subtract(const Duration(days: 30)),
      endDate: _currentEndDate ?? DateTime.now(),
      pageNumber: 1, // Reset to first page when searching
      pageSize: _currentPageSize,
      userId: _currentUserId,
      guestNameOrEmail: event.searchTerm,
      unitId: _currentUnitId,
      bookingSource: _currentBookingSource,
    ));
  }

  /// العربية: ينتقل إلى الصفحة المطلوبة فقط إذا كانت مختلفة عن الصفحة الحالية.
  /// English: Moves to the requested page only when it differs from the current page.
  Future<void> _onChangePage(
    ChangePageEvent event,
    Emitter<BookingsListState> emit,
  ) async {
    // إذا كنا بالفعل في الصفحة المطلوبة، تجاهل لتجنب إعادة التحميل غير الضرورية
    if (state is BookingsListLoaded) {
      final current = state as BookingsListLoaded;
      if (current.bookings.pageNumber == event.pageNumber) {
        return;
      }
    }

    add(LoadBookingsEvent(
      startDate: _currentStartDate ??
          DateTime.now().subtract(const Duration(days: 30)),
      endDate: _currentEndDate ?? DateTime.now(),
      pageNumber: event.pageNumber,
      pageSize: _currentPageSize,
      userId: _currentUserId,
      guestNameOrEmail: _currentGuestNameOrEmail,
      unitId: _currentUnitId,
      bookingSource: _currentBookingSource,
    ));
  }

  /// العربية: يغيّر حجم الصفحة ثم يعيد التحميل من الصفحة الأولى للمحافظة على اتساق الترقيم.
  /// English: Changes the page size and reloads from the first page to keep pagination consistent.
  Future<void> _onChangePageSize(
    ChangePageSizeEvent event,
    Emitter<BookingsListState> emit,
  ) async {
    if (event.pageSize == _currentPageSize) {
      return;
    }

    add(LoadBookingsEvent(
      startDate: _currentStartDate ??
          DateTime.now().subtract(const Duration(days: 30)),
      endDate: _currentEndDate ?? DateTime.now(),
      pageNumber: 1, // Reset to first page when changing page size
      pageSize: event.pageSize,
      userId: _currentUserId,
      guestNameOrEmail: _currentGuestNameOrEmail,
      unitId: _currentUnitId,
      bookingSource: _currentBookingSource,
    ));
  }

  /// العربية: يضيف حجزًا واحدًا إلى مجموعة الاختيار إذا لم يكن موجودًا بالفعل.
  /// English: Adds one booking to the selection set if it is not already included.
  Future<void> _onSelectBooking(
    SelectBookingEvent event,
    Emitter<BookingsListState> emit,
  ) async {
    if (state is BookingsListLoaded) {
      final currentState = state as BookingsListLoaded;
      final updatedSelection =
          List<Booking>.from(currentState.selectedBookings);

      final booking = currentState.bookings.items.firstWhere(
        (b) => b.id == event.bookingId,
      );

      if (!updatedSelection.contains(booking)) {
        updatedSelection.add(booking);
      }

      emit(currentState.copyWith(selectedBookings: updatedSelection));
    }
  }

  /// العربية: يزيل الحجز المطلوب من مجموعة الاختيار الحالية فقط.
  /// English: Removes the requested booking from the current selection only.
  Future<void> _onDeselectBooking(
    DeselectBookingEvent event,
    Emitter<BookingsListState> emit,
  ) async {
    if (state is BookingsListLoaded) {
      final currentState = state as BookingsListLoaded;
      final updatedSelection = List<Booking>.from(currentState.selectedBookings)
        ..removeWhere((b) => b.id == event.bookingId);

      emit(currentState.copyWith(selectedBookings: updatedSelection));
    }
  }

  /// العربية: يستبدل الاختيار الحالي بالحجوزات المطابقة للمعرّفات المرسلة.
  /// English: Replaces the current selection with bookings matching the supplied ids.
  Future<void> _onSelectMultipleBookings(
    SelectMultipleBookingsEvent event,
    Emitter<BookingsListState> emit,
  ) async {
    if (state is BookingsListLoaded) {
      final currentState = state as BookingsListLoaded;
      final bookings = currentState.bookings.items
          .where((b) => event.bookingIds.contains(b.id))
          .toList();

      emit(currentState.copyWith(selectedBookings: bookings));
    }
  }

  /// العربية: يمسح جميع الحجوزات المحددة ويعيد الحالة إلى وضع غير محدد.
  /// English: Clears every selected booking and returns the state to an unselected mode.
  Future<void> _onClearSelection(
    ClearSelectionEvent event,
    Emitter<BookingsListState> emit,
  ) async {
    if (state is BookingsListLoaded) {
      final currentState = state as BookingsListLoaded;
      emit(currentState.copyWith(selectedBookings: []));
    }
  }
}
