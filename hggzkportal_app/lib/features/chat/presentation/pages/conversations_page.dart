// lib/features/chat/presentation/pages/conversations_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/conversation.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/conversation_item_widget.dart';
import '../widgets/chat_fab.dart';
import 'chat_page.dart';
import 'new_conversation_page.dart';

/// Inbox screen that lists conversations, search, and quick entry actions.
/// شاشة الصندوق الوارد التي تعرض المحادثات والبحث وأفعال الدخول السريع.
class ConversationsPage extends StatefulWidget {
  /// Builds the conversation inbox screen.
  /// ينشئ شاشة صندوق المحادثات الوارد.
  const ConversationsPage({super.key});

  /// Builds the state object for this widget.
  /// ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

/// Keeps the inbox list, search overlay, and scroll-driven animations in sync.
/// يبقي قائمة الصندوق الوارد والبحث والحوكات المتحركة متزامنة.
class _ConversationsPageState extends State<ConversationsPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  // Animation Controllers
  /// العربية: يخزن القيمة `fadeController`.
  late AnimationController _fadeController;

  /// العربية: يخزن القيمة `slideController`.
  late AnimationController _slideController;

  /// العربية: يخزن القيمة `shimmerController`.
  late AnimationController _shimmerController;

  /// العربية: يخزن القيمة `backgroundController`.
  late AnimationController _backgroundController;

  /// العربية: يخزن القيمة `pulseController`.
  late AnimationController _pulseController;

  /// العربية: يخزن القيمة `fadeAnimation`.
  late Animation<double> _fadeAnimation;

  /// العربية: يخزن القيمة `slideAnimation`.
  late Animation<Offset> _slideAnimation;

  /// العربية: يخزن القيمة `shimmerAnimation`.
  late Animation<double> _shimmerAnimation;

  /// العربية: يخزن القيمة `backgroundAnimation`.
  late Animation<double> _backgroundAnimation;

  /// العربية: يخزن القيمة `pulseAnimation`.
  late Animation<double> _pulseAnimation;

  /// العربية: يحدد ما إذا كانت القيمة `isSearching` مفعلة.
  bool _isSearching = false;

  /// العربية: يخزن القيمة `searchQuery`.
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Minimal background particles
  /// العربية: يخزن القيمة `particles`.
  final List<_MinimalParticle> _particles = [];

  /// Initializes animations, particle state, and the first conversation load.
  /// يهيئ الحركات وحالة الجسيمات وأول تحميل للمحادثات.
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _loadConversations();
    _scrollController.addListener(_onScroll);
  }

  /// العربية: يهيئ animations.
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.02),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _shimmerAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_backgroundController);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  /// العربية: ينشئ particles.
  void _generateParticles() {
    for (int i = 0; i < 5; i++) {
      _particles.add(_MinimalParticle());
    }
  }

  /// العربية: يحرر الموارد المستخدمة بواسطة هذا الكائن.
  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _shimmerController.dispose();
    _backgroundController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// العربية: يحمل conversations.
  void _loadConversations() {
    context.read<ChatBloc>().add(const InitializeChatEvent());
  }

  /// العربية: يعالج `onScroll`.
  void _onScroll() {
    if (_isBottom) {
      final state = context.read<ChatBloc>().state;
      if (state is ChatLoaded && !state.isLoadingMore) {
        context.read<ChatBloc>().add(
              LoadConversationsEvent(
                pageNumber: (state.conversations.length ~/ 20) + 1,
              ),
            );
      }
    }
  }

  /// العربية: يعيد القيمة `isBottom`.
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (previous, current) {
          return current is! AuthLoading;
        },
        builder: (context, authState) {
          if (authState is AuthUnauthenticated) {
            return _buildUnauthenticatedView(context);
          }

          return Stack(
            children: [
              // Ultra minimal gradient background
              _buildUltraMinimalBackground(),

              // Subtle floating particles
              _buildSubtleParticles(),

              // Main content with glass overlay
              SafeArea(
                child: Column(
                  children: [
                    _buildUltraPremiumHeader(),
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildConversationsList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthUnauthenticated) {
            return const SizedBox.shrink();
          }
          return ChatFAB(
            onPressed: _startNewConversation,
          );
        },
      ),
    );
  }

  /// العربية: يبني ultra minimal background.
  Widget _buildUltraMinimalBackground() {
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
      child: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _UltraMinimalGradientPainter(
              animation: _backgroundAnimation.value,
              pulseAnimation: _pulseAnimation.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  /// العربية: يبني subtle particles.
  Widget _buildSubtleParticles() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return CustomPaint(
          painter: _SubtleParticlePainter(
            particles: _particles,
            animation: _backgroundController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  /// العربية: يبني ultra premium header.
  Widget _buildUltraPremiumHeader() {
    return Container(
      height: _isSearching ? 110 : 60,
      child: Stack(
        children: [
          // Glass background
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.darkCard.withOpacity(0.05),
                      AppTheme.darkCard.withOpacity(0.02),
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.darkBorder.withOpacity(0.05),
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          Column(
            children: [
              _buildMinimalHeaderContent(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: _isSearching ? 50 : 0,
                child: _isSearching ? _buildUltraMinimalSearch() : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// العربية: يبني minimal header content.
  Widget _buildMinimalHeaderContent() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Minimal logo
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue
                          .withOpacity(0.1 * _pulseAnimation.value),
                      AppTheme.primaryPurple
                          .withOpacity(0.05 * _pulseAnimation.value),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.forum_outlined,
                  color: AppTheme.primaryBlue.withOpacity(0.6),
                  size: 16,
                ),
              );
            },
          ),

          const SizedBox(width: 12),

          // Minimal title
          Text(
            context.tr('chat.inbox.title'),
            style: AppTextStyles.h3.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textWhite.withOpacity(0.9),
              letterSpacing: 0.5,
            ),
          ),

          const Spacer(),

          // Minimal search toggle
          _buildMinimalIconButton(
            icon: _isSearching ? Icons.close : Icons.search,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                  _searchFocusNode.unfocus();
                } else {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _searchFocusNode.requestFocus();
                  });
                }
              });
            },
          ),

          const SizedBox(width: 8),

          // Minimal menu
          _buildMinimalIconButton(
            icon: Icons.more_horiz,
            onTap: _showMinimalOptions,
          ),
        ],
      ),
    );
  }

  /// العربية: يبني minimal icon button.
  Widget _buildMinimalIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withOpacity(0.05),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.05),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          color: AppTheme.textWhite.withOpacity(0.6),
          size: 16,
        ),
      ),
    );
  }

  /// العربية: يبني ultra minimal search.
  Widget _buildUltraMinimalSearch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withOpacity(0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: AppTheme.textWhite.withOpacity(0.9),
              ),
              decoration: InputDecoration(
                hintText: context.tr(
                  'chat.inbox.searchHint',
                ),
                hintStyle: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted.withOpacity(0.3),
                  fontSize: 12,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  size: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// العربية: يبني conversations list.
  Widget _buildConversationsList() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return _buildUltraMinimalLoading();
        }

        if (state is ChatError) {
          return _buildUltraMinimalError(state.message);
        }

        if (state is ChatLoaded) {
          final conversations = _filterConversations(state.conversations);

          if (conversations.isEmpty) {
            return _buildUltraMinimalEmpty();
          }

          return _buildUltraPremiumList(conversations, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// العربية: يبني ultra minimal loading.
  Widget _buildUltraMinimalLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ultra minimal loading animation
          AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Rotating gradient border
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: SweepGradient(
                          colors: [
                            Colors.transparent,
                            AppTheme.primaryBlue.withOpacity(0.2),
                            AppTheme.primaryPurple.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.25, 0.5, 1.0],
                          transform: GradientRotation(
                              _shimmerAnimation.value * 2 * math.pi),
                        ),
                      ),
                    ),

                    // Icon
                    Icon(
                      Icons.forum_outlined,
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      size: 18,
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          Text(
            context.tr('chat.inbox.loading'),
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// العربية: يبني ultra minimal error.
  Widget _buildUltraMinimalError(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.error.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: AppTheme.error.withOpacity(0.5),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.error.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _loadConversations,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.error.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  context.tr('chat.inbox.retry'),
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.error.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// العربية: يبني ultra minimal empty.
  Widget _buildUltraMinimalEmpty() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.95 + (0.05 * value),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryBlue.withOpacity(0.05),
                            AppTheme.primaryPurple.withOpacity(0.02),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.forum_outlined,
                        size: 24,
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isSearching
                          ? context.tr(
                              'chat.inbox.emptySearchTitle',
                            )
                          : context.tr(
                              'chat.inbox.emptyTitle',
                            ),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        color: AppTheme.textWhite.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isSearching
                          ? context.tr(
                              'chat.inbox.emptySearchSubtitle',
                            )
                          : context.tr(
                              'chat.inbox.emptySubtitle',
                            ),
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                    if (!_isSearching) ...[
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _startNewConversation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryBlue.withOpacity(0.8),
                                AppTheme.primaryPurple.withOpacity(0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                context.tr(
                                  'chat.inbox.startConversation',
                                ),
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// العربية: يبني ultra premium list.
  Widget _buildUltraPremiumList(
    List<Conversation> conversations,
    ChatLoaded state,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.lightImpact();
        context.read<ChatBloc>().add(const LoadConversationsEvent());
      },
      color: AppTheme.primaryBlue,
      backgroundColor: AppTheme.darkCard,
      displacement: 20,
      strokeWidth: 1.5,
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.only(
          top: 4,
          bottom: 80, // Space for FAB
        ),
        itemCount: conversations.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= conversations.length) {
            return _buildMinimalLoadMore();
          }

          final conversation = conversations[index];
          final typingUsers = state.typingUsers[conversation.id] ?? [];
          final currentUserId = state.currentUserId ?? '';

          return TweenAnimationBuilder<double>(
            key: ValueKey(conversation.id),
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 200 + (index * 30).clamp(0, 300)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(10 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: ConversationItemWidget(
                    conversation: conversation,
                    currentUserId: currentUserId,
                    typingUserIds: typingUsers,
                    onTap: () => _openChat(conversation),
                    onLongPress: () => _showConversationOptions(conversation),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// العربية: يبني minimal load more.
  Widget _buildMinimalLoadMore() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.primaryBlue.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  /// العربية: يعالج `filterConversations`.
  List<Conversation> _filterConversations(List<Conversation> conversations) {
    if (_searchQuery.isEmpty) return conversations;

    final query = _searchQuery.toLowerCase();
    return conversations.where((conversation) {
      final title = conversation.title?.toLowerCase() ?? '';
      final lastMessage =
          conversation.lastMessage?.content?.toLowerCase() ?? '';
      return title.contains(query) || lastMessage.contains(query);
    }).toList();
  }

  /// العربية: يفتح chat.
  void _openChat(Conversation conversation) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ChatPage(conversation: conversation),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  /// العربية: يبني unauthenticated view.
  Widget _buildUnauthenticatedView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.darkBackground,
            AppTheme.darkSurface.withOpacity(0.95),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.darkCard.withOpacity(0.3),
                      AppTheme.darkCard.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.15),
                    width: 0.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Center(
                      child: Icon(
                        Icons.forum_outlined,
                        size: 48,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                context.tr(
                  'chat.inbox.loginPromptTitle',
                ),
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.tr(
                  'chat.inbox.loginPromptBody',
                ),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _buildMinimalButton(
                onPressed: () => context.push(RouteConstants.login),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.login_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('common.login'),
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// العربية: يبني minimal button.
  Widget _buildMinimalButton({
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryBlue.withOpacity(0.8),
                AppTheme.primaryPurple.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  /// العربية: يبدأ new conversation.
  void _startNewConversation() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NewConversationPage(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.5),
            ),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.98,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  /// العربية: يعرض minimal options.
  void _showMinimalOptions() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black26,
      builder: (context) => _UltraMinimalOptionsSheet(
        onArchiveAll: () {
          // Archive all conversations
        },
        onSettings: () {
          // Open settings
        },
      ),
    );
  }

  /// العربية: يعرض conversation options.
  void _showConversationOptions(Conversation conversation) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black26,
      isScrollControlled: true,
      builder: (context) => _UltraMinimalConversationSheet(
        conversation: conversation,
        onArchive: () {
          context.read<ChatBloc>().add(
                conversation.isArchived
                    ? UnarchiveConversationEvent(
                        conversationId: conversation.id)
                    : ArchiveConversationEvent(conversationId: conversation.id),
              );
        },
        onDelete: () {
          _confirmDelete(conversation);
        },
        onMute: () {
          // Toggle mute
        },
      ),
    );
  }

  /// العربية: يعالج `confirmDelete`.
  void _confirmDelete(Conversation conversation) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) => _UltraMinimalDialog(
        title: context.tr(
          'chat.inbox.deleteConversationTitle',
        ),
        message: context.tr(
          'chat.inbox.deleteConversationMessage',
        ),
        confirmText: context.tr('chat.inbox.action.delete'),
        isDestructive: true,
        onConfirm: () {
          context.read<ChatBloc>().add(
                DeleteConversationEvent(conversationId: conversation.id),
              );
          Navigator.pop(context);
        },
      ),
    );
  }
}

// Ultra Minimal Options Sheet
/// العربية: يمثل `UltraMinimalOptionsSheet`.
class _UltraMinimalOptionsSheet extends StatelessWidget {
  /// العربية: يخزن القيمة `onArchiveAll`.
  final VoidCallback onArchiveAll;

  /// العربية: يخزن القيمة `onSettings`.
  final VoidCallback onSettings;

  /// العربية: ينشئ مثيلًا جديدًا من `UltraMinimalOptionsSheet`.
  const _UltraMinimalOptionsSheet({
    required this.onArchiveAll,
    required this.onSettings,
  });

  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.darkCard.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.darkBorder.withOpacity(0.05),
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 28,
                  height: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.darkBorder.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),

                _buildMinimalOption(
                  icon: Icons.archive_outlined,
                  title: context.tr(
                    'chat.inbox.action.archiveAll',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onArchiveAll();
                  },
                ),

                _buildMinimalOption(
                  icon: Icons.settings_outlined,
                  title: context.tr(
                    'chat.inbox.action.settings',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onSettings();
                  },
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// العربية: يبني minimal option.
  Widget _buildMinimalOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.textMuted.withOpacity(0.6),
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textWhite.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Ultra Minimal Conversation Options
/// العربية: يمثل `UltraMinimalConversationSheet`.
class _UltraMinimalConversationSheet extends StatelessWidget {
  /// العربية: يخزن القيمة `conversation`.
  final Conversation conversation;

  /// العربية: يخزن القيمة `onArchive`.
  final VoidCallback onArchive;

  /// العربية: يخزن القيمة `onDelete`.
  final VoidCallback onDelete;

  /// العربية: يخزن القيمة `onMute`.
  final VoidCallback onMute;

  /// العربية: ينشئ مثيلًا جديدًا من `UltraMinimalConversationSheet`.
  const _UltraMinimalConversationSheet({
    required this.conversation,
    required this.onArchive,
    required this.onDelete,
    required this.onMute,
  });

  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.darkCard.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.darkBorder.withOpacity(0.05),
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.darkBorder.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                _buildOption(
                  icon: conversation.isMuted
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_off_outlined,
                  title: conversation.isMuted
                      ? context.tr(
                          'chat.inbox.action.unmute',
                        )
                      : context.tr(
                          'chat.inbox.action.mute',
                        ),
                  onTap: () {
                    Navigator.pop(context);
                    onMute();
                  },
                ),
                _buildOption(
                  icon: conversation.isArchived
                      ? Icons.unarchive_outlined
                      : Icons.archive_outlined,
                  title: conversation.isArchived
                      ? context.tr(
                          'chat.inbox.action.unarchive',
                        )
                      : context.tr(
                          'chat.inbox.action.archive',
                        ),
                  onTap: () {
                    Navigator.pop(context);
                    onArchive();
                  },
                ),
                _buildOption(
                  icon: Icons.delete_outline,
                  title: context.tr('chat.inbox.action.delete'),
                  color: AppTheme.error.withOpacity(0.7),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// العربية: يبني option.
  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? AppTheme.textMuted.withOpacity(0.6),
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: color ?? AppTheme.textWhite.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Ultra Minimal Dialog
/// العربية: يمثل `UltraMinimalDialog`.
class _UltraMinimalDialog extends StatelessWidget {
  /// العربية: يخزن القيمة `title`.
  final String title;

  /// العربية: يخزن القيمة `message`.
  final String message;

  /// العربية: يخزن القيمة `confirmText`.
  final String confirmText;

  /// العربية: يحدد ما إذا كانت القيمة `isDestructive` مفعلة.
  final bool isDestructive;

  /// العربية: يخزن القيمة `onConfirm`.
  final VoidCallback onConfirm;

  /// العربية: ينشئ مثيلًا جديدًا من `UltraMinimalDialog`.
  const _UltraMinimalDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.onConfirm,
    this.isDestructive = false,
  });

  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDestructive
                      ? AppTheme.error.withOpacity(0.1)
                      : AppTheme.darkBorder.withOpacity(0.05),
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isDestructive)
                    Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.error.withOpacity(0.7),
                        size: 20,
                      ),
                    ),
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted.withOpacity(0.6),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.darkBorder.withOpacity(0.1),
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              context.tr(
                                'chat.inbox.action.cancel',
                              ),
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onConfirm();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDestructive
                                    ? [
                                        AppTheme.error.withOpacity(0.7),
                                        AppTheme.error.withOpacity(0.5),
                                      ]
                                    : [
                                        AppTheme.primaryBlue.withOpacity(0.8),
                                        AppTheme.primaryPurple.withOpacity(0.6),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              confirmText,
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Minimal Particle Model
/// العربية: يمثل `MinimalParticle`.
class _MinimalParticle {
  double x = math.Random().nextDouble();
  double y = math.Random().nextDouble();
  double size = math.Random().nextDouble() * 60 + 20;
  double opacity = math.Random().nextDouble() * 0.02 + 0.01;
  double speed = math.Random().nextDouble() * 0.00005 + 0.00001;
  Color color = [
    AppTheme.primaryBlue,
    AppTheme.primaryPurple,
  ][math.Random().nextInt(2)];
}

// Painters
/// العربية: يمثل `UltraMinimalGradientPainter`.
class _UltraMinimalGradientPainter extends CustomPainter {
  /// العربية: يخزن القيمة `animation`.
  final double animation;

  /// العربية: يخزن القيمة `pulseAnimation`.
  final double pulseAnimation;

  /// العربية: ينشئ مثيلًا جديدًا من `UltraMinimalGradientPainter`.
  _UltraMinimalGradientPainter({
    required this.animation,
    required this.pulseAnimation,
  });

  /// العربية: يعالج `paint`.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    // Ultra subtle gradient circles
    final positions = [
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.2, size.height * 0.7),
    ];

    final colors = [
      AppTheme.primaryBlue.withOpacity(0.02 * pulseAnimation),
      AppTheme.primaryPurple.withOpacity(0.01 * pulseAnimation),
    ];

    for (int i = 0; i < positions.length; i++) {
      final offset = Offset(
        positions[i].dx + math.sin(animation + i) * 10,
        positions[i].dy + math.cos(animation + i) * 10,
      );

      paint.color = colors[i];
      canvas.drawCircle(offset, 100, paint);
    }
  }

  /// العربية: يعالج `shouldRepaint`.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// العربية: يمثل `SubtleParticlePainter`.
class _SubtleParticlePainter extends CustomPainter {
  /// العربية: يخزن القيمة `particles`.
  final List<_MinimalParticle> particles;

  /// العربية: يخزن القيمة `animation`.
  final double animation;

  /// العربية: ينشئ مثيلًا جديدًا من `SubtleParticlePainter`.
  _SubtleParticlePainter({
    required this.particles,
    required this.animation,
  });

  /// العربية: يعالج `paint`.
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.y -= particle.speed;
      if (particle.y < -0.1) {
        particle.y = 1.1;
        particle.x = math.Random().nextDouble();
      }

      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  /// العربية: يعالج `shouldRepaint`.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
