import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

/// يعرّف الكلاس `ChatSearchBar`.
/// Describes the `ChatSearchBar` class.
class ChatSearchBar extends StatefulWidget {
  /// Receives `Function`.
  /// العربية: يعالج `Function`.
  final Function(String) onSearch;

  /// يخزن العضو `onClear`.
  /// Holds the `onClear` member.
  final VoidCallback? onClear;

  /// يخزن العضو `hintText`.
  /// Holds the `hintText` member.
  final String? hintText;

  /// يخزن العضو `autofocus`.
  /// Holds the `autofocus` member.
  final bool autofocus;

  /// ينشئ مثيلاً من `ChatSearchBar`.
  /// Builds an instance of `ChatSearchBar`.
  const ChatSearchBar({
    super.key,
    required this.onSearch,
    this.onClear,
    this.hintText,
    this.autofocus = false,
  });

  /// ينفذ العملية `createState`.
  /// Runs the `createState` operation.
  @override
  State<ChatSearchBar> createState() => _ChatSearchBarState();
}

/// يعرّف الكلاس `_ChatSearchBarState`.
/// Describes the `_ChatSearchBarState` class.
class _ChatSearchBarState extends State<ChatSearchBar>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  /// يخزن العضو `_animationController`.
  /// Holds the `_animationController` member.
  late AnimationController _animationController;

  /// يخزن العضو `_fadeAnimation`.
  /// Holds the `_fadeAnimation` member.
  late Animation<double> _fadeAnimation;

  /// يخزن العضو `_debounceTimer`.
  /// Holds the `_debounceTimer` member.
  Timer? _debounceTimer;

  /// يخزن العضو `_hasText`.
  /// Holds the `_hasText` member.
  bool _hasText = false;

  /// ينفذ العملية `initState`.
  /// Runs the `initState` operation.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );

    _controller.addListener(_onTextChanged);
    _animationController.forward();

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  /// ينفذ العملية `dispose`.
  /// Runs the `dispose` operation.
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// ينفذ العملية `_onTextChanged`.
  /// Runs the `_onTextChanged` operation.
  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onSearch(_controller.text);
    });
  }

  /// ينفذ العملية `_clearSearch`.
  /// Runs the `_clearSearch` operation.
  void _clearSearch() {
    HapticFeedback.selectionClick();
    _controller.clear();
    widget.onClear?.call();
    _focusNode.unfocus();
  }

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: 42, // Reduced from 48
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.darkCard.withValues(alpha: 0.6),
                    AppTheme.darkCard.withValues(alpha: 0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                      : AppTheme.darkBorder.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  // Search icon with animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.search_rounded,
                      color: _focusNode.hasFocus
                          ? AppTheme.primaryBlue.withValues(alpha: 0.8)
                          : AppTheme.textMuted.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ),

                  // Input field
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: widget.autofocus,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 13,
                        color: AppTheme.textWhite,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hintText ?? 'البحث...',
                        hintStyle: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.textMuted.withValues(alpha: 0.4),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: widget.onSearch,
                    ),
                  ),

                  // Clear button with animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: _hasText
                        ? GestureDetector(
                            key: const ValueKey('clear'),
                            onTap: _clearSearch,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.primaryBlue.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color:
                                    AppTheme.textMuted.withValues(alpha: 0.6),
                                size: 14,
                              ),
                            ),
                          )
                        : const SizedBox(
                            key: ValueKey('empty'),
                            width: 8,
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
}
