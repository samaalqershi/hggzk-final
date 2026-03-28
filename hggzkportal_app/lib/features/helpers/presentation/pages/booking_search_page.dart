import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/usecases/search_bookings_usecase.dart';
import 'package:hggzkportal/injection_container.dart' as di;
import '../widgets/search_header.dart';
import '../widgets/search_item_card.dart';

/// يعرّف الكلاس `BookingSearchPage`.
/// Describes the `BookingSearchPage` class.
class BookingSearchPage extends StatefulWidget {
  /// Holds the `initialSearchTerm` value.
  /// العربية: يخزن القيمة `initialSearchTerm`.
  final String? initialSearchTerm;

  /// يخزن العضو `userId`.
  /// Holds the `userId` member.
  final String? userId;

  /// يخزن العضو `unitId`.
  /// Holds the `unitId` member.
  final String? unitId;

  /// يخزن العضو `allowMultiSelect`.
  /// Holds the `allowMultiSelect` member.
  final bool allowMultiSelect;

  /// ينفذ العملية `Function`.
  /// Runs the `Function` operation.
  final Function(List<Map<String, dynamic>>)? onBookingsSelected;

  /// ينفذ العملية `Function`.
  /// Runs the `Function` operation.
  final Function(Map<String, dynamic>)? onBookingSelected;

  /// ينشئ مثيلاً من `BookingSearchPage`.
  /// Builds an instance of `BookingSearchPage`.
  const BookingSearchPage({
    super.key,
    this.initialSearchTerm,
    this.userId,
    this.unitId,
    this.allowMultiSelect = false,
    this.onBookingsSelected,
    this.onBookingSelected,
  });

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<BookingSearchPage> createState() => _BookingSearchPageState();
}

/// يعرّف الكلاس `_BookingSearchPageState`.
/// Describes the `_BookingSearchPageState` class.
class _BookingSearchPageState extends State<BookingSearchPage> {
  final SearchBookingsUseCase _searchBookingsUseCase =
      di.sl<SearchBookingsUseCase>();

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// يخزن العضو `_bookings`.
  /// Holds the `_bookings` member.
  List<SearchResult> _bookings = [];

  /// يخزن العضو `_selectedIds`.
  /// Holds the `_selectedIds` member.
  List<String> _selectedIds = [];

  /// يخزن العضو `_isLoading`.
  /// Holds the `_isLoading` member.
  bool _isLoading = false;

  /// يخزن العضو `_hasError`.
  /// Holds the `_hasError` member.
  bool _hasError = false;

  /// يخزن العضو `_errorMessage`.
  /// Holds the `_errorMessage` member.
  String? _errorMessage;

  /// يخزن العضو `_statusFilter`.
  /// Holds the `_statusFilter` member.
  String? _statusFilter;

  /// يخزن العضو `_startDate`.
  /// Holds the `_startDate` member.
  DateTime? _startDate;

  /// يخزن العضو `_endDate`.
  /// Holds the `_endDate` member.
  DateTime? _endDate;

  /// يخزن العضو `_currentPage`.
  /// Holds the `_currentPage` member.
  int _currentPage = 1;

  /// يخزن العضو `_totalPages`.
  /// Holds the `_totalPages` member.
  int _totalPages = 1;

  /// يخزن العضو `_isLoadingMore`.
  /// Holds the `_isLoadingMore` member.
  bool _isLoadingMore = false;

  /// ينفذ العملية `initState`.
  /// Runs the `initState` operation.
  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialSearchTerm ?? '';
    _scrollController.addListener(_onScroll);
    _loadBookings();
  }

  /// ينفذ العملية `dispose`.
  /// Runs the `dispose` operation.
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// ينفذ العملية `_onScroll`.
  /// Runs the `_onScroll` operation.
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _currentPage < _totalPages) {
        _loadMoreBookings();
      }
    }
  }

  /// ينفذ العملية `_loadBookings`.
  /// Runs the `_loadBookings` operation.
  Future<void> _loadBookings({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _bookings.clear();
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final result = await _searchBookingsUseCase(
      searchTerm:
          _searchController.text.isEmpty ? null : _searchController.text,
      userId: widget.userId,
      unitId: widget.unitId,
      status: _statusFilter,
      startDate: _startDate,
      endDate: _endDate,
      pageNumber: _currentPage,
      pageSize: 20,
    );

    result.fold(
      (failure) {
        setState(() {
          _hasError = true;
          _errorMessage = failure.message;
          _isLoading = false;
        });
      },
      (paginatedResult) {
        setState(() {
          _bookings = paginatedResult.items;
          _totalPages = paginatedResult.totalPages;
          _isLoading = false;
        });
      },
    );
  }

  /// ينفذ العملية `_loadMoreBookings`.
  /// Runs the `_loadMoreBookings` operation.
  Future<void> _loadMoreBookings() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;

    final result = await _searchBookingsUseCase(
      searchTerm:
          _searchController.text.isEmpty ? null : _searchController.text,
      userId: widget.userId,
      unitId: widget.unitId,
      status: _statusFilter,
      startDate: _startDate,
      endDate: _endDate,
      pageNumber: _currentPage,
      pageSize: 20,
    );

    result.fold(
      (failure) {
        _currentPage--;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (paginatedResult) {
        setState(() {
          _bookings.addAll(paginatedResult.items);
        });
      },
    );

    setState(() {
      _isLoadingMore = false;
    });
  }

  /// ينفذ العملية `_toggleSelection`.
  /// Runs the `_toggleSelection` operation.
  void _toggleSelection(String id) {
    setState(() {
      if (widget.allowMultiSelect) {
        if (_selectedIds.contains(id)) {
          _selectedIds.remove(id);
        } else {
          _selectedIds.add(id);
        }
      } else {
        _selectedIds = [id];
      }
    });
  }

  /// ينفذ العملية `_confirmSelection`.
  /// Runs the `_confirmSelection` operation.
  void _confirmSelection() {
    final selectedBookings = _bookings
        .where((result) => _selectedIds.contains(result.id))
        .map((result) => result.item as Map<String, dynamic>)
        .toList();

    if (widget.allowMultiSelect && widget.onBookingsSelected != null) {
      widget.onBookingsSelected!(selectedBookings);
    } else if (!widget.allowMultiSelect &&
        widget.onBookingSelected != null &&
        selectedBookings.isNotEmpty) {
      widget.onBookingSelected!(selectedBookings.first);
    }

    Navigator.of(context).pop();
  }

  /// ينفذ العملية `_selectDateRange`.
  /// Runs the `_selectDateRange` operation.
  Future<void> _selectDateRange() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryBlue,
              surface: AppTheme.darkCard,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() {
        _startDate = result.start;
        _endDate = result.end;
      });
      _loadBookings(isRefresh: true);
    }
  }

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Search
            SearchHeader(
              title: widget.allowMultiSelect ? 'اختر الحجوزات' : 'اختر حجز',
              searchHint: 'ابحث باسم الضيف أو البريد الإلكتروني...',
              searchController: _searchController,
              onSearchChanged: (value) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (value == _searchController.text) {
                    _loadBookings(isRefresh: true);
                  }
                });
              },
              onClearSearch: () {
                _loadBookings(isRefresh: true);
              },
            ),

            // Date Range Selector
            if (_startDate != null || _endDate != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.date_range_rounded,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _startDate != null && _endDate != null
                            ? '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}'
                            : 'اختر نطاق التواريخ',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.textWhite,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: AppTheme.textMuted,
                        size: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                        });
                        _loadBookings(isRefresh: true);
                      },
                    ),
                  ],
                ),
              ),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Date Range Button
                  GestureDetector(
                    onTap: _selectDateRange,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: (_startDate != null || _endDate != null)
                            ? AppTheme.primaryBlue.withValues(alpha: 0.2)
                            : AppTheme.darkSurface.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (_startDate != null || _endDate != null)
                              ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                              : AppTheme.darkBorder.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: (_startDate != null || _endDate != null)
                                ? AppTheme.primaryBlue
                                : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'التاريخ',
                            style: AppTextStyles.caption.copyWith(
                              color: (_startDate != null || _endDate != null)
                                  ? AppTheme.primaryBlue
                                  : AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status Filters
                  ..._buildStatusFilters(),
                ],
              ),
            ),

            // Results
            Expanded(
              child: _buildContent(),
            ),

            // Action Buttons
            if (_selectedIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withValues(alpha: 0.5),
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.darkBorder.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'تم اختيار ${_selectedIds.length} ${_selectedIds.length == 1 ? 'حجز' : 'حجوزات'}',
                        style: TextStyle(color: AppTheme.textWhite),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selectedIds.clear()),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                      ),
                      child: const Text('تأكيد'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// ينفذ العملية `_buildStatusFilters`.
  /// Runs the `_buildStatusFilters` operation.
  List<Widget> _buildStatusFilters() {
    final statuses = [
      {'value': null, 'label': 'الكل'},
      {'value': 'Pending', 'label': 'معلق'},
      {'value': 'Confirmed', 'label': 'مؤكد'},
      {'value': 'Cancelled', 'label': 'ملغي'},
      {'value': 'Completed', 'label': 'مكتمل'},
    ];

    return statuses.map((status) {
      final isSelected = _statusFilter == status['value'];
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(status['label'] as String),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _statusFilter = selected ? status['value'] as String : null;
            });
            _loadBookings(isRefresh: true);
          },
          backgroundColor: AppTheme.darkSurface.withValues(alpha: 0.3),
          selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
          labelStyle: AppTextStyles.caption.copyWith(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.textMuted,
          ),
          side: BorderSide(
            color: isSelected
                ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                : AppTheme.darkBorder.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      );
    }).toList();
  }

  /// ينفذ العملية `_buildContent`.
  /// Runs the `_buildContent` operation.
  Widget _buildContent() {
    if (_isLoading && _bookings.isEmpty) {
      return const LoadingWidget(
        message: 'جاري البحث عن الحجوزات...',
      );
    }

    if (_hasError) {
      return CustomErrorWidget(
        message: _errorMessage,
        onRetry: () => _loadBookings(isRefresh: true),
      );
    }

    if (_bookings.isEmpty) {
      return const EmptyWidget(
        message: 'لا توجد نتائج',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadBookings(isRefresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _bookings.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _bookings.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final booking = _bookings[index];
          return SearchItemCard(
            item: booking,
            isSelected: _selectedIds.contains(booking.id),
            onTap: () => _toggleSelection(booking.id),
          );
        },
      ),
    );
  }

  /// ينفذ العملية `_formatDate`.
  /// Runs the `_formatDate` operation.
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
