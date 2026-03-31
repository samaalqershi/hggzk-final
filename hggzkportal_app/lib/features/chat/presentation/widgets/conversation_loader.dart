import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/chat_bloc.dart';
import '../pages/chat_page.dart';

/// Temporary screen that resolves a conversation id into a loaded chat page.
/// شاشة مؤقتة تحوّل معرّف المحادثة إلى صفحة دردشة محمّلة.
class ConversationLoader extends StatefulWidget {
  /// Identifies the conversation that should be opened.
  /// يحدد المحادثة التي يجب فتحها.
  final String conversationId;

  /// Starts the lookup flow for the requested conversation.
  /// يبدأ مسار العثور على المحادثة المطلوبة.
  const ConversationLoader({required this.conversationId});

  /// Sets up the state that performs the lookup and redirect.
  /// يهيئ الحالة التي تنفذ البحث ثم التحويل.
  @override
  State<ConversationLoader> createState() => ConversationLoaderState();
}

/// Resolves the conversation from chat bloc state and redirects once ready.
/// يحلّ المحادثة من حالة الـ bloc ثم يحول المستخدم عندما تصبح جاهزة.
class ConversationLoaderState extends State<ConversationLoader> {
  /// Triggers the lookup as soon as the widget is mounted.
  /// يطلق البحث فور تركيب العنصر.
  @override
  void initState() {
    super.initState();
    _loadConversation();
  }

  /// Looks up the target conversation in the current chat state and falls
  /// back to a reload if the inbox has not finished loading yet.
  /// يبحث عن المحادثة المطلوبة داخل حالة الدردشة الحالية، ويطلب إعادة
  /// التحميل إذا لم تكن القائمة قد اكتملت بعد.
  void _loadConversation() {
    // حمل المحادثة من ChatBloc
    final chatBloc = context.read<ChatBloc>();
    final state = chatBloc.state;

    if (state is ChatLoaded) {
      final conversation = state.conversations.firstWhere(
        (c) => c.id == widget.conversationId,
        orElse: () => throw Exception(
          context.l10n.get('chat.system.conversationNotFound'),
        ),
      );

      // انتقل للصفحة مع المحادثة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ChatPage(conversation: conversation),
          ),
        );
      });
    } else {
      // إذا لم تكن المحادثات محملة، حملها أولاً
      chatBloc.add(const LoadConversationsEvent());
    }
  }

  /// Shows a short loading view while the redirect target is being resolved.
  /// يعرض شاشة تحميل قصيرة أثناء تجهيز التحويل.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr(
                'chat.loader.loadingConversation',
              ),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
