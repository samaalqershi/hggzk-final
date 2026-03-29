import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hggzk/features/chat/presentation/pages/chat_page.dart';
import 'package:hggzk/features/chat/presentation/widgets/pinned_admins_widget.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import '../../domain/entities/conversation.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/participant_item_widget.dart';

/// العربية: يمثل عنصر الصفحة `NewConversationPage`.
class NewConversationPage extends StatefulWidget {
  /// العربية: ينشئ مثيلًا جديدًا من `NewConversationPage`.
  const NewConversationPage({super.key});

  /// العربية: ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<NewConversationPage> createState() => _NewConversationPageState();
}

/// العربية: يمثل الحالة الخاصة بـ `NewConversationPageState`.
class _NewConversationPageState extends State<NewConversationPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();

  /// العربية: يخزن القيمة `selectedUsers`.
  final Set<ChatUser> _selectedUsers = {};

  /// العربية: يحدد ما إذا كانت القيمة `isCreatingGroup` مفعلة.
  bool _isCreatingGroup = false;

  /// العربية: يخزن القيمة `availableUsers`.
  List<ChatUser> _availableUsers = [];

  /// العربية: يخزن القيمة `filteredUsers`.
  List<ChatUser> _filteredUsers = [];

  // Animation Controllers
  /// العربية: يخزن القيمة `fadeController`.
  late AnimationController _fadeController;

  /// العربية: يخزن القيمة `slideController`.
  late AnimationController _slideController;

  /// العربية: يخزن القيمة `pulseController`.
  late AnimationController _pulseController;

  /// العربية: يخزن القيمة `fadeAnimation`.
  late Animation<double> _fadeAnimation;

  /// العربية: يخزن القيمة `slideAnimation`.
  late Animation<Offset> _slideAnimation;

  /// العربية: يخزن القيمة `pulseAnimation`.
  late Animation<double> _pulseAnimation;

  /// العربية: يهيئ الحالة الخاصة بهذا العنصر.
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAvailableUsers();
    _searchController.addListener(_filterUsers);
  }

  /// العربية: يهيئ animations.
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  /// العربية: يحرر الموارد المستخدمة بواسطة هذا الكائن.
  @override
  void dispose() {
    _searchController.dispose();
    _groupNameController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// العربية: يحمل available users.
  void _loadAvailableUsers() {
    final bloc = context.read<ChatBloc>();
    bloc.add(const LoadAdminUsersEvent());
    bloc.add(const LoadAvailableUsersEvent());
  }

  /// العربية: يعالج `filterUsers`.
  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _availableUsers;
      } else {
        _filteredUsers = _availableUsers
            .where((user) => user.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ConversationCreated) {
          // نجح إنشاء المحادثة
          HapticFeedback.mediumImpact();

          // إغلاق أي dialog مفتوح
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

          // الانتقال للمحادثة الجديدة
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ChatPage(conversation: state.conversation),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutQuart,
                    )),
                    child: child,
                  ),
                );
              },
            ),
          );
        } else if (state is ConversationCreating) {
          // إظهار loading dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black54,
            builder: (dialogContext) => _buildCreatingDialog(),
          );
        } else if (state is ChatError && state.message.isNotEmpty) {
          // إغلاق أي dialog مفتوح
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

          // إظهار رسالة الخطأ
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.message,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (state is ChatLoaded) {
          // إغلاق dialog التحميل عند الرجوع للحالة العادية
          // التحقق من وجود dialog مفتوح
          final route = ModalRoute.of(context);
          if (route != null &&
              !route.isCurrent &&
              Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Stack(
          children: [
            // Premium gradient background
            _buildPremiumBackground(),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  _buildPremiumAppBar(),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _isCreatingGroup
                            ? _buildGroupCreationView()
                            : _buildUserSelectionView(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: _buildPremiumFAB(),
      ),
    );
  }

// أضف دالة بناء dialog التحميل الاحترافي
  /// العربية: يبني creating dialog.
  Widget _buildCreatingDialog() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.darkCard.withOpacity(0.9),
                          AppTheme.darkCard.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.2),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Custom loading animation
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer ring
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(seconds: 2),
                                builder: (context, value, child) {
                                  return CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.primaryBlue.withOpacity(0.3),
                                    ),
                                  );
                                },
                              ),
                              // Inner animated ring
                              CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryBlue,
                                ),
                              ),
                              // Center icon
                              Icon(
                                Icons.chat_bubble_rounded,
                                color: AppTheme.primaryBlue,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              AppTheme.primaryBlue,
                              AppTheme.primaryPurple
                            ],
                          ).createShader(bounds),
                          child: Text(
                            _isCreatingGroup
                                ? context.tr(
                                    'chat.newConversation.creatingGroup',
                                  )
                                : context.tr(
                                    'chat.newConversation.startingDirect',
                                  ),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.tr(
                            'chat.newConversation.pleaseWait',
                          ),
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.textMuted.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

// تحديث دالة _startDirectChat - إزالة Navigator.pop
  /// العربية: يبدأ direct chat.
  void _startDirectChat(ChatUser user) {
    HapticFeedback.lightImpact();

    // فقط أرسل الحدث، BlocListener سيتولى التنقل
    context.read<ChatBloc>().add(
          CreateConversationEvent(
            participantIds: [user.id],
            conversationType: 'direct',
          ),
        );
    // لا Navigator.pop هنا!
  }

// أضف validation محسّن
  /// العربية: يتحقق من صحة group creation.
  bool _validateGroupCreation() {
    if (_groupNameController.text.trim().isEmpty) {
      _showValidationError(
        context.tr(
          'chat.newConversation.groupNameRequired',
        ),
      );
      return false;
    }

    if (_groupNameController.text.trim().length < 3) {
      _showValidationError(
        context.tr(
          'chat.newConversation.groupNameMin',
        ),
      );
      return false;
    }

    if (_selectedUsers.length < 2) {
      _showValidationError(
        context.tr(
          'chat.newConversation.groupMembersMin',
        ),
      );
      return false;
    }

    if (_selectedUsers.length > 100) {
      _showValidationError(
        context.tr(
          'chat.newConversation.groupMembersMax',
        ),
      );
      return false;
    }

    return true;
  }

  /// العربية: يعرض validation error.
  void _showValidationError(String message) {
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.warning,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: context.tr('common.ok'),
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// العربية: ينشئ group.
  void _createGroup() {
    if (!_validateGroupCreation()) {
      return;
    }

    HapticFeedback.lightImpact();

    // تنظيف اسم المجموعة
    final cleanGroupName = _groupNameController.text.trim();

    context.read<ChatBloc>().add(
          CreateConversationEvent(
            participantIds: _selectedUsers.map((u) => u.id).toList(),
            conversationType: 'group',
            title: cleanGroupName,
            description: context.tr(
              'chat.newConversation.groupDescription',
              params: {'count': _selectedUsers.length},
            ),
          ),
        );
  }

  /// العربية: يبني premium background.
  Widget _buildPremiumBackground() {
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
        painter: _SubtlePatternPainter(),
        size: Size.infinite,
      ),
    );
  }

  /// العربية: يبني premium app bar.
  Widget _buildPremiumAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withOpacity(0.9),
                AppTheme.darkCard.withOpacity(0.85),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: AppTheme.darkBorder.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              // Back button
              _buildAppBarButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  if (_isCreatingGroup && _selectedUsers.isNotEmpty) {
                    setState(() {
                      _isCreatingGroup = false;
                    });
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),

              const SizedBox(width: 12),

              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isCreatingGroup
                          ? context.tr(
                              'chat.newConversation.createGroupTitle',
                            )
                          : context.tr(
                              'chat.newConversation.newConversationTitle',
                            ),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (_selectedUsers.isNotEmpty && !_isCreatingGroup)
                      Text(
                        context.tr(
                          'chat.newConversation.selectedCount',
                          params: {'count': _selectedUsers.length},
                        ),
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.primaryBlue.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),

              // Next button for group creation
              if (_selectedUsers.length > 1 && !_isCreatingGroup)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isCreatingGroup = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      context.tr('chat.newConversation.next'),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

  /// العربية: يبني app bar button.
  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkSurface.withOpacity(0.5),
              AppTheme.darkSurface.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          color: AppTheme.textWhite.withOpacity(0.8),
          size: 18,
        ),
      ),
    );
  }

  /// العربية: يبني user selection view.
  Widget _buildUserSelectionView() {
    return Column(
      children: [
        _buildPremiumSearchBar(),

        // إضافة widget الأدمن المثبتين
        BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatLoaded && state.adminUsers.isNotEmpty) {
              return PinnedAdminsWidget(
                adminUsers: state.adminUsers,
                selectedUsers: _selectedUsers,
                onUserTap: (admin) {
                  HapticFeedback.selectionClick();

                  setState(() {
                    if (_selectedUsers.contains(admin)) {
                      _selectedUsers.remove(admin);
                    } else {
                      _selectedUsers.add(admin);
                    }
                  });

                  // إذا تم اختيار مستخدم واحد فقط، ابدأ محادثة مباشرة
                  if (_selectedUsers.length == 1) {
                    // لا تستخدم Navigator.pop هنا!
                    context.read<ChatBloc>().add(
                          CreateConversationEvent(
                            participantIds: [_selectedUsers.first.id],
                            conversationType: 'direct',
                          ),
                        );
                    // BlocListener سيتولى التنقل
                  }
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),

        if (_selectedUsers.isNotEmpty) _buildSelectedUsersChips(),

        Expanded(
          child: BlocConsumer<ChatBloc, ChatState>(
            listenWhen: (prev, curr) => curr is ChatLoaded,
            listener: (context, state) {
              if (state is ChatLoaded) {
                setState(() {
                  _availableUsers = state.availableUsers
                      .where((user) => !state.adminUsers.contains(user))
                      .toList(); // استثناء الأدمن من القائمة العادية
                  _filterUsers();
                });
              }
            },
            builder: (context, state) {
              if (state is ChatLoading) {
                return _buildPremiumLoadingState();
              }

              if (_filteredUsers.isEmpty) {
                return _buildPremiumEmptyState();
              }

              return _buildRegularUsersList();
            },
          ),
        ),
      ],
    );
  }

  /// العربية: يبني regular users list.
  Widget _buildRegularUsersList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _buildUserListTile(user, listIndex: index);
      },
    );
  }

  /// العربية: يبني group creation view.
  Widget _buildGroupCreationView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Group info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkCard.withOpacity(0.6),
                  AppTheme.darkCard.withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.darkBorder.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                // Group avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.group_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 16),

                // Group name input
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.darkSurface.withOpacity(0.5),
                        AppTheme.darkSurface.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: TextField(
                    controller: _groupNameController,
                    autofocus: true,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: context.tr(
                        'chat.newConversation.groupNameHint',
                      ),
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textMuted.withOpacity(0.4),
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.edit_rounded,
                        color: AppTheme.primaryBlue.withOpacity(0.6),
                        size: 18,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Members section
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.darkCard.withOpacity(0.3),
                    AppTheme.darkCard.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.darkBorder.withOpacity(0.05),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(
                      'chat.newConversation.membersCount',
                      params: {'count': _selectedUsers.length},
                    ),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textMuted.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _selectedUsers.length,
                      itemBuilder: (context, index) {
                        final user = _selectedUsers.elementAt(index);
                        return ParticipantItemWidget(
                          participant: user,
                          onRemove: () {
                            setState(() {
                              _selectedUsers.remove(user);
                              if (_selectedUsers.length < 2) {
                                _isCreatingGroup = false;
                              }
                            });
                          },
                        );
                      },
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

  /// العربية: يبني premium search bar.
  Widget _buildPremiumSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkSurface.withOpacity(0.6),
              AppTheme.darkSurface.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: TextField(
          controller: _searchController,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 13,
          ),
          decoration: InputDecoration(
            hintText: context.tr(
              'chat.newConversation.searchHint',
            ),
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textMuted.withOpacity(0.4),
              fontSize: 13,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppTheme.textMuted.withOpacity(0.5),
              size: 18,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ),
    );
  }

  /// العربية: يبني selected users chips.
  Widget _buildSelectedUsersChips() {
    return Container(
      height: 90, // زيادة الارتفاع من 80 إلى 90 لحل مشكلة overflow
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _selectedUsers.length,
        itemBuilder: (context, index) {
          final user = _selectedUsers.elementAt(index);
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 64, // زيادة العرض قليلاً
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // مهم جداً
                    children: [
                      Stack(
                        clipBehavior: Clip.none, // السماح بالعناصر خارج الحدود
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryBlue.withOpacity(0.1),
                                  AppTheme.primaryPurple.withOpacity(0.05),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primaryBlue.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _getInitials(user.name),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -2,
                            right: -2,
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedUsers.remove(user);
                                });
                              },
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.error.withOpacity(0.8),
                                      AppTheme.error.withOpacity(0.6),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.darkCard,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        // استخدام Flexible بدلاً من SizedBox ثابت
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            user.name.split(' ').first,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// العربية: يبني user list tile.
  Widget _buildUserListTile(ChatUser user, {required int listIndex}) {
    final isSelected = _selectedUsers.contains(user);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (listIndex * 30)),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          AppTheme.primaryBlue.withOpacity(0.08),
                          AppTheme.primaryPurple.withOpacity(0.04),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        width: 0.5,
                      )
                    : null,
              ),
              child: ListTile(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (isSelected) {
                      _selectedUsers.remove(user);
                    } else {
                      _selectedUsers.add(user);
                    }
                  });

                  if (_selectedUsers.length == 1) {
                    _startDirectChat(_selectedUsers.first);
                  }
                },
                leading: _buildUserAvatar(user, isSelected),
                title: Text(
                  user.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                subtitle: _buildUserSubtitle(user),
                trailing: AnimatedScale(
                  scale: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// العربية: يبني user avatar.
  Widget _buildUserAvatar(ChatUser user, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
              )
            : LinearGradient(
                colors: [
                  AppTheme.darkCard.withOpacity(0.6),
                  AppTheme.darkCard.withOpacity(0.4),
                ],
              ),
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : AppTheme.darkBorder.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          _getInitials(user.name),
          style: AppTextStyles.bodySmall.copyWith(
            color:
                isSelected ? Colors.white : AppTheme.textWhite.withOpacity(0.8),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// العربية: يبني user subtitle.
  Widget? _buildUserSubtitle(ChatUser user) {
    if (user.isOnline) {
      return Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.success, AppTheme.neonGreen],
              ),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            context.tr(
              'chat.newConversation.onlineNow',
            ),
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.success.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        ],
      );
    }
    if (user.lastSeen != null) {
      return Text(
        context.tr(
          'chat.newConversation.lastSeen',
          params: {'value': _formatLastSeen(user.lastSeen!)},
        ),
        style: AppTextStyles.caption.copyWith(
          color: AppTheme.textMuted.withOpacity(0.5),
          fontSize: 11,
        ),
      );
    }
    return null;
  }

  /// العربية: يبني premium loading state.
  Widget _buildPremiumLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryBlue.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr(
              'chat.newConversation.loadingContacts',
            ),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textMuted.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// العربية: يبني premium empty state.
  Widget _buildPremiumEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.5),
              AppTheme.darkCard.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.1),
                    AppTheme.primaryPurple.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_search_rounded,
                size: 32,
                color: AppTheme.primaryBlue.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr(
                'chat.newConversation.noContactsTitle',
              ),
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(
                'chat.newConversation.noContactsSubtitle',
              ),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// العربية: يبني premium fab.
  Widget? _buildPremiumFAB() {
    if (!_isCreatingGroup || _groupNameController.text.isEmpty) {
      return null;
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: _createGroup,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// العربية: ينسق last seen.
  String _formatLastSeen(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) {
      return context.tr('chat.thread.now');
    }
    if (diff.inMinutes < 60) {
      return context.tr(
        'chat.thread.minuteAgo',
        params: {'value': diff.inMinutes},
      );
    }
    if (diff.inHours < 24) {
      return context.tr(
        'chat.thread.hourAgo',
        params: {'value': diff.inHours},
      );
    }
    return context.tr(
      'chat.thread.dayAgo',
      params: {'value': diff.inDays},
    );
  }

  /// العربية: يعيد initials.
  String _getInitials(String name) {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    String firstLetter(String value) {
      if (value.isEmpty) return '';
      return String.fromCharCodes(value.runes.take(1));
    }

    if (parts.length == 1) return firstLetter(parts.first).toUpperCase();
    return (firstLetter(parts[0]) + firstLetter(parts[1])).toUpperCase();
  }
}

// Subtle Pattern Painter
/// العربية: يمثل `SubtlePatternPainter`.
class _SubtlePatternPainter extends CustomPainter {
  /// العربية: يعالج `paint`.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryBlue.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    const radius = 100.0;
    const spacing = 150.0;

    for (double x = 0; x < size.width + radius; x += spacing) {
      for (double y = 0; y < size.height + radius; y += spacing) {
        canvas.drawCircle(
          Offset(x, y),
          radius,
          paint,
        );
      }
    }
  }

  /// العربية: يعالج `shouldRepaint`.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
