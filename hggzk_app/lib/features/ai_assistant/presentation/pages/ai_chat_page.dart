import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';
import 'package:go_router/go_router.dart';

import 'package:hggzk/core/network/api_client.dart';
import 'package:hggzk/core/network/api_exceptions.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import 'package:hggzk/core/theme/app_text_styles.dart';
import 'package:hggzk/core/theme/app_theme.dart';
import 'package:hggzk/features/ai_assistant/data/models/ai_assistant_models.dart';
import 'package:hggzk/features/ai_assistant/data/services/ai_assistant_remote_service.dart';
import 'package:hggzk/app/dependency_injection/injection_container.dart';

/// Describes the `AiChatPage` page widget.
/// العربية: يمثل عنصر الصفحة `AiChatPage`.
class AiChatPage extends StatefulWidget {
  /// Builds a new `AiChatPage` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `AiChatPage`.
  const AiChatPage({super.key});

  /// Builds the state object for this widget.
  /// العربية: ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

/// Describes the state for `AiChatPageState`.
/// العربية: يمثل الحالة الخاصة بـ `AiChatPageState`.
class _AiChatPageState extends State<AiChatPage> with TickerProviderStateMixin {
  /// Keeps the `headerAnimationController` value.
  /// العربية: يخزن القيمة `headerAnimationController`.
  late final AnimationController _headerAnimationController;

  /// Keeps the `headerAnimation` value.
  /// العربية: يخزن القيمة `headerAnimation`.
  late final Animation<double> _headerAnimation;

  final ChatMessagesController _controller = ChatMessagesController();

  /// Keeps the `assistantService` value.
  /// العربية: يخزن القيمة `assistantService`.
  late final AiAssistantRemoteService _assistantService;

  ChatUser get _currentUser => ChatUser(
        id: 'current_user',
        firstName: context.tr('ai_chat.currentUserName'),
      );

  ChatUser get _aiUser => ChatUser(
        id: 'ai_assistant',
        firstName: context.tr('ai_chat.assistantName'),
      );

  /// Keeps the `messages` value.
  /// العربية: يخزن القيمة `messages`.
  final List<ChatMessage> _messages = <ChatMessage>[];
  final List<AiAssistantHistoryMessage> _history =
      <AiAssistantHistoryMessage>[];

  /// Indicates whether `isLoading` is enabled.
  /// العربية: يحدد ما إذا كانت القيمة `isLoading` مفعلة.
  bool _isLoading = true;

  /// Indicates whether `isTyping` is enabled.
  /// العربية: يحدد ما إذا كانت القيمة `isTyping` مفعلة.
  bool _isTyping = false;

  /// Indicates whether `isResetting` is enabled.
  /// العربية: يحدد ما إذا كانت القيمة `isResetting` مفعلة.
  bool _isResetting = false;

  /// Keeps the `error` value.
  /// العربية: يخزن القيمة `error`.
  String? _error;

  /// Initializes the state for this widget.
  /// العربية: يهيئ الحالة الخاصة بهذا العنصر.
  @override
  void initState() {
    super.initState();
    _assistantService = AiAssistantRemoteService(apiClient: sl<ApiClient>());
    _setupAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeChat();
    });
  }

  /// Sets the up animations.
  /// العربية: يضبط up animations.
  void _setupAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOut,
    );
    _headerAnimationController.forward();
  }

  /// Initializes the chat.
  /// العربية: يهيئ chat.
  Future<void> _initializeChat() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future<void>.delayed(const Duration(milliseconds: 200));

      if (_messages.isEmpty) {
        final welcomeMessage = ChatMessage(
          text: context.tr('ai_chat.initialWelcomeMessage'),
          user: _aiUser,
          createdAt: DateTime.now(),
        );

        _messages.insert(0, welcomeMessage);
        _controller.addMessage(welcomeMessage);
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = context.tr('ai_chat.initFailed');
      });
    }
  }

  /// Releases the resources used by this instance.
  /// العربية: يحرر الموارد المستخدمة بواسطة هذا الكائن.
  @override
  void dispose() {
    _headerAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Processes `appendMessage`.
  /// العربية: يعالج `appendMessage`.
  void _appendMessage(ChatMessage message, {bool addToHistory = true}) {
    _messages.insert(0, message);
    _controller.addMessage(message);

    if (!addToHistory) return;

    final role = message.user.id == _currentUser.id ? 'user' : 'assistant';
    _history.add(AiAssistantHistoryMessage(role: role, content: message.text));

    if (_history.length > 30) {
      _history.removeRange(0, _history.length - 30);
    }
  }

  /// Sends the message.
  /// العربية: يرسل message.
  Future<void> _sendMessage(ChatMessage message) async {
    if (_isLoading || _isTyping || _isResetting) return;

    final text = message.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();

    final userMessage = ChatMessage(
      text: text,
      user: _currentUser,
      createdAt: DateTime.now(),
    );
    _appendMessage(userMessage);

    setState(() {
      _isTyping = true;
      _error = null;
    });

    try {
      final requestHistory = List<AiAssistantHistoryMessage>.from(_history);
      if (requestHistory.isNotEmpty) {
        requestHistory.removeLast();
      }

      final response = await _assistantService.sendMessage(
        message: text,
        history: requestHistory,
      );

      final reply = response.reply.trim().isNotEmpty
          ? response.reply.trim()
          : context.tr('ai_chat.requestHandled');

      final aiMessage = _buildAssistantMessage(
        reply: reply,
        cards: response.cards,
      );
      _appendMessage(aiMessage);
    } catch (e) {
      final fallback = e is ApiException
          ? (e.message.isNotEmpty
              ? e.message
              : context.tr('ai_chat.assistantUnavailable'))
          : context.tr('ai_chat.messageProcessingError');

      final errorMessage = ChatMessage(
        text: fallback,
        user: _aiUser,
        createdAt: DateTime.now(),
      );
      _appendMessage(errorMessage, addToHistory: false);
    } finally {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
    }
  }

  /// Builds the assistant message.
  /// العربية: يبني assistant message.
  ChatMessage _buildAssistantMessage({
    required String reply,
    required List<AiAssistantResultCard> cards,
  }) {
    final cleanedCards = cards
        .where((card) => card.propertyId.trim().isNotEmpty)
        .take(8)
        .toList();

    if (cleanedCards.isEmpty) {
      return ChatMessage(
        text: reply,
        user: _aiUser,
        createdAt: DateTime.now(),
      );
    }

    return ChatMessage(
      text: reply,
      user: _aiUser,
      createdAt: DateTime.now(),
      customBuilder: (BuildContext context, ChatMessage message) {
        return _buildAssistantCardsBubble(message, cleanedCards);
      },
    );
  }

  /// Processes `copyAssistantMessage`.
  /// العربية: يعالج `copyAssistantMessage`.
  Future<void> _copyAssistantMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: cleanText));
    HapticFeedback.selectionClick();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr('ai_chat.copySuccess'),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  /// Builds the assistant cards bubble.
  /// العربية: يبني assistant cards bubble.
  Widget _buildAssistantCardsBubble(
    ChatMessage message,
    List<AiAssistantResultCard> cards,
  ) {
    final maxWidth = math.min(MediaQuery.of(context).size.width * 0.9, 560.0);

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: GestureDetector(
          onLongPress: () => _copyAssistantMessage(message.text),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.22),
                width: 1,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  message.text,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 208,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: cards.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final card = cards[index];
                      return _buildResultCard(card);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the result card.
  /// العربية: يبني result card.
  Widget _buildResultCard(AiAssistantResultCard card) {
    if (card.type == 'review' || card.type == 'review_summary') {
      return _buildReviewResultCard(card);
    }

    return InkWell(
      onTap: () => _openResultCard(card),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: AppTheme.darkBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.22),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: card.imageUrl != null && card.imageUrl!.trim().isNotEmpty
                    ? Image.network(
                        card.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildCardPlaceholder(),
                      )
                    : _buildCardPlaceholder(),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (card.badge != null && card.badge!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          card.badge!,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    Text(
                      card.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (card.subtitle.isNotEmpty)
                      Text(
                        card.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        Icon(Icons.location_on_outlined,
                            size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            card.city.isEmpty
                                ? context.tr('ai_chat.cityUnknown')
                                : card.city,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppTheme.textLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatCardPrice(context, card),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.success,
                        fontWeight: FontWeight.w700,
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

  /// Builds the review result card.
  /// العربية: يبني review result card.
  Widget _buildReviewResultCard(AiAssistantResultCard card) {
    final averageRating = _metaNumber(card, 'average_rating');
    final totalReviews = _metaInt(card, 'total_reviews');
    final reviewsWithImages = _metaInt(card, 'reviews_with_images');
    final recommendedCount = _metaInt(card, 'recommended_count');
    final createdAt = _metaString(card, 'created_at');
    final highlightComment =
        _metaString(card, 'highlight_comment') ?? _metaString(card, 'comment');
    final distributionText = _buildDistributionText(card);

    return InkWell(
      onTap: () => _openResultCard(card),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.darkBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.22),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (card.badge != null && card.badge!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  card.badge!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Text(
              card.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  averageRating != null
                      ? averageRating.toStringAsFixed(1)
                      : card.subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (totalReviews != null) ...<Widget>[
                  const SizedBox(width: 6),
                  Text(
                    '($totalReviews)',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                if (recommendedCount != null)
                  _buildReviewChip(context
                      .tr('ai_chat.recommendedCount')
                      .replaceFirst('{count}', '$recommendedCount')),
                if (reviewsWithImages != null)
                  _buildReviewChip(context
                      .tr('ai_chat.withImages')
                      .replaceFirst('{count}', '$reviewsWithImages')),
                if (createdAt != null && createdAt.isNotEmpty)
                  _buildReviewChip(createdAt),
              ],
            ),
            if (distributionText.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                distributionText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
            if (highlightComment != null &&
                highlightComment.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                highlightComment,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppTheme.textLight,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the review chip.
  /// العربية: يبني review chip.
  Widget _buildReviewChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppTheme.textLight,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Processes `metaNumber`.
  /// العربية: يعالج `metaNumber`.
  double? _metaNumber(AiAssistantResultCard card, String key) {
    final value = card.metadata?[key];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  /// Processes `metaInt`.
  /// العربية: يعالج `metaInt`.
  int? _metaInt(AiAssistantResultCard card, String key) {
    final value = card.metadata?[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  /// Processes `metaString`.
  /// العربية: يعالج `metaString`.
  String? _metaString(AiAssistantResultCard card, String key) {
    final value = card.metadata?[key];
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') {
      return null;
    }
    return text;
  }

  /// Builds the distribution text.
  /// العربية: يبني distribution text.
  String _buildDistributionText(AiAssistantResultCard card) {
    final raw = card.metadata?['rating_distribution'];
    if (raw is! Map) {
      return '';
    }

    final mapped = raw
        .map((key, value) => MapEntry(key.toString(), value))
        .entries
        .map((entry) => MapEntry(
              int.tryParse(entry.key) ?? 0,
              entry.value is num
                  ? entry.value.toInt()
                  : int.tryParse(entry.value.toString()) ?? 0,
            ))
        .where((entry) => entry.key > 0 && entry.value > 0)
        .toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return mapped.take(3).map((e) => '${e.key}★ ${e.value}').join(' • ');
  }

  /// Builds the card placeholder.
  /// العربية: يبني card placeholder.
  Widget _buildCardPlaceholder() {
    return Container(
      width: double.infinity,
      color: AppTheme.primaryBlue.withOpacity(0.1),
      child: Icon(
        Icons.image_outlined,
        size: 34,
        color: AppTheme.primaryBlue.withOpacity(0.55),
      ),
    );
  }

  /// Formats the card price.
  /// العربية: ينسق card price.
  String _formatCardPrice(BuildContext context, AiAssistantResultCard card) {
    if (card.price == null) {
      return context.tr('ai_chat.priceOnRequest');
    }

    final currency = (card.currency ?? '').trim();
    final value = card.price!;
    final priceText = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);

    return currency.isEmpty ? priceText : '$priceText $currency';
  }

  /// Opens the result card.
  /// العربية: يفتح result card.
  void _openResultCard(AiAssistantResultCard card) {
    final propertyId = card.propertyId.trim();
    if (propertyId.isEmpty) {
      return;
    }

    final extra = card.unitId != null && card.unitId!.trim().isNotEmpty
        ? <String, dynamic>{'unitId': card.unitId!.trim()}
        : null;

    context.push('/property/$propertyId', extra: extra);
  }

  /// Processes `clearChat`.
  /// العربية: يعالج `clearChat`.
  void _clearChat() {
    _messages.clear();
    _history.clear();
    _controller.clearMessages();
    _initializeChat();
  }

  /// Processes `resetConversation`.
  /// العربية: يعالج `resetConversation`.
  Future<bool> _resetConversation() async {
    if (_isResetting) return false;

    setState(() {
      _isResetting = true;
      _error = null;
    });

    try {
      await _assistantService.resetConversation();
      _clearChat();

      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('ai_chat.newConversationStarted')),
          backgroundColor: AppTheme.success,
        ),
      );
      return true;
    } catch (e) {
      if (!mounted) return false;

      final message = e is ApiException
          ? (e.message.isNotEmpty
              ? e.message
              : context.tr('ai_chat.newConversationFailed'))
          : context.tr('ai_chat.newConversationFailed');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.error,
        ),
      );
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isResetting = false;
        });
      }
    }
  }

  /// Builds the widget tree for this component.
  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AppTheme.primaryBlue.withOpacity(0.03),
              AppTheme.darkBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingView()
                    : _error != null
                        ? _buildErrorView(_error!)
                        : _buildChatView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header.
  /// العربية: يبني header.
  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withOpacity(0.95),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              color: AppTheme.textWhite,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    AppTheme.primaryBlue,
                    AppTheme.primaryPurple,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    context.tr('ai_chat.title'),
                    style: AppTextStyles.h5.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textWhite,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.success,
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AppTheme.success.withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.tr('ai_chat.headerConnection'),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: _isResetting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppTheme.textWhite),
                      ),
                    )
                  : const Icon(Icons.restart_alt_rounded),
              color: AppTheme.error,
              tooltip: context.tr('ai_chat.startNew'),
              onPressed: (_isResetting || _isTyping || _isLoading)
                  ? null
                  : _showClearConfirmation,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the loading view.
  /// العربية: يبني loading view.
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  AppTheme.primaryBlue.withOpacity(0.15),
                  AppTheme.primaryBlue.withOpacity(0.07),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.tr('ai_chat.loading'),
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppTheme.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the error view.
  /// العربية: يبني error view.
  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AppTheme.error,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.tr('ai_chat.errorTitle'),
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeChat,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.tr('ai_chat.retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the chat view.
  /// العربية: يبني chat view.
  Widget _buildChatView() {
    return SelectionArea(
      child: AiChatWidget(
        currentUser: _currentUser,
        aiUser: _aiUser,
        controller: _controller,
        onSendMessage: _sendMessage,
        loadingConfig: LoadingConfig(
          isLoading: _isTyping,
          showCenteredIndicator: false,
        ),
        inputOptions: InputOptions.minimal(
          hintText: context.tr('ai_chat.inputHint'),
          textColor: AppTheme.textWhite,
          hintColor: AppTheme.textMuted,
          backgroundColor: AppTheme.darkCard,
          borderRadius: 24,
          autofocus: false,
        ),
        welcomeMessageConfig: WelcomeMessageConfig(
          title: context.tr('ai_chat.welcomeTitle'),
          questionsSectionTitle: context.tr('ai_chat.welcomeSubtitle'),
        ),
        exampleQuestions: <ExampleQuestion>[
          ExampleQuestion(question: context.tr('ai_chat.example1')),
          ExampleQuestion(question: context.tr('ai_chat.example2')),
          ExampleQuestion(question: context.tr('ai_chat.example3')),
          ExampleQuestion(question: context.tr('ai_chat.example4')),
        ],
        persistentExampleQuestions: false,
        enableAnimation: true,
        enableMarkdownStreaming: true,
        streamingWordByWord: true,
        streamingDuration: const Duration(milliseconds: 30),
        messageOptions: MessageOptions(
          showTime: true,
          showUserName: false,
          bubbleStyle: BubbleStyle(
            userBubbleColor: AppTheme.primaryBlue.withOpacity(0.14),
            aiBubbleColor: AppTheme.darkCard,
            userNameColor: AppTheme.primaryBlue,
            aiNameColor: AppTheme.primaryBlue,
            bottomLeftRadius: 16,
            bottomRightRadius: 16,
            enableShadow: true,
          ),
        ),
        scrollBehaviorConfig: const ScrollBehaviorConfig(
          autoScrollBehavior: AutoScrollBehavior.onUserMessageOnly,
          scrollToFirstResponseMessage: true,
          scrollAnimationDuration: Duration(milliseconds: 300),
          scrollAnimationCurve: Curves.easeOut,
        ),
        maxWidth: 800,
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  /// Shows the clear confirmation.
  /// العربية: يعرض clear confirmation.
  void _showClearConfirmation() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: <Widget>[
              Icon(Icons.warning_rounded, color: AppTheme.warning),
              const SizedBox(width: 12),
              Text(context.tr('ai_chat.clearTitle')),
            ],
          ),
          content: Text(
            context.tr('ai_chat.clearMessage'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('ai_chat.cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final resetDone = await _resetConversation();
                if (resetDone) {
                  HapticFeedback.mediumImpact();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white,
              ),
              child: Text(context.tr('ai_chat.startNew')),
            ),
          ],
        );
      },
    );
  }
}
