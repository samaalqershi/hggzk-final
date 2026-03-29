import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/conversation.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/media_grid_widget.dart';
import '../widgets/participant_item_widget.dart';

/// Conversation settings screen for participants, media, and chat preferences.
/// شاشة إعدادات المحادثة للمشاركين والوسائط وتفضيلات الدردشة.
class ChatSettingsPage extends StatefulWidget {
  /// Conversation whose settings are being viewed.
  /// المحادثة التي تُعرض إعداداتها.
  final Conversation conversation;

  /// Builds the settings screen for a single conversation.
  /// ينشئ شاشة الإعدادات لمحادثة واحدة.
  const ChatSettingsPage({
    super.key,
    required this.conversation,
  });

  /// Builds the state object for this widget.
  /// ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<ChatSettingsPage> createState() => _ChatSettingsPageState();
}

/// Controls tabs, header animations, and the loaded conversation metadata.
/// يدير الألسنة وحركات الترويسة وبيانات المحادثة المحملة.
class _ChatSettingsPageState extends State<ChatSettingsPage>
    with TickerProviderStateMixin {
  // Controllers
  /// العربية: يخزن القيمة `tabController`.
  late TabController _tabController;

  /// العربية: يخزن القيمة `fadeController`.
  late AnimationController _fadeController;

  /// العربية: يخزن القيمة `slideController`.
  late AnimationController _slideController;

  /// العربية: يخزن القيمة `glowController`.
  late AnimationController _glowController;

  /// العربية: يخزن القيمة `headerController`.
  late AnimationController _headerController;

  /// العربية: يخزن القيمة `floatingController`.
  late AnimationController _floatingController;

  // Animations
  /// العربية: يخزن القيمة `fadeAnimation`.
  late Animation<double> _fadeAnimation;

  /// العربية: يخزن القيمة `slideAnimation`.
  late Animation<Offset> _slideAnimation;

  /// العربية: يخزن القيمة `glowAnimation`.
  late Animation<double> _glowAnimation;

  /// العربية: يخزن القيمة `headerAnimation`.
  late Animation<double> _headerAnimation;

  /// العربية: يخزن القيمة `floatingAnimation`.
  late Animation<double> _floatingAnimation;

  // Scroll Controller
  final ScrollController _scrollController = ScrollController();

  // Data
  /// العربية: يخزن القيمة `currentUserId`.
  final String currentUserId = 'current_user';

  /// العربية: يخزن القيمة `notificationsEnabled`.
  bool _notificationsEnabled = true;

  /// العربية: يخزن القيمة `showReadReceipts`.
  bool _showReadReceipts = true;

  /// العربية: يخزن القيمة `theme`.
  String _theme = 'default';

  // UI State
  /// العربية: يخزن القيمة `headerOpacity`.
  double _headerOpacity = 1.0;

  /// العربية: يحدد ما إذا كانت القيمة `isHeaderExpanded` مفعلة.
  bool _isHeaderExpanded = true;

  // Background elements
  /// العربية: يخزن القيمة `floatingOrbs`.
  final List<_FloatingOrb> _floatingOrbs = [];

  /// Initializes the tab controller and page animations.
  /// يهيئ متحكم الألسنة وحركات الصفحة.
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _generateFloatingOrbs();
    _loadSettings();
    _scrollController.addListener(_onScroll);
  }

  /// العربية: يهيئ controllers.
  void _initializeControllers() {
    _tabController = TabController(length: 3, vsync: this);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  /// العربية: يهيئ animations.
  void _initializeAnimations() {
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_floatingController);

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _headerController.forward();
  }

  /// العربية: ينشئ floating orbs.
  void _generateFloatingOrbs() {
    for (int i = 0; i < 5; i++) {
      _floatingOrbs.add(_FloatingOrb());
    }
  }

  /// العربية: يعالج `onScroll`.
  void _onScroll() {
    final offset = _scrollController.offset;
    setState(() {
      _headerOpacity = (1.0 - (offset / 150)).clamp(0.0, 1.0);
      _isHeaderExpanded = offset < 50;
    });
  }

  /// العربية: يحرر الموارد المستخدمة بواسطة هذا الكائن.
  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _glowController.dispose();
    _headerController.dispose();
    _floatingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// العربية: يحمل settings.
  void _loadSettings() {
    context.read<ChatBloc>().add(const LoadChatSettingsEvent());
  }

  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Premium animated background
          _buildPremiumBackground(),

          // Floating orbs
          _buildFloatingOrbs(),

          // Main content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildPremiumSliverAppBar(),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        _buildPremiumInfoSection(),
                        _buildPremiumTabBar(),
                      ],
                    ),
                  ),
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPremiumMediaTab(),
                    _buildPremiumParticipantsTab(),
                    _buildPremiumSettingsTab(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// العربية: يبني premium background.
  Widget _buildPremiumBackground() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
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
          child: CustomPaint(
            painter: _PremiumBackgroundPainter(
              animation: _floatingAnimation.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  /// العربية: يبني floating orbs.
  Widget _buildFloatingOrbs() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return CustomPaint(
          painter: _FloatingOrbsPainter(
            orbs: _floatingOrbs,
            animation: _floatingController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  /// العربية: يبني premium sliver app bar.
  Widget _buildPremiumSliverAppBar() {
    final displayImage = widget.conversation.avatar ??
        widget.conversation.getOtherParticipant(currentUserId)?.profileImage;
    final displayName = widget.conversation.title ??
        widget.conversation.getOtherParticipant(currentUserId)?.name ??
        context.tr(
          'chat.settings.title',
        );

    return SliverAppBar(
      expandedHeight: 180, // Reduced from 200
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: _buildGlassIconButton(
        icon: Icons.arrow_back_ios_new_rounded,
        onPressed: () {
          HapticFeedback.selectionClick();
          Navigator.pop(context);
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image or gradient background
            if (displayImage != null)
              CachedImageWidget(
                imageUrl: displayImage,
                fit: BoxFit.cover,
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryBlue,
                      AppTheme.primaryPurple,
                      AppTheme.primaryViolet,
                    ],
                  ),
                ),
              ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),

            // Glass effect overlay
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _isHeaderExpanded ? 0 : 10,
                  sigmaY: _isHeaderExpanded ? 0 : 10,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.darkBackground.withOpacity(0.0),
                        AppTheme.darkBackground
                            .withOpacity(_headerOpacity * 0.9),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Avatar and title
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _headerAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _headerAnimation.value,
                    child: Opacity(
                      opacity: _headerOpacity,
                      child: Column(
                        children: [
                          // Avatar with glow effect
                          Container(
                            width: 72, // Reduced from 80
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: displayImage != null
                                  ? CachedImageWidget(
                                      imageUrl: displayImage,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.primaryBlue,
                                            AppTheme.primaryPurple,
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _getInitials(displayName),
                                          style: AppTextStyles.h2.copyWith(
                                            color: Colors.white,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Name with shimmer effect
                          AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0.8),
                                      Colors.white,
                                    ],
                                    stops: [
                                      0.0,
                                      _glowAnimation.value,
                                      1.0,
                                    ],
                                  ).createShader(bounds);
                                },
                                child: Text(
                                  displayName,
                                  style: AppTextStyles.h3.copyWith(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        _buildGlassIconButton(
          icon: Icons.more_vert_rounded,
          onPressed: _showMoreOptions,
        ),
      ],
    );
  }

  /// العربية: يبني glass icon button.
  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              width: 36, // Reduced from 40
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white.withOpacity(0.9),
                size: 18, // Reduced from 20
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// العربية: يبني premium info section.
  Widget _buildPremiumInfoSection() {
    return Container(
      margin: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
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
                if (widget.conversation.description != null) ...[
                  Text(
                    widget.conversation.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textMuted.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _PremiumInfoItem(
                      icon: Icons.message_rounded,
                      label: context.tr(
                        'chat.settings.info.messages',
                      ),
                      value: '1.2k',
                      animation: _glowAnimation,
                    ),
                    _PremiumInfoItem(
                      icon: Icons.image_rounded,
                      label: context.tr(
                        'chat.settings.info.media',
                      ),
                      value: '89',
                      animation: _glowAnimation,
                    ),
                    _PremiumInfoItem(
                      icon: Icons.attach_file_rounded,
                      label: context.tr(
                        'chat.settings.info.files',
                      ),
                      value: '12',
                      animation: _glowAnimation,
                    ),
                    if (widget.conversation.isGroupChat)
                      _PremiumInfoItem(
                        icon: Icons.group_rounded,
                        label: context.tr(
                          'chat.settings.info.members',
                        ),
                        value:
                            widget.conversation.participants.length.toString(),
                        animation: _glowAnimation,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// العربية: يبني premium tab bar.
  Widget _buildPremiumTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkCard.withOpacity(0.5),
                  AppTheme.darkCard.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.darkBorder.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryBlue,
              unselectedLabelColor: AppTheme.textMuted.withOpacity(0.5),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.1),
                    AppTheme.primaryPurple.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              labelStyle: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              tabs: [
                Tab(text: context.tr('chat.settings.tab.media')),
                Tab(text: context.tr('chat.settings.tab.members')),
                Tab(text: context.tr('chat.settings.tab.settings')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// العربية: يبني premium media tab.
  Widget _buildPremiumMediaTab() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is! ChatLoaded) {
          return _buildPremiumLoadingState();
        }

        final messages = state.messages[widget.conversation.id] ?? [];
        final mediaMessages = messages.where((m) {
          return ['image', 'video'].contains(m.messageType) ||
              m.attachments.any((a) => a.isImage || a.isVideo);
        }).toList();

        if (mediaMessages.isEmpty) {
          return _buildPremiumEmptyMediaState();
        }

        return Container(
          padding: const EdgeInsets.all(8),
          child: MediaGridWidget(
            messages: mediaMessages,
            onMediaTap: (message) {
              HapticFeedback.selectionClick();
              // Open media viewer
            },
          ),
        );
      },
    );
  }

  /// العربية: يبني premium participants tab.
  Widget _buildPremiumParticipantsTab() {
    if (widget.conversation.isDirectChat) {
      final otherParticipant =
          widget.conversation.getOtherParticipant(currentUserId);
      if (otherParticipant == null) return const SizedBox.shrink();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ParticipantItemWidget(
              participant: otherParticipant,
              isAdmin: false,
              onTap: () => _viewParticipantProfile(otherParticipant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: widget.conversation.participants.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildAddParticipantButton();
        }

        final participant = widget.conversation.participants[index - 1];
        final isAdmin = index == 1;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 50)),
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
                  child: ParticipantItemWidget(
                    participant: participant,
                    isAdmin: isAdmin,
                    isCurrentUser: participant.id == currentUserId,
                    onTap: () => _viewParticipantProfile(participant),
                    onRemove: isAdmin && participant.id != currentUserId
                        ? () => _removeParticipant(participant)
                        : null,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// العربية: يبني add participant button.
  Widget _buildAddParticipantButton() {
    return Container(
      margin: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: GestureDetector(
            onTap: _addParticipant,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.1),
                    AppTheme.primaryPurple.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.tr(
                      'chat.settings.addMember',
                    ),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
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

  /// العربية: يبني premium settings tab.
  Widget _buildPremiumSettingsTab() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoaded && state.settings != null) {
          _notificationsEnabled = state.settings!.notificationsEnabled;
          _showReadReceipts = state.settings!.showReadReceipts;
          _theme = state.settings!.theme;
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _buildPremiumSettingSection(
              title: context.tr(
                'chat.settings.notifications',
              ),
              icon: Icons.notifications_rounded,
              children: [
                _buildPremiumSwitch(
                  title: context.tr(
                    'chat.settings.notificationsEnabled',
                  ),
                  subtitle: context.tr(
                    'chat.settings.notificationsSubtitle',
                  ),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _updateSettings();
                  },
                ),
                _buildPremiumListTile(
                  icon: Icons.music_note_rounded,
                  title: context.tr(
                    'chat.settings.notificationSound',
                  ),
                  subtitle: context.tr(
                    'chat.settings.default',
                  ),
                  onTap: _changeNotificationSound,
                ),
              ],
            ),
            _buildPremiumSettingSection(
              title: context.tr(
                'chat.settings.privacy',
              ),
              icon: Icons.lock_rounded,
              children: [
                _buildPremiumSwitch(
                  title: context.tr(
                    'chat.settings.readReceipts',
                  ),
                  subtitle: context.tr(
                    'chat.settings.readReceiptsSubtitle',
                  ),
                  value: _showReadReceipts,
                  onChanged: (value) {
                    setState(() {
                      _showReadReceipts = value;
                    });
                    _updateSettings();
                  },
                ),
                _buildPremiumListTile(
                  icon: Icons.block_rounded,
                  title: context.tr(
                    'chat.settings.blockUser',
                  ),
                  subtitle: context.tr(
                    'chat.settings.blockUserSubtitle',
                  ),
                  onTap: _blockUser,
                  isDestructive: true,
                ),
              ],
            ),
            _buildPremiumSettingSection(
              title: context.tr(
                'chat.settings.appearance',
              ),
              icon: Icons.palette_rounded,
              children: [
                _buildPremiumListTile(
                  icon: Icons.wallpaper_rounded,
                  title: context.tr(
                    'chat.settings.chatBackground',
                  ),
                  subtitle: _theme == 'default'
                      ? context.tr('chat.settings.default')
                      : _theme,
                  onTap: _changeChatTheme,
                ),
                _buildPremiumListTile(
                  icon: Icons.text_fields_rounded,
                  title: context.tr(
                    'chat.settings.fontSize',
                  ),
                  subtitle: context.tr(
                    'chat.settings.fontSizeMedium',
                  ),
                  onTap: _changeFontSize,
                ),
              ],
            ),
            _buildPremiumSettingSection(
              title: context.tr(
                'chat.settings.storage',
              ),
              icon: Icons.storage_rounded,
              children: [
                _buildPremiumListTile(
                  icon: Icons.download_rounded,
                  title: context.tr(
                    'chat.settings.autoDownload',
                  ),
                  subtitle: context.tr(
                    'chat.settings.wifiOnly',
                  ),
                  onTap: _configureAutoDownload,
                ),
                _buildPremiumListTile(
                  icon: Icons.cleaning_services_rounded,
                  title: context.tr(
                    'chat.settings.clearCache',
                  ),
                  subtitle: context.tr(
                    'chat.settings.clearCacheSubtitle',
                  ),
                  onTap: _clearCache,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// العربية: يبني premium setting section.
  Widget _buildPremiumSettingSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue.withOpacity(0.15),
                        AppTheme.primaryPurple.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Section content with glass effect
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.darkCard.withOpacity(0.5),
                      AppTheme.darkCard.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.darkBorder.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                child: Column(children: children),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// العربية: يبني premium switch.
  Widget _buildPremiumSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.primaryBlue,
              activeTrackColor: AppTheme.primaryBlue.withOpacity(0.3),
              inactiveThumbColor: AppTheme.textMuted.withOpacity(0.5),
              inactiveTrackColor: AppTheme.darkBorder.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  /// العربية: يبني premium list tile.
  Widget _buildPremiumListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDestructive
                      ? [
                          AppTheme.error.withOpacity(0.15),
                          AppTheme.error.withOpacity(0.08),
                        ]
                      : [
                          AppTheme.darkSurface.withOpacity(0.5),
                          AppTheme.darkSurface.withOpacity(0.3),
                        ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isDestructive
                    ? AppTheme.error
                    : AppTheme.textMuted.withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? AppTheme.error : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: isDestructive
                          ? AppTheme.error.withOpacity(0.7)
                          : AppTheme.textMuted.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppTheme.textMuted.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  /// العربية: يبني premium loading state.
  Widget _buildPremiumLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryBlue.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('chat.settings.loading'),
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

  /// العربية: يبني premium empty media state.
  Widget _buildPremiumEmptyMediaState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
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
                    width: 56,
                    height: 56,
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
                      Icons.photo_library_rounded,
                      size: 28,
                      color: AppTheme.primaryBlue.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr(
                      'chat.settings.noMediaTitle',
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr(
                      'chat.settings.noMediaSubtitle',
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
    );
  }

  /// العربية: يعرض more options.
  void _showMoreOptions() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PremiumOptionsSheet(
        onSearch: _searchInChat,
        onExport: _exportChat,
        onLeave: widget.conversation.isGroupChat ? _leaveGroup : null,
        onClear: _clearChat,
      ),
    );
  }

  /// العربية: يحدّث settings.
  void _updateSettings() {
    context.read<ChatBloc>().add(
          UpdateChatSettingsEvent(
            notificationsEnabled: _notificationsEnabled,
            showReadReceipts: _showReadReceipts,
            theme: _theme,
          ),
        );
  }

  /// العربية: يعالج `viewParticipantProfile`.
  void _viewParticipantProfile(ChatUser participant) {
    HapticFeedback.selectionClick();
    // Navigate to participant profile
  }

  /// العربية: يعالج `addParticipant`.
  void _addParticipant() {
    HapticFeedback.selectionClick();
    // Show add participant dialog
  }

  /// العربية: يزيل participant.
  void _removeParticipant(ChatUser participant) {
    HapticFeedback.selectionClick();
    // Show confirmation and remove participant
  }

  /// العربية: يعالج `changeNotificationSound`.
  void _changeNotificationSound() {
    HapticFeedback.selectionClick();
    // Show notification sound picker
  }

  /// العربية: يعالج `blockUser`.
  void _blockUser() {
    HapticFeedback.selectionClick();
    // Show block user confirmation
  }

  /// العربية: يعالج `changeChatTheme`.
  void _changeChatTheme() {
    HapticFeedback.selectionClick();
    // Show theme picker
  }

  /// العربية: يعالج `changeFontSize`.
  void _changeFontSize() {
    HapticFeedback.selectionClick();
    // Show font size picker
  }

  /// العربية: يعالج `configureAutoDownload`.
  void _configureAutoDownload() {
    HapticFeedback.selectionClick();
    // Show auto download settings
  }

  /// العربية: يعالج `clearCache`.
  void _clearCache() {
    HapticFeedback.selectionClick();
    // Show clear cache confirmation
  }

  /// العربية: يعالج `searchInChat`.
  void _searchInChat() {
    HapticFeedback.selectionClick();
    // Navigate to search page
  }

  /// العربية: يعالج `exportChat`.
  void _exportChat() {
    HapticFeedback.selectionClick();
    // Export chat history
  }

  /// العربية: يعالج `leaveGroup`.
  void _leaveGroup() {
    HapticFeedback.selectionClick();
    // Show leave group confirmation
  }

  /// العربية: يعالج `clearChat`.
  void _clearChat() {
    HapticFeedback.selectionClick();
    // Show clear chat confirmation
  }

  /// العربية: يعيد initials.
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// Premium Info Item
/// العربية: يمثل `PremiumInfoItem`.
class _PremiumInfoItem extends StatelessWidget {
  /// العربية: يخزن القيمة `icon`.
  final IconData icon;

  /// العربية: يخزن القيمة `label`.
  final String label;

  /// العربية: يخزن القيمة `value`.
  final String value;

  /// العربية: يخزن القيمة `animation`.
  final Animation<double> animation;

  /// العربية: ينشئ مثيلًا جديدًا من `PremiumInfoItem`.
  const _PremiumInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.animation,
  });

  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkSurface.withOpacity(0.3 * animation.value),
                AppTheme.darkSurface.withOpacity(0.1 * animation.value),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
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
                  icon,
                  color: AppTheme.primaryBlue.withOpacity(0.8),
                  size: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Premium Options Sheet
/// العربية: يمثل `PremiumOptionsSheet`.
class _PremiumOptionsSheet extends StatelessWidget {
  /// العربية: يخزن القيمة `onSearch`.
  final VoidCallback onSearch;

  /// العربية: يخزن القيمة `onExport`.
  final VoidCallback onExport;

  /// العربية: يخزن القيمة `onLeave`.
  final VoidCallback? onLeave;

  /// العربية: يخزن القيمة `onClear`.
  final VoidCallback onClear;

  /// العربية: ينشئ مثيلًا جديدًا من `PremiumOptionsSheet`.
  const _PremiumOptionsSheet({
    required this.onSearch,
    required this.onExport,
    this.onLeave,
    required this.onClear,
  });

  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkCard.withOpacity(0.9),
                  AppTheme.darkCard.withOpacity(0.8),
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
                  width: 32,
                  height: 3,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.darkBorder.withOpacity(0.3),
                        AppTheme.darkBorder.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                _buildOption(
                  icon: Icons.search_rounded,
                  title: context.tr(
                    'chat.settings.searchInChat',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onSearch();
                  },
                ),
                _buildOption(
                  icon: Icons.download_rounded,
                  title: context.tr(
                    'chat.settings.exportChat',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onExport();
                  },
                ),
                if (onLeave != null)
                  _buildOption(
                    icon: Icons.exit_to_app_rounded,
                    title: context.tr(
                      'chat.settings.leaveGroup',
                    ),
                    color: AppTheme.error,
                    onTap: () {
                      Navigator.pop(context);
                      onLeave!();
                    },
                  ),
                _buildOption(
                  icon: Icons.clear_all_rounded,
                  title: context.tr(
                    'chat.settings.clearChat',
                  ),
                  color: AppTheme.error,
                  onTap: () {
                    Navigator.pop(context);
                    onClear();
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (color ?? AppTheme.primaryBlue).withOpacity(0.1),
                    (color ?? AppTheme.primaryBlue).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color ?? AppTheme.textMuted,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: color ?? AppTheme.textWhite,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Floating Orb Model
/// العربية: يمثل `FloatingOrb`.
class _FloatingOrb {
  double x = math.Random().nextDouble();
  double y = math.Random().nextDouble();
  double radius = math.Random().nextDouble() * 50 + 30;
  double opacity = math.Random().nextDouble() * 0.03 + 0.01;
  double speed = math.Random().nextDouble() * 0.0001 + 0.00005;
  Color color = [
    AppTheme.primaryBlue,
    AppTheme.primaryPurple,
    AppTheme.primaryCyan,
  ][math.Random().nextInt(3)];
}

// Painters
/// العربية: يمثل `PremiumBackgroundPainter`.
class _PremiumBackgroundPainter extends CustomPainter {
  /// العربية: يخزن القيمة `animation`.
  final double animation;

  /// العربية: ينشئ مثيلًا جديدًا من `PremiumBackgroundPainter`.
  _PremiumBackgroundPainter({required this.animation});

  /// العربية: يعالج `paint`.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.2
      ..color = AppTheme.primaryBlue.withOpacity(0.02);

    // Draw animated grid
    const spacing = 50.0;
    final offset = animation * spacing;

    for (double x = -spacing + offset % spacing;
        x < size.width + spacing;
        x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = -spacing + offset % spacing;
        y < size.height + spacing;
        y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  /// العربية: يعالج `shouldRepaint`.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// العربية: يمثل `FloatingOrbsPainter`.
class _FloatingOrbsPainter extends CustomPainter {
  /// العربية: يخزن القيمة `orbs`.
  final List<_FloatingOrb> orbs;

  /// العربية: يخزن القيمة `animation`.
  final double animation;

  /// العربية: ينشئ مثيلًا جديدًا من `FloatingOrbsPainter`.
  _FloatingOrbsPainter({
    required this.orbs,
    required this.animation,
  });

  /// العربية: يعالج `paint`.
  @override
  void paint(Canvas canvas, Size size) {
    for (var orb in orbs) {
      orb.y -= orb.speed;
      if (orb.y < -0.1) {
        orb.y = 1.1;
        orb.x = math.Random().nextDouble();
      }

      final paint = Paint()
        ..color = orb.color.withOpacity(orb.opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

      canvas.drawCircle(
        Offset(
          orb.x * size.width + math.sin(animation + orb.x * math.pi) * 20,
          orb.y * size.height,
        ),
        orb.radius,
        paint,
      );
    }
  }

  /// العربية: يعالج `shouldRepaint`.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
