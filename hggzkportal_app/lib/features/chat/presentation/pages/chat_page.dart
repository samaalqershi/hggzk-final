import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/attachment.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/message_bubble_widget.dart';
import '../widgets/image_message_bubble.dart';
import '../widgets/message_input_widget.dart';
import '../widgets/typing_indicator_widget.dart';
import '../widgets/chat_app_bar.dart';
import 'chat_settings_page.dart';
// Provider typing indicator removed; rely on ChatBloc.state
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// يعرّف الكلاس `ChatPage`.
/// Describes the `ChatPage` class.
class ChatPage extends StatefulWidget {
  /// Holds the `conversation` value.
  /// العربية: يخزن القيمة `conversation`.
  final Conversation conversation;

  /// ينشئ مثيلاً من `ChatPage`.
  /// Builds an instance of `ChatPage`.
  const ChatPage({
    super.key,
    required this.conversation,
  });

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<ChatPage> createState() => _ChatPageState();
}

/// يعرّف الكلاس `_ChatPageState`.
/// Describes the `_ChatPageState` class.
class _ChatPageState extends State<ChatPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  /// يخزن العضو `_messageKeys`.
  /// Holds the `_messageKeys` member.
  final Map<String, GlobalKey> _messageKeys = {};

  /// يخزن العضو `_fadeController`.
  /// Holds the `_fadeController` member.
  late AnimationController _fadeController;

  /// يخزن العضو `_backgroundController`.
  /// Holds the `_backgroundController` member.
  late AnimationController _backgroundController;

  /// يخزن العضو `_particleController`.
  /// Holds the `_particleController` member.
  late AnimationController _particleController;

  /// يخزن العضو `_glowController`.
  /// Holds the `_glowController` member.
  late AnimationController _glowController;

  /// يخزن العضو `_fadeAnimation`.
  /// Holds the `_fadeAnimation` member.
  late Animation<double> _fadeAnimation;

  /// يخزن العضو `_backgroundAnimation`.
  /// Holds the `_backgroundAnimation` member.
  late Animation<double> _backgroundAnimation;

  /// يخزن العضو `_scaleAnimation`.
  /// Holds the `_scaleAnimation` member.
  late Animation<double> _scaleAnimation;

  /// يخزن العضو `_glowAnimation`.
  /// Holds the `_glowAnimation` member.
  late Animation<double> _glowAnimation;

  /// يخزن العضو `_particles`.
  /// Holds the `_particles` member.
  final List<_ChatParticle> _particles = [];

  /// يخزن العضو `_typingTimer`.
  /// Holds the `_typingTimer` member.
  Timer? _typingTimer;

  /// يخزن العضو `_isTyping`.
  /// Holds the `_isTyping` member.
  bool _isTyping = false;

  /// يخزن العضو `_showScrollToBottom`.
  /// Holds the `_showScrollToBottom` member.
  bool _showScrollToBottom = false;

  /// يخزن العضو `_replyToMessageId`.
  /// Holds the `_replyToMessageId` member.
  String? _replyToMessageId;

  /// يخزن العضو `_replyToAttachment`.
  /// Holds the `_replyToAttachment` member.
  Attachment? _replyToAttachment;

  /// يخزن العضو `_editingMessage`.
  /// Holds the `_editingMessage` member.
  Message? _editingMessage;

  /// يخزن العضو `_currentUserId`.
  /// Holds the `_currentUserId` member.
  String? _currentUserId;

  /// يخزن العضو `_authSubscription`.
  /// Holds the `_authSubscription` member.
  StreamSubscription<AuthState>? _authSubscription;

  /// يخزن العضو `_chatStateSubscription`.
  /// Holds the `_chatStateSubscription` member.
  StreamSubscription<ChatState>? _chatStateSubscription;

  /// يخزن العضو `_isScrollingToReply`.
  /// Holds the `_isScrollingToReply` member.
  bool _isScrollingToReply = false;

  /// يخزن العضو `_loadingOverlay`.
  /// Holds the `_loadingOverlay` member.
  OverlayEntry? _loadingOverlay;

  /// ينفذ العملية `initState`.
  /// Runs the `initState` operation.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _generateParticles();
    _syncCurrentUser();
    _loadMessages();
    _scrollController.addListener(_onScroll);
    _messageController.addListener(_onTypingChanged);
    // Typing indicator and WebSocket subscriptions are handled in ChatBloc
    _subscribeToChatStateForAutoRead();
  }

  /// ينفذ العملية `_initializeAnimations`.
  /// Runs the `_initializeAnimations` operation.
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_backgroundController);

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutBack,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  /// ينفذ العملية `_generateParticles`.
  /// Runs the `_generateParticles` operation.
  void _generateParticles() {
    for (int i = 0; i < 8; i++) {
      _particles.add(_ChatParticle());
    }
  }

  // WebSocket subscriptions removed here; BLoC emits state updates we listen to below

  /// ينفذ العملية `_subscribeToChatStateForAutoRead`.
  /// Runs the `_subscribeToChatStateForAutoRead` operation.
  void _subscribeToChatStateForAutoRead() {
    final bloc = context.read<ChatBloc>();
    _chatStateSubscription = bloc.stream.listen((state) {
      if (!mounted) return;
      if (state is ChatLoaded) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _markMessagesAsRead());
      }
    });
  }

  /// ينفذ العملية `dispose`.
  /// Runs the `dispose` operation.
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    _fadeController.dispose();
    _backgroundController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    _typingTimer?.cancel();
    _authSubscription?.cancel();
    _chatStateSubscription?.cancel();
    _loadingOverlay?.remove();
    super.dispose();
  }

  /// ينفذ العملية `didChangeAppLifecycleState`.
  /// Runs the `didChangeAppLifecycleState` operation.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _markMessagesAsRead();
    }
  }

  /// ينفذ العملية `_loadMessages`.
  /// Runs the `_loadMessages` operation.
  void _loadMessages() {
    context.read<ChatBloc>().add(
          LoadMessagesEvent(
            conversationId: widget.conversation.id,
          ),
        );
    WidgetsBinding.instance.addPostFrameCallback((_) => _markMessagesAsRead());
  }

  /// ينفذ العملية `_onScroll`.
  /// Runs the `_onScroll` operation.
  void _onScroll() {
    if (_scrollController.hasClients) {
      final showButton = _scrollController.offset > 200;
      if (showButton != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = showButton;
        });
      }

      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreMessages();
      }
    }
  }

  /// ينفذ العملية `_loadMoreMessages`.
  /// Runs the `_loadMoreMessages` operation.
  void _loadMoreMessages() {
    final state = context.read<ChatBloc>().state;
    if (state is ChatLoaded && !state.isLoadingMessages) {
      final messages = state.messages[widget.conversation.id] ?? [];
      if (messages.isNotEmpty) {
        context.read<ChatBloc>().add(
              LoadMessagesEvent(
                conversationId: widget.conversation.id,
                pageNumber: (messages.length ~/ 50) + 1,
                beforeMessageId: messages.last.id,
              ),
            );
      }
    }
  }

  /// ينفذ العملية `_onTypingChanged`.
  /// Runs the `_onTypingChanged` operation.
  void _onTypingChanged() {
    if (_messageController.text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      context.read<ChatBloc>().add(
            SendTypingIndicatorEvent(
              conversationId: widget.conversation.id,
              isTyping: true,
            ),
          );
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      if (_isTyping) {
        _isTyping = false;
        context.read<ChatBloc>().add(
              SendTypingIndicatorEvent(
                conversationId: widget.conversation.id,
                isTyping: false,
              ),
            );
      }
    });
  }

  /// ينفذ العملية `_markMessagesAsRead`.
  /// Runs the `_markMessagesAsRead` operation.
  void _markMessagesAsRead() {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) return;
    final state = context.read<ChatBloc>().state;
    if (state is ChatLoaded) {
      final List<Message> messages =
          (state.messages[widget.conversation.id] ?? []).cast<Message>();
      final unreadMessages = messages
          .where((m) => m.senderId != userId && !m.isRead)
          .map((m) => m.id)
          .toList();

      if (unreadMessages.isNotEmpty) {
        context.read<ChatBloc>().add(
              MarkMessagesAsReadEvent(
                conversationId: widget.conversation.id,
                messageIds: unreadMessages,
              ),
            );
      }
    }
  }

  /// ينفذ العملية `didUpdateWidget`.
  /// Runs the `didUpdateWidget` operation.
  @override
  void didUpdateWidget(covariant ChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _markMessagesAsRead());
  }

  // FIX: إصلاح المشكلة 1 - التنقل للرد (محسّن بالكامل)
  /// ينفذ العملية `_scrollToMessage`.
  /// Runs the `_scrollToMessage` operation.
  void _scrollToMessage(String messageId) {
    if (_isScrollingToReply) {
      return;
    }

    // أولاً: تحقق من وجود الرسالة في القائمة الحالية
    final bloc = context.read<ChatBloc>();
    final state = bloc.state;

    if (state is! ChatLoaded) return;

    final convoId = widget.conversation.id;
    final List<Message> currentMessages =
        (state.messages[convoId] ?? []).cast<Message>();

    // البحث عن الرسالة في القائمة الحالية
    final messageExists = currentMessages.any((m) => m.id == messageId);

    if (messageExists) {
      // الرسالة موجودة - انتظر دورة بناء واحدة ثم مرر
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final key = _messageKeys[messageId];

        if (key?.currentContext != null) {
          _isScrollingToReply = true;
          Scrollable.ensureVisible(
            key!.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutExpo,
            alignment: 0.5,
          ).then((_) {
            _isScrollingToReply = false;
            _highlightMessage(messageId);
          });
          HapticFeedback.lightImpact();
        } else {
          // المفتاح غير جاهز بعد - انتظر دورة أخرى
          Future.delayed(const Duration(milliseconds: 100), () {
            final key2 = _messageKeys[messageId];
            if (key2?.currentContext != null) {
              _isScrollingToReply = true;
              Scrollable.ensureVisible(
                key2!.currentContext!,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutExpo,
                alignment: 0.5,
              ).then((_) {
                _isScrollingToReply = false;
                _highlightMessage(messageId);
              });
              HapticFeedback.lightImpact();
            } else {
              // ignore
            }
          });
        }
      });
    } else {
      // الرسالة غير موجودة - ابدأ التحميل
      _showLoadingIndicator();
      _isScrollingToReply = true;
      _loadOlderMessagesUntilFound(messageId, bloc, convoId);
    }
  }

  /// ينفذ العملية `_loadOlderMessagesUntilFound`.
  /// Runs the `_loadOlderMessagesUntilFound` operation.
  void _loadOlderMessagesUntilFound(
      String messageId, ChatBloc bloc, String convoId) {
    int attempts = 0;
    const maxAttempts = 10;

    void tryFindAfterLoad() {
      if (!mounted || !_isScrollingToReply) {
        _hideLoadingIndicator();
        return;
      }

      attempts++;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final st = bloc.state;
        if (st is ChatLoaded) {
          final msgs = (st.messages[convoId] ?? []).cast<Message>();
          final found = msgs.any((m) => m.id == messageId);

          if (found) {
            _hideLoadingIndicator();

            Future.delayed(const Duration(milliseconds: 150), () {
              final key = _messageKeys[messageId];
              if (key?.currentContext != null) {
                Scrollable.ensureVisible(
                  key!.currentContext!,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutExpo,
                  alignment: 0.5,
                ).then((_) {
                  _isScrollingToReply = false;
                  _highlightMessage(messageId);
                });
                HapticFeedback.lightImpact();
              } else {
                _isScrollingToReply = false;
                _showNotFoundSnackbar();
              }
            });
          } else {
            if (msgs.isNotEmpty &&
                !st.isLoadingMessages &&
                attempts < maxAttempts) {
              bloc.add(LoadMessagesEvent(
                conversationId: convoId,
                pageNumber: (msgs.length ~/ 50) + 1,
                beforeMessageId: msgs.last.id,
              ));
              Future.delayed(
                  const Duration(milliseconds: 600), tryFindAfterLoad);
            } else {
              _hideLoadingIndicator();
              _isScrollingToReply = false;
              _showNotFoundSnackbar();
            }
          }
        } else {
          _hideLoadingIndicator();
          _isScrollingToReply = false;
        }
      });
    }

    tryFindAfterLoad();
  }

  /// ينفذ العملية `_showLoadingIndicator`.
  /// Runs the `_showLoadingIndicator` operation.
  void _showLoadingIndicator() {
    _loadingOverlay?.remove();
    _loadingOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 60,
        left: 0,
        right: 0,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.darkCard.withValues(alpha: 0.9),
                      AppTheme.darkCard.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryBlue.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'جاري البحث عن الرسالة...',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textWhite.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_loadingOverlay!);
  }

  /// ينفذ العملية `_hideLoadingIndicator`.
  /// Runs the `_hideLoadingIndicator` operation.
  void _hideLoadingIndicator() {
    _loadingOverlay?.remove();
    _loadingOverlay = null;
  }

  /// ينفذ العملية `_highlightMessage`.
  /// Runs the `_highlightMessage` operation.
  void _highlightMessage(String messageId) {
    final key = _messageKeys[messageId];
    if (key?.currentContext == null) return;

    final overlay = Overlay.of(context);
    final renderBox = key!.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    OverlayEntry? highlightEntry;
    highlightEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy,
        width: size.width,
        height: size.height,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.3, end: 0.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: value),
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
          onEnd: () {
            Future.delayed(const Duration(milliseconds: 100), () {
              try {
                highlightEntry?.remove();
              } catch (_) {}
            });
          },
        ),
      ),
    );

    overlay.insert(highlightEntry);
  }

  /// ينفذ العملية `_showNotFoundSnackbar`.
  /// Runs the `_showNotFoundSnackbar` operation.
  void _showNotFoundSnackbar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'لم يتم العثور على الرسالة',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.error.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// ينفذ العملية `_syncCurrentUser`.
  /// Runs the `_syncCurrentUser` operation.
  void _syncCurrentUser() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.userId;
    }
    _authSubscription = context.read<AuthBloc>().stream.listen((state) {
      if (state is AuthAuthenticated && mounted) {
        if (_currentUserId != state.user.userId) {
          setState(() {
            _currentUserId = state.user.userId;
          });
          _markMessagesAsRead();
        }
      }
    });
  }

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    final effectiveUserId = _currentUserId ?? '';
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          _buildPremiumBackground(),
          _buildFloatingParticles(),
          SafeArea(
            child: Column(
              children: [
                ChatAppBar(
                  conversation: widget.conversation,
                  currentUserId: effectiveUserId,
                  onBackPressed: () => Navigator.pop(context),
                  onInfoPressed: () => _openChatSettings(),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      _buildMessagesListWithEffects(userId: effectiveUserId),
                      if (_showScrollToBottom) _buildFloatingScrollButton(),
                    ],
                  ),
                ),
                _buildPremiumBottomSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ينفذ العملية `_buildPremiumBackground`.
  /// Runs the `_buildPremiumBackground` operation.
  Widget _buildPremiumBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([_backgroundAnimation, _glowAnimation]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground.withValues(alpha: 0.95),
                AppTheme.darkSurface.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _PremiumBackgroundPainter(
              animation: _backgroundAnimation.value,
              glowIntensity: _glowAnimation.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  /// ينفذ العملية `_buildFloatingParticles`.
  /// Runs the `_buildFloatingParticles` operation.
  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            animation: _particleController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  /// ينفذ العملية `_buildMessagesListWithEffects`.
  /// Runs the `_buildMessagesListWithEffects` operation.
  Widget _buildMessagesListWithEffects({required String userId}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is! ChatLoaded) {
              return _buildPremiumLoadingState();
            }

            final typingUsers =
                state.typingUsers[widget.conversation.id] ?? const <String>[];

            final List<Message> messages =
                (state.messages[widget.conversation.id] ?? []).cast<Message>();

            if (messages.isEmpty) {
              return _buildPremiumEmptyState();
            }

            for (final message in messages) {
              _messageKeys[message.id] ??= GlobalKey();
            }

            return _buildMessagesList(state, messages, typingUsers,
                userId: userId);
          },
        ),
      ),
    );
  }

  /// ينفذ العملية `_buildPremiumLoadingState`.
  /// Runs the `_buildPremiumLoadingState` operation.
  Widget _buildPremiumLoadingState() {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: 8,
      itemBuilder: (context, index) {
        final isMe = index % 2 == 0;
        return TweenAnimationBuilder<double>(
          key: ValueKey('skeleton_$index'),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(
                      left: isMe ? MediaQuery.of(context).size.width * 0.2 : 8,
                      right: isMe ? 8 : MediaQuery.of(context).size.width * 0.2,
                      top: 8,
                      bottom: 4,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              height: 60 + (index % 3) * 15,
                              width: MediaQuery.of(context).size.width *
                                  (0.5 + (index % 3) * 0.1),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.darkCard.withValues(alpha: 0.4),
                                    AppTheme.darkCard.withValues(alpha: 0.25),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.darkBorder
                                      .withValues(alpha: 0.08),
                                  width: 0.5,
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _backgroundController,
                              builder: (context, child) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withValues(alpha: 0.0),
                                        Colors.white.withValues(alpha: 0.05),
                                        Colors.white.withValues(alpha: 0.0),
                                      ],
                                      stops: [
                                        (_backgroundController.value - 0.3)
                                            .clamp(0.0, 1.0),
                                        _backgroundController.value
                                            .clamp(0.0, 1.0),
                                        (_backgroundController.value + 0.3)
                                            .clamp(0.0, 1.0),
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
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ينفذ العملية `_buildPremiumEmptyState`.
  /// Runs the `_buildPremiumEmptyState` operation.
  Widget _buildPremiumEmptyState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.darkCard.withValues(alpha: 0.4),
                        AppTheme.darkCard.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.08),
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
                              AppTheme.primaryBlue.withValues(alpha: 0.15),
                              AppTheme.primaryPurple.withValues(alpha: 0.08),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.waving_hand_rounded,
                          size: 28,
                          color: AppTheme.primaryBlue.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            AppTheme.primaryBlue.withValues(alpha: 0.8),
                            AppTheme.primaryPurple.withValues(alpha: 0.8),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'ابدأ المحادثة',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'اكتب رسالتك الأولى للبدء',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.textMuted.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// ينفذ العملية `_buildMessagesList`.
  /// Runs the `_buildMessagesList` operation.
  Widget _buildMessagesList(
      ChatLoaded state, List<Message> messages, List<String> typingUsers,
      {required String userId}) {
    final uploadingImages =
        state.uploadingImages[widget.conversation.id] ?? const [];
    final hasUploadingImages = uploadingImages.isNotEmpty;
    final hasUploadingAttachment =
        state.uploadingAttachment != null && state.uploadProgress != null;

    final baseExtra = (typingUsers.isNotEmpty ? 1 : 0) +
        (hasUploadingImages ? 1 : 0) +
        (hasUploadingAttachment ? 1 : 0);

    return Stack(
      children: [
        ListView.builder(
          key: _listKey,
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          physics: const BouncingScrollPhysics(),
          itemCount: messages.length + baseExtra,
          itemBuilder: (context, index) {
            int cursor = 0;
            if (typingUsers.isNotEmpty && index == cursor) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TypingIndicatorWidget(
                  typingUserIds: typingUsers,
                  conversation: widget.conversation,
                ),
              );
            }

            cursor += typingUsers.isNotEmpty ? 1 : 0;

            if (hasUploadingImages && index == cursor) {
              final synthetic = Message(
                id: 'uploading_${widget.conversation.id}',
                conversationId: widget.conversation.id,
                senderId: userId.isNotEmpty ? userId : 'current_user',
                messageType: 'image',
                content: null,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                status: 'sending',
              );
              return Align(
                alignment: Alignment.centerRight,
                child: ImageMessageBubble(
                  message: synthetic,
                  isMe: true,
                  uploadingImages: uploadingImages,
                ),
              );
            }

            cursor += hasUploadingImages ? 1 : 0;

            if (hasUploadingAttachment && index == cursor) {
              // فقّاعة مؤقتة لمرفق واحد (صوت/فيديو/مستند) قيد الرفع
              final att = state.uploadingAttachment!;
              final progress =
                  (state.uploadProgress ?? 0).clamp(0, 1).toDouble();
              final synthetic = Message(
                id: 'uploading_single_${widget.conversation.id}',
                conversationId: widget.conversation.id,
                senderId: userId.isNotEmpty ? userId : 'current_user',
                messageType: att.isAudio
                    ? 'audio'
                    : (att.isVideo ? 'video' : 'document'),
                content: null,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                status: 'sending',
                attachments: [
                  Attachment(
                    id: att.id,
                    conversationId: att.conversationId,
                    fileName: att.fileName,
                    contentType: att.contentType,
                    fileSize: att.fileSize,
                    filePath: att.filePath,
                    fileUrl: att.fileUrl,
                    url: att.url,
                    uploadedBy: att.uploadedBy,
                    createdAt: att.createdAt,
                    thumbnailUrl: att.thumbnailUrl,
                    metadata: att.metadata,
                    duration: att.duration,
                    downloadProgress: progress,
                  ),
                ],
              );

              return Align(
                alignment: Alignment.centerRight,
                child: MessageBubbleWidget(
                  message: synthetic,
                  isMe: true,
                ),
              );
            }

            cursor += hasUploadingAttachment ? 1 : 0;

            final messageIndex = index - cursor;
            final message = messages[messageIndex];
            final previousMessage = messageIndex < messages.length - 1
                ? messages[messageIndex + 1]
                : null;
            final nextMessage =
                messageIndex > 0 ? messages[messageIndex - 1] : null;

            final showDateSeparator = previousMessage == null ||
                !_isSameDay(message.createdAt, previousMessage.createdAt);
            final isMe = message.senderId == userId && userId.isNotEmpty;

            return Column(
              key: _messageKeys[message.id],
              children: [
                if (showDateSeparator)
                  _buildPremiumDateSeparator(message.createdAt),
                Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: _buildMessageBubbleFor(
                      message, isMe, previousMessage, nextMessage, userId),
                ),
              ],
            );
          },
        ),
        if (state.isLoadingMessages)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(8),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue.withValues(alpha: 0.8),
                        AppTheme.primaryPurple.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: const LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: Colors.transparent,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.transparent),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // FIX: تمرير onReplyTap بشكل صحيح لكلا النوعين من الرسائل
  /// ينفذ العملية `_buildMessageBubbleFor`.
  /// Runs the `_buildMessageBubbleFor` operation.
  Widget _buildMessageBubbleFor(
    Message message,
    bool isMe,
    Message? previousMessage,
    Message? nextMessage,
    String userId,
  ) {
    final isImageMessage = message.messageType == 'image' ||
        (message.attachments.isNotEmpty &&
            message.attachments.any((a) => a.isImage));

    if (isImageMessage) {
      return ImageMessageBubble(
        message: message,
        isMe: isMe,
        onReply: (attachment) {
          setState(() {
            _replyToMessageId = message.id;
            _replyToAttachment = attachment;
          });
          _messageFocusNode.requestFocus();
        },
        onReaction: (reactionType) =>
            _addReaction(message, reactionType, userId),
        // FIX: تمرير onReplyTap للصور
        onReplyTap: message.replyToMessageId != null
            ? () {
                _scrollToMessage(message.replyToMessageId!);
              }
            : null,
      );
    }

    return MessageBubbleWidget(
      message: message,
      isMe: isMe,
      previousMessage: previousMessage,
      nextMessage: nextMessage,
      onReply: () => _setReplyTo(message),
      onEdit: isMe ? () => _startEditingMessage(message) : null,
      onDelete: isMe ? () => _deleteMessage(message) : null,
      onReaction: (reactionType) => _addReaction(message, reactionType, userId),
      // FIX: تمرير onReplyTap للرسائل النصية
      onReplyTap: message.replyToMessageId != null
          ? () {
              _scrollToMessage(message.replyToMessageId!);
            }
          : null,
    );
  }

  /// ينفذ العملية `_buildPremiumDateSeparator`.
  /// Runs the `_buildPremiumDateSeparator` operation.
  Widget _buildPremiumDateSeparator(DateTime date) {
    final text = _getDateSeparatorText(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.darkBorder.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.darkCard.withValues(alpha: 0.3),
                        AppTheme.darkCard.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppTheme.darkBorder.withValues(alpha: 0.08),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    text,
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted.withValues(alpha: 0.5),
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.darkBorder.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ينفذ العملية `_buildFloatingScrollButton`.
  /// Runs the `_buildFloatingScrollButton` operation.
  Widget _buildFloatingScrollButton() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: AnimatedScale(
        scale: _showScrollToBottom ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: GestureDetector(
              onTap: _scrollToBottom,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.darkCard.withValues(alpha: 0.5),
                      AppTheme.darkCard.withValues(alpha: 0.3),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.textWhite.withValues(alpha: 0.6),
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ينفذ العملية `_buildPremiumBottomSection`.
  /// Runs the `_buildPremiumBottomSection` operation.
  Widget _buildPremiumBottomSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_replyToMessageId != null) _buildPremiumReplySection(),
        if (_editingMessage != null) _buildPremiumEditSection(),
        MessageInputWidget(
          controller: _messageController,
          focusNode: _messageFocusNode,
          conversationId: widget.conversation.id,
          replyToMessageId: _replyToMessageId,
          editingMessage: _editingMessage,
          onSend: _sendMessage,
          onAttachment: _pickAttachment,
          onLocation: _shareLocation,
          onCancelReply: () {
            setState(() {
              _replyToMessageId = null;
              _replyToAttachment = null;
            });
          },
          onCancelEdit: () {
            setState(() {
              _editingMessage = null;
              _messageController.clear();
            });
          },
        ),
      ],
    );
  }

  /// ينفذ العملية `_buildPremiumReplySection`.
  /// Runs the `_buildPremiumReplySection` operation.
  Widget _buildPremiumReplySection() {
    final state = context.read<ChatBloc>().state;
    if (state is! ChatLoaded) return const SizedBox.shrink();

    final List<Message> messages =
        (state.messages[widget.conversation.id] ?? []).cast<Message>();

    Message? replyMessage;
    if (_replyToMessageId != null) {
      for (final m in messages) {
        if (m.id == _replyToMessageId) {
          replyMessage = m;
          break;
        }
      }
    }

    if (replyMessage == null) {
      return const SizedBox.shrink();
    }

    final currentUserId = _currentUserId;
    final displayName =
        currentUserId != null && replyMessage.senderId == currentUserId
            ? 'أنت'
            : 'مستخدم';

    return GestureDetector(
      onTap: () {
        _scrollToMessage(replyMessage!.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.06),
                    AppTheme.primaryPurple.withValues(alpha: 0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.8),
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          replyMessage.content ?? '[محتوى غير نصي]',
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.textWhite.withValues(alpha: 0.7),
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _replyToMessageId = null;
                        _replyToAttachment = null;
                      });
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.darkCard.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppTheme.textWhite.withValues(alpha: 0.6),
                      ),
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

  /// ينفذ العملية `_buildPremiumEditSection`.
  /// Runs the `_buildPremiumEditSection` operation.
  Widget _buildPremiumEditSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.warning.withValues(alpha: 0.06),
                  AppTheme.warning.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(
                  color: AppTheme.warning.withValues(alpha: 0.8),
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تعديل الرسالة',
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.warning.withValues(alpha: 0.7),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _editingMessage?.content ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppTheme.textWhite.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _editingMessage = null;
                      _messageController.clear();
                    });
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: AppTheme.textMuted.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ينفذ العملية `_sendMessage`.
  /// Runs the `_sendMessage` operation.
  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;

    HapticFeedback.lightImpact();

    if (_editingMessage != null) {
      context.read<ChatBloc>().add(
            EditMessageEvent(
              messageId: _editingMessage!.id,
              content: content,
            ),
          );
      setState(() {
        _editingMessage = null;
      });
    } else {
      String messageContent = content;
      if (_replyToAttachment != null && _replyToMessageId != null) {
        messageContent = '::attref=${_replyToAttachment!.id}::$content';
      }

      context.read<ChatBloc>().add(
            SendMessageEvent(
              conversationId: widget.conversation.id,
              messageType: 'text',
              content: messageContent,
              replyToMessageId: _replyToMessageId,
              currentUserId: _currentUserId,
            ),
          );
      setState(() {
        _replyToMessageId = null;
        _replyToAttachment = null;
      });
    }

    _messageController.clear();
    _scrollToBottom();
  }

  /// ينفذ العملية `_pickAttachment`.
  /// Runs the `_pickAttachment` operation.
  void _pickAttachment() {
    HapticFeedback.lightImpact();
  }

  /// ينفذ العملية `_shareLocation`.
  /// Runs the `_shareLocation` operation.
  void _shareLocation() {
    HapticFeedback.lightImpact();
  }

  /// ينفذ العملية `_setReplyTo`.
  /// Runs the `_setReplyTo` operation.
  void _setReplyTo(Message message) {
    setState(() {
      _replyToMessageId = message.id;
      _replyToAttachment = null;
    });
    _messageFocusNode.requestFocus();
  }

  /// ينفذ العملية `_startEditingMessage`.
  /// Runs the `_startEditingMessage` operation.
  void _startEditingMessage(Message message) {
    setState(() {
      _editingMessage = message;
      _messageController.text = message.content ?? '';
    });
    _messageFocusNode.requestFocus();
  }

  /// ينفذ العملية `_deleteMessage`.
  /// Runs the `_deleteMessage` operation.
  void _deleteMessage(Message message) {
    HapticFeedback.lightImpact();
    showDialog(
      fullscreenDialog: true,
      context: context,
      barrierColor: Colors.black38,
      builder: (context) => _PremiumDeleteDialog(
        onConfirm: () {
          context.read<ChatBloc>().add(
                DeleteMessageEvent(messageId: message.id),
              );
          Navigator.pop(context);
        },
      ),
    );
  }

  /// ينفذ العملية `_addReaction`.
  /// Runs the `_addReaction` operation.
  void _addReaction(Message message, String reactionType, String userId) {
    HapticFeedback.lightImpact();

    final hasReaction = message.reactions.any(
      (r) => r.userId == userId && r.reactionType == reactionType,
    );

    if (hasReaction) {
      context.read<ChatBloc>().add(
            RemoveReactionEvent(
              messageId: message.id,
              reactionType: reactionType,
              currentUserId: userId,
            ),
          );
    } else {
      context.read<ChatBloc>().add(
            AddReactionEvent(
              messageId: message.id,
              reactionType: reactionType,
              currentUserId: userId,
            ),
          );
    }
  }

  /// ينفذ العملية `_scrollToBottom`.
  /// Runs the `_scrollToBottom` operation.
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutExpo,
      );
    }
  }

  /// ينفذ العملية `_openChatSettings`.
  /// Runs the `_openChatSettings` operation.
  void _openChatSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatSettingsPage(
          conversation: widget.conversation,
        ),
      ),
    );
  }

  /// ينفذ العملية `_isSameDay`.
  /// Runs the `_isSameDay` operation.
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// ينفذ العملية `_getDateSeparatorText`.
  /// Runs the `_getDateSeparatorText` operation.
  String _getDateSeparatorText(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'اليوم';
    } else if (messageDate == yesterday) {
      return 'أمس';
    } else if (now.difference(date).inDays < 7) {
      final days = [
        'الأحد',
        'الإثنين',
        'الثلاثاء',
        'الأربعاء',
        'الخميس',
        'الجمعة',
        'السبت'
      ];
      return days[date.weekday % 7];
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// يعرّف الكلاس `_PremiumDeleteDialog`.
/// Describes the `_PremiumDeleteDialog` class.
class _PremiumDeleteDialog extends StatelessWidget {
  /// Holds the `onConfirm` value.
  /// العربية: يخزن القيمة `onConfirm`.
  final VoidCallback onConfirm;

  /// ينشئ مثيلاً من `_PremiumDeleteDialog`.
  /// Builds an instance of `_PremiumDeleteDialog`.
  const _PremiumDeleteDialog({required this.onConfirm});

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.darkCard.withValues(alpha: 0.8),
                    AppTheme.darkCard.withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.error.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.error.withValues(alpha: 0.12),
                          AppTheme.error.withValues(alpha: 0.06),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: AppTheme.error.withValues(alpha: 0.8),
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'حذف الرسالة',
                    style: AppTextStyles.heading3.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'هل أنت متأكد من حذف هذه الرسالة؟',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textMuted.withValues(alpha: 0.6),
                      fontSize: 11,
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
                                color:
                                    AppTheme.darkBorder.withValues(alpha: 0.15),
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'إلغاء',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 12,
                                color:
                                    AppTheme.textWhite.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: onConfirm,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.error.withValues(alpha: 0.7),
                                  AppTheme.error.withValues(alpha: 0.5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'حذف',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppTheme.textWhite,
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

/// يعرّف الكلاس `_ChatParticle`.
/// Describes the `_ChatParticle` class.
class _ChatParticle {
  double x = math.Random().nextDouble();
  double y = math.Random().nextDouble();
  double vx = (math.Random().nextDouble() - 0.5) * 0.0003;
  double vy = (math.Random().nextDouble() - 0.5) * 0.0003;
  double radius = math.Random().nextDouble() * 1.2 + 0.3;
  double opacity = math.Random().nextDouble() * 0.08 + 0.02;

  /// يخزن العضو `color`.
  /// Holds the `color` member.
  Color color = [
    AppTheme.primaryBlue,
    AppTheme.primaryPurple,
    AppTheme.primaryCyan,
  ][math.Random().nextInt(3)];

  /// ينفذ العملية `update`.
  /// Runs the `update` operation.
  void update() {
    x += vx;
    y += vy;
    if (x < 0 || x > 1) vx = -vx;
    if (y < 0 || y > 1) vy = -vy;
  }
}

/// يعرّف الكلاس `_PremiumBackgroundPainter`.
/// Describes the `_PremiumBackgroundPainter` class.
class _PremiumBackgroundPainter extends CustomPainter {
  /// Holds the `animation` value.
  /// العربية: يخزن القيمة `animation`.
  final double animation;

  /// يخزن العضو `glowIntensity`.
  /// Holds the `glowIntensity` member.
  final double glowIntensity;

  /// ينشئ مثيلاً من `_PremiumBackgroundPainter`.
  /// Builds an instance of `_PremiumBackgroundPainter`.
  _PremiumBackgroundPainter({
    required this.animation,
    required this.glowIntensity,
  });

  /// ينفذ العملية `paint`.
  /// Runs the `paint` operation.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.2
      ..color = AppTheme.primaryBlue.withValues(alpha: 0.02 * glowIntensity);

    const spacing = 30.0;
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
  }

  /// ينفذ العملية `shouldRepaint`.
  /// Runs the `shouldRepaint` operation.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// يعرّف الكلاس `_ParticlePainter`.
/// Describes the `_ParticlePainter` class.
class _ParticlePainter extends CustomPainter {
  /// Holds the `particles` value.
  /// العربية: يخزن القيمة `particles`.
  final List<_ChatParticle> particles;

  /// يخزن العضو `animation`.
  /// Holds the `animation` member.
  final double animation;

  /// ينشئ مثيلاً من `_ParticlePainter`.
  /// Builds an instance of `_ParticlePainter`.
  _ParticlePainter({
    required this.particles,
    required this.animation,
  });

  /// ينفذ العملية `paint`.
  /// Runs the `paint` operation.
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update();

      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.radius,
        paint,
      );
    }
  }

  /// ينفذ العملية `shouldRepaint`.
  /// Runs the `shouldRepaint` operation.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
