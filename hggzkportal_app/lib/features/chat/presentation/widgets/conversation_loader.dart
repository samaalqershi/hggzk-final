import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hggzkportal/core/theme/app_theme.dart';
import 'package:hggzkportal/core/theme/app_text_styles.dart';
import 'package:hggzkportal/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:hggzkportal/features/chat/presentation/pages/chat_page.dart';

/// يعرّف الكلاس `ConversationLoader`.
/// Describes the `ConversationLoader` class.
class ConversationLoader extends StatefulWidget {
  /// Holds the `conversationId` value.
  /// العربية: يخزن القيمة `conversationId`.
  final String conversationId;

  /// ينشئ مثيلاً من `ConversationLoader`.
  /// Builds an instance of `ConversationLoader`.
  const ConversationLoader({super.key, required this.conversationId});

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<ConversationLoader> createState() => ConversationLoaderState();
}

/// يعرّف الكلاس `ConversationLoaderState`.
/// Describes the `ConversationLoaderState` class.
class ConversationLoaderState extends State<ConversationLoader> {
  /// ينفذ العملية `initState`.
  /// Runs the `initState` operation.
  @override
  void initState() {
    super.initState();
    _loadConversation();
  }

  /// ينفذ العملية `_loadConversation`.
  /// Runs the `_loadConversation` operation.
  void _loadConversation() {
    // حمل المحادثة من ChatBloc
    final chatBloc = context.read<ChatBloc>();
    final state = chatBloc.state;

    if (state is ChatLoaded) {
      final conversation = state.conversations.firstWhere(
        (c) => c.id == widget.conversationId,
        orElse: () => throw Exception('Conversation not found'),
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

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
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
              'جاري تحميل المحادثة...',
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
