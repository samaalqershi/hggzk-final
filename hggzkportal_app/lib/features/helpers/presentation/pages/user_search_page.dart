import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../admin_users/domain/entities/user.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/usecases/search_users_usecase.dart';
import 'package:hggzkportal/injection_container.dart' as di;
import '../widgets/search_header.dart';
import '../widgets/search_item_card.dart';
import '../widgets/simple_filter_bar.dart';

/// يعرّف الكلاس `UserSearchPage`.
/// Describes the `UserSearchPage` class.
class UserSearchPage extends StatefulWidget {
  /// Holds the `initialSearchTerm` value.
  /// العربية: يخزن القيمة `initialSearchTerm`.
  final String? initialSearchTerm;

  /// يخزن العضو `allowMultiSelect`.
  /// Holds the `allowMultiSelect` member.
  final bool allowMultiSelect;

  /// ينفذ العملية `Function`.
  /// Runs the `Function` operation.
  final Function(List<User>)? onUsersSelected;

  /// ينفذ العملية `Function`.
  /// Runs the `Function` operation.
  final Function(User)? onUserSelected;

  /// ينشئ مثيلاً من `UserSearchPage`.
  /// Builds an instance of `UserSearchPage`.
  const UserSearchPage({
    super.key,
    this.initialSearchTerm,
    this.allowMultiSelect = false,
    this.onUsersSelected,
    this.onUserSelected,
  });

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

/// يعرّف الكلاس `_UserSearchPageState`.
/// Describes the `_UserSearchPageState` class.
class _UserSearchPageState extends State<UserSearchPage> {
  final SearchUsersUseCase _searchUsersUseCase = di.sl<SearchUsersUseCase>();

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// يخزن العضو `_users`.
  /// Holds the `_users` member.
  List<SearchResult> _users = [];

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

  /// يخزن العضو `_selectedRole`.
  /// Holds the `_selectedRole` member.
  String? _selectedRole;

  /// يخزن العضو `_isActiveFilter`.
  /// Holds the `_isActiveFilter` member.
  bool? _isActiveFilter;

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
    _loadUsers();
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
        _loadMoreUsers();
      }
    }
  }

  /// ينفذ العملية `_loadUsers`.
  /// Runs the `_loadUsers` operation.
  Future<void> _loadUsers({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _users.clear();
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final result = await _searchUsersUseCase(
      searchTerm:
          _searchController.text.isEmpty ? null : _searchController.text,
      role: _selectedRole,
      isActive: _isActiveFilter,
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
          _users = paginatedResult.items;
          _totalPages = paginatedResult.totalPages;
          _isLoading = false;
        });
      },
    );
  }

  /// ينفذ العملية `_loadMoreUsers`.
  /// Runs the `_loadMoreUsers` operation.
  Future<void> _loadMoreUsers() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;

    final result = await _searchUsersUseCase(
      searchTerm:
          _searchController.text.isEmpty ? null : _searchController.text,
      role: _selectedRole,
      isActive: _isActiveFilter,
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
          _users.addAll(paginatedResult.items);
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
    final selectedUsers = _users
        .where((result) => _selectedIds.contains(result.id))
        .map((result) => result.item as User)
        .toList();

    if (widget.allowMultiSelect && widget.onUsersSelected != null) {
      widget.onUsersSelected!(selectedUsers);
    } else if (!widget.allowMultiSelect &&
        widget.onUserSelected != null &&
        selectedUsers.isNotEmpty) {
      widget.onUserSelected!(selectedUsers.first);
    }

    Navigator.of(context).pop();
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
              title:
                  widget.allowMultiSelect ? 'اختر المستخدمين' : 'اختر مستخدم',
              searchHint: 'ابحث بالاسم أو البريد الإلكتروني...',
              searchController: _searchController,
              onSearchChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (value == _searchController.text) {
                    _loadUsers(isRefresh: true);
                  }
                });
              },
              onClearSearch: () {
                _loadUsers(isRefresh: true);
              },
            ),

            // Filters
            SimpleFilterBar(
              filters: [
                FilterOption(
                  label: 'الكل',
                  isSelected: _selectedRole == null,
                  onChanged: (selected) {
                    if (selected) {
                      setState(() => _selectedRole = null);
                      _loadUsers(isRefresh: true);
                    }
                  },
                ),
                FilterOption(
                  label: 'مدير',
                  isSelected: _selectedRole == 'admin',
                  onChanged: (selected) {
                    setState(() => _selectedRole = selected ? 'admin' : null);
                    _loadUsers(isRefresh: true);
                  },
                ),
                FilterOption(
                  label: 'عميل',
                  isSelected: _selectedRole == 'customer',
                  onChanged: (selected) {
                    setState(
                        () => _selectedRole = selected ? 'customer' : null);
                    _loadUsers(isRefresh: true);
                  },
                ),
                FilterOption(
                  label: 'نشط',
                  isSelected: _isActiveFilter == true,
                  onChanged: (selected) {
                    setState(() => _isActiveFilter = selected ? true : null);
                    _loadUsers(isRefresh: true);
                  },
                ),
              ],
              onClearFilters: () {
                setState(() {
                  _selectedRole = null;
                  _isActiveFilter = null;
                });
                _loadUsers(isRefresh: true);
              },
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
                        'تم اختيار ${_selectedIds.length} ${_selectedIds.length == 1 ? 'مستخدم' : 'مستخدمين'}',
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
                      child: Text(
                        'تأكيد',
                        style: TextStyle(color: AppTheme.textWhite),
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

  /// ينفذ العملية `_buildContent`.
  /// Runs the `_buildContent` operation.
  Widget _buildContent() {
    if (_isLoading && _users.isEmpty) {
      return const LoadingWidget(
        message: 'جاري البحث عن المستخدمين...',
      );
    }

    if (_hasError) {
      return CustomErrorWidget(
        message: _errorMessage,
        onRetry: () => _loadUsers(isRefresh: true),
      );
    }

    if (_users.isEmpty) {
      return const EmptyWidget(
        message: 'لا توجد نتائج',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadUsers(isRefresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _users.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _users.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final user = _users[index];
          return SearchItemCard(
            item: user,
            isSelected: _selectedIds.contains(user.id),
            onTap: () => _toggleSelection(user.id),
          );
        },
      ),
    );
  }
}
