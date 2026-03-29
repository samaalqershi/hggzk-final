import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/message.dart';
import '../bloc/chat_bloc.dart';

/// Composer anchored at the bottom of the chat screen for text, reply, edit,
/// attachment, and voice-note flows.
/// محرر مثبت أسفل شاشة الدردشة لكتابة النص والرد والتعديل والمرفقات
/// والملاحظات الصوتية.
class MessageInputWidget extends StatefulWidget {
  /// Live draft text controlled by the parent screen.
  /// المسودة النصية الحية التي تتحكم بها الشاشة الأب.
  final TextEditingController controller;

  /// Focus node that keeps the keyboard attached to the composer.
  /// عقدة التركيز التي تبقي لوحة المفاتيح مرتبطة بالمحرر.
  final FocusNode focusNode;

  /// Conversation that receives the outgoing message.
  /// المحادثة التي تستقبل الرسالة الصادرة.
  final String conversationId;

  /// Optional message id when the composer is replying.
  /// معرّف الرسالة الاختياري عندما يكون المحرر في وضع الرد.
  final String? replyToMessageId;

  /// Original message used when the composer edits an existing message.
  /// الرسالة الأصلية المستخدمة عند تعديل رسالة موجودة.
  final Message? editingMessage;

  /// Sends the cleaned message payload to the conversation bloc.
  /// يرسل الحمولة النصية المنظفة إلى bloc المحادثة.
  final Function(String) onSend;

  /// Opens the attachment flow from the surrounding chat screen.
  /// يفتح مسار المرفقات من شاشة الدردشة المحيطة.
  final VoidCallback? onAttachment;

  /// Starts location sharing when the host screen supports it.
  /// يبدأ مشاركة الموقع عندما تدعم الشاشة المضيفة ذلك.
  final VoidCallback? onLocation;

  /// Returns the composer from reply mode back to a normal draft flow.
  /// يعيد المحرر من وضع الرد إلى كتابة عادية.
  final VoidCallback? onCancelReply;

  /// Cancels edit mode without submitting a replacement message.
  /// يلغي وضع التعديل دون إرسال رسالة بديلة.
  final VoidCallback? onCancelEdit;

  /// Builds a composer that can send text, replies, attachments, or voice
  /// notes.
  /// ينشئ محررًا قادرًا على إرسال النصوص والردود والمرفقات والرسائل الصوتية.
  const MessageInputWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.conversationId,
    this.replyToMessageId,
    this.editingMessage,
    required this.onSend,
    this.onAttachment,
    this.onLocation,
    this.onCancelReply,
    this.onCancelEdit,
  });

  /// Convenience constructor for screens that already wire bloc callbacks.
  /// مُنشئ مساعد للشاشات التي تربط callbacks الخاصة بالـ bloc مسبقًا.
  static MessageInputWidget createWithBloc({
    Key? key,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String conversationId,
    String? replyToMessageId,
    Message? editingMessage,
    required Function(String) onSend,
    VoidCallback? onAttachment,
    VoidCallback? onLocation,
    VoidCallback? onCancelReply,
    VoidCallback? onCancelEdit,
  }) {
    return MessageInputWidget(
      key: key,
      controller: controller,
      focusNode: focusNode,
      conversationId: conversationId,
      replyToMessageId: replyToMessageId,
      editingMessage: editingMessage,
      onSend: onSend,
      onAttachment: onAttachment,
      onLocation: onLocation,
      onCancelReply: onCancelReply,
      onCancelEdit: onCancelEdit,
    );
  }

  /// Creates the mutable composer state that drives animation and recording.
  /// ينشئ حالة المحرر المتغيرة التي تدير الحركة والتسجيل.
  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

/// Owns the transient UI state for the chat composer.
/// يملك الحالة المؤقتة لواجهة محرر الرسائل.
class _MessageInputWidgetState extends State<MessageInputWidget>
    with SingleTickerProviderStateMixin {
  /// Drives the send-button and recording hint transitions.
  /// يقود انتقالات زر الإرسال ومؤشر التسجيل.
  late AnimationController _animationController;

  /// Expands the send affordance when the draft contains text.
  late Animation<double> _sendButtonAnimation;

  /// Soft pulse used to show that audio capture is active.
  late Animation<double> _recordAnimation;

  final AudioRecorder _audioRecorder = AudioRecorder();

  /// Tracks whether the recorder is currently capturing audio.
  bool _isRecording = false;

  /// Controls the visibility of the inline attachment menu.
  bool _showAttachmentOptions = false;

  /// Temporary path for the currently recorded audio file.
  String _recordingPath = '';

  /// Measures the live recording length shown in the composer.
  Duration _recordingDuration = Duration.zero;

  /// Reads the chat bloc from the surrounding provider tree.
  ChatBloc? get _chatBloc => context.read<ChatBloc>();

  /// Sets up the composer animations and draft listener.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _sendButtonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _recordAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    widget.controller.addListener(_onTextChanged);
  }

  /// Releases animation, recorder, and listener resources.
  @override
  void dispose() {
    _animationController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  /// Toggles the send animation based on whether the draft is empty.
  void _onTextChanged() {
    if (widget.controller.text.isNotEmpty && _sendButtonAnimation.value == 0) {
      _animationController.forward();
    } else if (widget.controller.text.isEmpty &&
        _sendButtonAnimation.value == 1) {
      _animationController.reverse();
    }
  }

  /// Builds the composer shell and its inline action zones.
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(
            left: 8,
            right: 8,
            top: 4,
            bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 4 : 8,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.darkCard.withOpacity(0.85),
                AppTheme.darkCard.withOpacity(0.8),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: AppTheme.darkBorder.withOpacity(0.03),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showAttachmentOptions) _buildMinimalAttachmentOptions(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMinimalAttachmentButton(),
                  const SizedBox(width: 5),
                  Expanded(child: _buildMinimalInputField()),
                  const SizedBox(width: 5),
                  _buildMinimalActionButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the horizontal row of quick attachment actions.
  Widget _buildMinimalAttachmentOptions() {
    return Container(
      height: 64,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _MinimalAttachmentOption(
            icon: Icons.image_rounded,
            label: context.tr('chat.composer.image'),
            gradient: [
              AppTheme.primaryBlue.withOpacity(0.8),
              AppTheme.primaryBlue.withOpacity(0.6),
            ],
            onTap: () => _pickImage(ImageSource.gallery),
          ),
          _MinimalAttachmentOption(
            icon: Icons.camera_alt_rounded,
            label: context.tr('chat.composer.camera'),
            gradient: [
              AppTheme.neonGreen.withOpacity(0.8),
              AppTheme.neonGreen.withOpacity(0.6),
            ],
            onTap: () => _pickImage(ImageSource.camera),
          ),
          _MinimalAttachmentOption(
            icon: Icons.videocam_rounded,
            label: context.tr('chat.composer.video'),
            gradient: [
              AppTheme.error.withOpacity(0.8),
              AppTheme.error.withOpacity(0.6),
            ],
            onTap: _pickVideo,
          ),
          _MinimalAttachmentOption(
            icon: Icons.attach_file_rounded,
            label: context.tr('chat.composer.file'),
            gradient: [
              AppTheme.warning.withOpacity(0.8),
              AppTheme.warning.withOpacity(0.6),
            ],
            onTap: _pickFile,
          ),
          _MinimalAttachmentOption(
            icon: Icons.location_on_rounded,
            label: context.tr('chat.composer.location'),
            gradient: [
              AppTheme.primaryPurple.withOpacity(0.8),
              AppTheme.primaryPurple.withOpacity(0.6),
            ],
            onTap: () {
              setState(() {
                _showAttachmentOptions = false;
              });
              widget.onLocation?.call();
            },
          ),
        ],
      ),
    );
  }

  /// Builds the button that opens or closes the attachment strip.
  Widget _buildMinimalAttachmentButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _showAttachmentOptions = !_showAttachmentOptions;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: _showAttachmentOptions
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.8),
                    AppTheme.primaryPurple.withOpacity(0.7),
                  ],
                )
              : null,
          color: !_showAttachmentOptions
              ? AppTheme.darkCard.withOpacity(0.4)
              : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _showAttachmentOptions
                ? Colors.white.withOpacity(0.15)
                : AppTheme.darkBorder.withOpacity(0.15),
            width: 0.5,
          ),
        ),
        child: AnimatedRotation(
          duration: const Duration(milliseconds: 200),
          turns: _showAttachmentOptions ? 0.125 : 0,
          child: Icon(
            Icons.add_rounded,
            color: _showAttachmentOptions
                ? Colors.white
                : AppTheme.textMuted.withOpacity(0.5),
            size: 18,
          ),
        ),
      ),
    );
  }

  /// Builds the compact multiline text field used for chat drafts.
  Widget _buildMinimalInputField() {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 32,
        maxHeight: 80,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.5),
            AppTheme.darkCard.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.focusNode.hasFocus
              ? AppTheme.primaryBlue.withOpacity(0.2)
              : AppTheme.darkBorder.withOpacity(0.08),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppTheme.textWhite.withOpacity(0.9),
                height: 1.3,
              ),
              decoration: InputDecoration(
                hintText: widget.editingMessage != null
                    ? context.tr(
                        'chat.composer.editHint',
                      )
                    : widget.replyToMessageId != null
                        ? context.tr(
                            'chat.composer.replyHint',
                          )
                        : context.tr(
                            'chat.composer.messageHint',
                          ),
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textMuted.withOpacity(0.35),
                  fontSize: 12,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                isDense: true,
              ),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  widget.onSend(text);
                }
              },
            ),
          ),
          GestureDetector(
            onTap: _insertEmoji,
            child: Container(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.emoji_emotions_outlined,
                color: AppTheme.textMuted.withOpacity(0.35),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the primary send/mic action and its recording state.
  Widget _buildMinimalActionButton() {
    return AnimatedBuilder(
      animation: _sendButtonAnimation,
      builder: (context, child) {
        final showSend = _sendButtonAnimation.value > 0.5;

        return GestureDetector(
          onTap: showSend ? _sendMessage : null,
          onLongPress: !showSend ? _startRecording : null,
          onLongPressEnd: !showSend ? (_) => _stopRecording() : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: showSend || _isRecording
                  ? LinearGradient(
                      colors: [
                        AppTheme.primaryBlue.withOpacity(0.8),
                        AppTheme.primaryPurple.withOpacity(0.7),
                      ],
                    )
                  : null,
              color: !showSend && !_isRecording
                  ? AppTheme.darkCard.withOpacity(0.4)
                  : null,
              shape: BoxShape.circle,
              border: Border.all(
                color: showSend || _isRecording
                    ? Colors.white.withOpacity(0.15)
                    : AppTheme.darkBorder.withOpacity(0.15),
                width: 0.5,
              ),
              boxShadow: showSend || _isRecording
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: AnimatedSwitcher(
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
                child: _isRecording
                    ? _buildMinimalRecordingIndicator()
                    : Icon(
                        showSend ? Icons.send_rounded : Icons.mic_rounded,
                        color: showSend || _isRecording
                            ? Colors.white
                            : AppTheme.textMuted.withOpacity(0.5),
                        size: 16,
                        key: ValueKey(showSend),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the pulsing indicator shown while audio capture is active.
  Widget _buildMinimalRecordingIndicator() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _recordAnimation.value,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.error.withOpacity(0.8),
                  AppTheme.error.withOpacity(0.6),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.error.withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Sends the trimmed text draft through the chat bloc.
  void _sendMessage() {
    final text = widget.controller.text.trim();
    if (text.isNotEmpty) {
      HapticFeedback.lightImpact();
      widget.onSend(text);
    }
  }

  /// Starts microphone capture after checking runtime permission.
  Future<void> _startRecording() async {
    HapticFeedback.mediumImpact();

    final permission = await Permission.microphone.request();
    if (!permission.isGranted) return;

    if (await _audioRecorder.hasPermission()) {
      final directory = Directory.systemTemp;
      _recordingPath =
          '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(),
        path: _recordingPath,
      );

      setState(() {
        _isRecording = true;
      });

      _animationController.repeat(reverse: true);
    }
  }

  /// Stops microphone capture and hands the file path to the chat bloc.
  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    HapticFeedback.mediumImpact();
    _animationController.stop();

    final path = await _audioRecorder.stop();

    setState(() {
      _isRecording = false;
    });

    if (path != null) {
      _sendAudioMessage(path);
    }
  }

  /// Wraps the recorded file into the dedicated chat event.
  void _sendAudioMessage(String path) async {
    try {
      // Upload the audio file as part of the message sending process
      await _sendMessageWithAudioFile(path);
    } catch (e) {
      // Handle error appropriately
      print('Error sending audio message: $e');
    }
  }

  /// Picks a compressed image from the chosen source and closes the sheet.
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _showAttachmentOptions = false;
      });
      // Send image
    }
  }

  /// Picks a short video from the gallery and collapses the sheet.
  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );

    if (video != null) {
      setState(() {
        _showAttachmentOptions = false;
      });
      // Send video
    }
  }

  /// Closes the attachment sheet before handing off to a file picker.
  void _pickFile() {
    setState(() {
      _showAttachmentOptions = false;
    });
    // Implement file picker
  }

  /// Triggers the emoji affordance and provides immediate tactile feedback.
  void _insertEmoji() {
    HapticFeedback.lightImpact();
    // Show emoji picker
  }

  /// Sends the recorded audio path through the chat bloc.
  Future<void> _sendMessageWithAudioFile(String filePath) async {
    if (_chatBloc == null) {
      print('ChatBloc not available');
      return;
    }

    try {
      // Send the audio message using the new dedicated event
      _chatBloc!.add(SendAudioMessageEvent(
        conversationId: widget.conversationId,
        filePath: filePath,
        replyToMessageId: widget.replyToMessageId,
      ));
    } catch (e) {
      print('Error sending audio message: $e');
    }
  }
}

/// Small action tile used inside the attachment sheet.
class _MinimalAttachmentOption extends StatelessWidget {
  /// Icon shown inside the attachment tile.
  final IconData icon;

  /// Short label describing the action.
  final String label;

  /// Gradient used to make the tile visually distinct.
  final List<Color> gradient;

  /// Invoked when the user taps the tile.
  final VoidCallback onTap;

  /// Builds one compact attachment action.
  const _MinimalAttachmentOption({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  /// Builds the tappable attachment action tile.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 56,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 9,
                color: AppTheme.textMuted.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
