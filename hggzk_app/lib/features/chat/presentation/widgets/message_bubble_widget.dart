import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../app/dependency_injection/injection_container.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../chat_settings_keys.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/entities/message.dart';
import '../bloc/chat_bloc.dart';
import '../pages/chat_media_viewer_page.dart';
import 'attachment_preview_widget.dart';
import 'message_status_indicator.dart';
import 'reaction_picker_widget.dart';

/// Renders one chat message bubble with replies, attachments, reactions, and
/// action affordances.
/// يرسم فقاعة رسالة واحدة مع الردود والمرفقات والتفاعلات وأفعال الرسالة.
class MessageBubbleWidget extends StatefulWidget {
  /// Message being rendered in the bubble.
  /// الرسالة التي تُعرض داخل الفقاعة.
  final Message message;

  /// True when the bubble belongs to the current user.
  /// تكون صحيحة عندما تعود الفقاعة للمستخدم الحالي.
  final bool isMe;

  /// Previous message used to decide grouping and tail visibility.
  /// الرسالة السابقة المستخدمة لتحديد التجميع وإظهار الذيل.
  final Message? previousMessage;

  /// Next message used to decide grouping and tail visibility.
  /// الرسالة التالية المستخدمة لتحديد التجميع وإظهار الذيل.
  final Message? nextMessage;

  /// Opens the reply composer for this message.
  /// يفتح محرر الرد لهذه الرسالة.
  final VoidCallback? onReply;

  /// Opens edit mode for this message.
  /// يفتح وضع التعديل لهذه الرسالة.
  final VoidCallback? onEdit;

  /// Deletes the message when the user confirms the action.
  /// يحذف الرسالة عند تأكيد المستخدم.
  final VoidCallback? onDelete;

  /// Applies a reaction picked from the inline reaction tray.
  /// يضيف تفاعلًا مختارًا من درج التفاعلات المضمّن.
  final Function(String)? onReaction;

  /// Opens the referenced reply when the user taps the quoted preview.
  /// يفتح الرد المشار إليه عندما ينقر المستخدم على المعاينة المقتبسة.
  final VoidCallback? onReplyTap;

  /// Retries a failed outgoing message.
  /// يعيد محاولة الرسالة الصادرة عند فشلها.
  final VoidCallback? onRetry;

  /// Builds one message bubble with optional reaction support.
  /// ينشئ فقاعة رسالة واحدة مع دعم اختياري للتفاعلات.
  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.isMe,
    this.previousMessage,
    this.nextMessage,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onReaction,
    this.onReplyTap,
    this.onRetry,
  });

  /// Creates the state object for this widget.
  /// ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<MessageBubbleWidget> createState() => _MessageBubbleWidgetState();
}

/// Animates the message entrance and manages inline reaction visibility.
/// يحرك ظهور الرسالة ويدير ظهور درج التفاعلات المضمّن.
class _MessageBubbleWidgetState extends State<MessageBubbleWidget>
    with SingleTickerProviderStateMixin {
  final Map<String, String> _remoteVideoCachePaths = {};
  final Map<String, String> _videoThumbnailCachePaths = {};

  /// Drives the bubble entrance animation.
  /// يقود حركة ظهور الفقاعة.
  late AnimationController _animationController;

  /// Scales the bubble slightly as it enters the viewport.
  /// يكبّر الفقاعة قليلًا أثناء دخولها إلى الشاشة.
  late Animation<double> _scaleAnimation;

  /// Fades the bubble into view.
  /// يدرج الفقاعة إلى الواجهة بالتدريج.
  late Animation<double> _fadeAnimation;

  /// Tracks whether the reaction tray is visible.
  /// يتتبع ما إذا كان درج التفاعلات ظاهرًا.
  bool _showReactions = false;

  bool get _autoDownloadEnabled {
    final state = context.read<ChatBloc>().state;
    if (state is ChatLoaded) {
      return state.settings?.autoDownloadMedia ?? true;
    }

    final persisted =
        sl<LocalStorageService>().getData(ChatSettingsKeys.autoDownloadMedia);
    if (persisted is bool) {
      return persisted;
    }

    return true;
  }

  /// Starts the entrance animation when the widget mounts.
  /// يبدأ حركة الظهور عند تركيب العنصر.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  /// Releases the animation controller owned by the bubble.
  /// يحرر متحكم الحركة المملوك للفقاعة.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Builds the bubble, attachment previews, footer, and reaction tray.
  /// يبني الفقاعة ومعاينات المرفقات والتذييل ودرج التفاعلات.
  @override
  Widget build(BuildContext context) {
    final showTail = _shouldShowTail();
    final borderRadius = _getBorderRadius(showTail);
    final showAttachmentsFirst = _shouldRenderAttachmentsFirst();
    final hasAttachments = widget.message.attachments.isNotEmpty;
    final hasTextContent = _hasTextContent;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        // FIXED: Remove alignment from ScaleTransition to preserve message position
        child: Container(
          margin: EdgeInsets.only(
            left: widget.isMe ? MediaQuery.of(context).size.width * 0.18 : 10,
            right: widget.isMe ? 10 : MediaQuery.of(context).size.width * 0.18,
            top: _getTopPadding(),
            bottom: 4,
          ),
          child: Column(
            crossAxisAlignment:
                widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onLongPress: _showOptions,
                onDoubleTap: () {
                  if (widget.onReaction != null) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _showReactions = !_showReactions;
                    });
                  }
                },
                child: Stack(
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.76,
                        minWidth: 60,
                      ),
                      child: ClipRRect(
                        borderRadius: borderRadius,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: widget.isMe ? 0 : 8,
                            sigmaY: widget.isMe ? 0 : 8,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: widget.isMe
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.primaryBlue.withOpacity(0.96),
                                        AppTheme.primaryPurple
                                            .withOpacity(0.88),
                                      ],
                                    )
                                  : LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.08),
                                        Colors.white.withOpacity(0.03),
                                      ],
                                    ),
                              borderRadius: borderRadius,
                              border: Border.all(
                                color: widget.isMe
                                    ? Colors.white.withOpacity(0.12)
                                    : AppTheme.darkBorder.withOpacity(0.1),
                                width: 0.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.isMe
                                      ? AppTheme.primaryBlue.withOpacity(0.15)
                                      : Colors.black.withOpacity(0.08),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.message.replyToMessageId != null)
                                  _buildMinimalReplySection(),
                                if (!showAttachmentsFirst)
                                  _buildMessageContent(),
                                if (hasAttachments) _buildAttachments(),
                                if (showAttachmentsFirst && hasTextContent)
                                  _buildMessageContent(isCaption: true),
                                if (_showsAttachmentUploadProgress)
                                  _buildAttachmentUploadProgress(),
                                _buildMinimalFooter(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (showTail) _buildMinimalTail(),
                  ],
                ),
              ),
              if (_shouldShowRetryState()) _buildFailureState(),
              if (widget.message.reactions.isNotEmpty) _buildMinimalReactions(),
              if (_showReactions)
                Padding(
                  padding: EdgeInsets.only(
                    top: 4,
                    left: widget.isMe ? 0 : 8,
                    right: widget.isMe ? 8 : 0,
                  ),
                  child: ReactionPickerWidget(
                    onReaction: (reaction) {
                      widget.onReaction?.call(reaction);
                      setState(() {
                        _showReactions = false;
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the quoted reply preview so users can jump back to the referenced
  /// message.
  /// ينشئ معاينة الرد المقتبس حتى يتمكن المستخدم من الرجوع إلى الرسالة
  /// المشار إليها.
  Widget _buildMinimalReplySection() {
    return GestureDetector(
      onTap: widget.onReplyTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 8, 8, 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isMe
                ? [
                    Colors.white.withOpacity(0.18),
                    Colors.white.withOpacity(0.08),
                  ]
                : [
                    AppTheme.primaryBlue.withOpacity(0.08),
                    AppTheme.primaryPurple.withOpacity(0.04),
                  ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isMe
                ? Colors.white.withOpacity(0.08)
                : AppTheme.primaryBlue.withOpacity(0.08),
            width: 0.6,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 2,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: widget.isMe
                      ? [
                          Colors.white.withOpacity(0.5),
                          Colors.white.withOpacity(0.2),
                        ]
                      : [
                          AppTheme.primaryBlue.withOpacity(0.8),
                          AppTheme.primaryPurple.withOpacity(0.6),
                        ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr('chat.message.replyTo'),
                    style: AppTextStyles.caption.copyWith(
                      color: widget.isMe
                          ? Colors.white.withOpacity(0.78)
                          : AppTheme.primaryBlue.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 9.5,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    context.tr(
                      'chat.message.repliedContent',
                    ),
                    style: AppTextStyles.caption.copyWith(
                      color: widget.isMe
                          ? Colors.white.withOpacity(0.56)
                          : AppTheme.textMuted.withOpacity(0.64),
                      fontSize: 10.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Renders the message body or the special location payload for the bubble.
  /// يرسم نص الرسالة أو حمولة الموقع الخاصة بالفقاعة.
  Widget _buildMessageContent({
    bool isCaption = false,
  }) {
    final normalizedMessageType = widget.message.messageType.toLowerCase();

    if (widget.message.content != null &&
        widget.message.content!.trim().isNotEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          12,
          isCaption ? 8 : 10,
          12,
          isCaption ? 4 : 8,
        ),
        child: Text(
          widget.message.content!,
          style: AppTextStyles.bodySmall.copyWith(
            color: widget.isMe
                ? Colors.white
                : AppTheme.textWhite.withOpacity(0.9),
            height: 1.45,
            fontSize: isCaption ? 12 : 12.6,
          ),
        ),
      );
    }

    if (normalizedMessageType == 'location' &&
        widget.message.location != null) {
      return _buildMinimalLocationMessage();
    }

    if (normalizedMessageType == 'location') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
        child: Text(
          context.tr('chat.message.location'),
          style: AppTextStyles.bodySmall.copyWith(
            color: widget.isMe
                ? Colors.white
                : AppTheme.textWhite.withOpacity(0.85),
            height: 1.35,
            fontSize: 12,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Renders the compact location card used for map-style chat messages.
  /// يرسم بطاقة الموقع المدمجة المستخدمة لرسائل المواقع.
  Widget _buildMinimalLocationMessage() {
    return GestureDetector(
      onTap: _openLocationInMaps,
      child: Container(
        margin: const EdgeInsets.all(5),
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Map placeholder
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.darkCard.withOpacity(0.8),
                      AppTheme.darkCard.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.map_rounded,
                  size: 32,
                  color: AppTheme.textMuted,
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                  child: Text(
                    context.tr('chat.message.location'),
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 9.5,
                    ),
                  ),
                ),
              ),

              // Glass overlay with location info
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.15),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryBlue.withOpacity(0.8),
                                  AppTheme.primaryPurple.withOpacity(0.6),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              widget.message.location!.address ??
                                  context.tr(
                                    'chat.message.location',
                                  ),
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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

  Future<void> _openLocationInMaps() async {
    final location = widget.message.location;
    if (location == null) return;

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}',
    );

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.tr('chat.errors.unknown')),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  /// Renders all attachments that belong to the message.
  /// يرسم كل المرفقات التابعة للرسالة.
  Widget _buildAttachments() {
    final visualAttachments = widget.message.attachments
        .where((attachment) => attachment.isImage || attachment.isVideo)
        .toList();
    final allVisual =
        visualAttachments.length == widget.message.attachments.length;

    if (allVisual) {
      return _buildMediaGallery(visualAttachments);
    }

    return Column(
      children: widget.message.attachments.asMap().entries.map((entry) {
        final index = entry.key;
        final attachment = entry.value;
        return AttachmentPreviewWidget(
          attachment: attachment,
          isMe: widget.isMe,
          autoDownloadEnabled: _autoDownloadEnabled,
          onTap: () => _openMediaViewer(
            attachments: widget.message.attachments,
            initialIndex: index,
          ),
        );
      }).toList(),
    );
  }

  bool get _showsAttachmentUploadProgress {
    if (widget.message.status != 'sending') {
      return false;
    }
    return widget.message.attachments.any(
      (attachment) =>
          attachment.downloadProgress != null &&
          attachment.downloadProgress! < 1.0,
    );
  }

  double? get _aggregateAttachmentUploadProgress {
    final tracked = widget.message.attachments
        .where((attachment) => attachment.downloadProgress != null)
        .toList();
    if (tracked.isEmpty) {
      return null;
    }

    final total = tracked.fold<double>(
      0,
      (sum, attachment) => sum + attachment.downloadProgress!.clamp(0.0, 1.0),
    );
    return (total / tracked.length).clamp(0.0, 1.0);
  }

  Widget _buildAttachmentUploadProgress() {
    final progress = _aggregateAttachmentUploadProgress;
    if (progress == null) {
      return const SizedBox.shrink();
    }

    final trackColor = widget.isMe
        ? Colors.white.withOpacity(0.18)
        : AppTheme.darkBorder.withOpacity(0.22);
    final fillColor =
        widget.isMe ? Colors.white : AppTheme.primaryBlue.withOpacity(0.95);
    final labelColor = widget.isMe
        ? Colors.white.withOpacity(0.82)
        : AppTheme.textWhite.withOpacity(0.76);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: trackColor,
              valueColor: AlwaysStoppedAnimation<Color>(fillColor),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).round()}%',
            style: AppTextStyles.caption.copyWith(
              color: labelColor,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Uses a media-first layout for image messages so the caption sits below
  /// the gallery, matching familiar messaging apps.
  bool _shouldRenderAttachmentsFirst() {
    return widget.message.attachments.isNotEmpty &&
        _hasTextContent &&
        widget.message.attachments
            .every((attachment) => attachment.isImage || attachment.isVideo);
  }

  /// Whether the bubble currently has visible text content.
  bool get _hasTextContent =>
      (widget.message.content?.trim().isNotEmpty ?? false);

  /// Renders one or many photos in a compact gallery layout inspired by
  /// mainstream messaging apps.
  Widget _buildMediaGallery(List<Attachment> attachments) {
    if (attachments.length == 1) {
      return AttachmentPreviewWidget(
        attachment: attachments.first,
        isMe: widget.isMe,
        autoDownloadEnabled: _autoDownloadEnabled,
        onTap: () => _openMediaViewer(
          attachments: attachments,
          initialIndex: 0,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(6, 6, 6, 2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spacing = 4.0;
          final maxWidth = constraints.maxWidth;
          final tileWidth = (maxWidth - spacing) / 2;

          if (attachments.length == 2) {
            return Row(
              children: [
                Expanded(
                  child: _buildGalleryTile(
                    attachments[0],
                    galleryAttachments: attachments,
                    index: 0,
                    height: 164,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildGalleryTile(
                    attachments[1],
                    galleryAttachments: attachments,
                    index: 1,
                    height: 164,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                ),
              ],
            );
          }

          if (attachments.length == 3) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: tileWidth,
                  child: _buildGalleryTile(
                    attachments[0],
                    galleryAttachments: attachments,
                    index: 0,
                    height: 188,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: tileWidth,
                  child: Column(
                    children: [
                      _buildGalleryTile(
                        attachments[1],
                        galleryAttachments: attachments,
                        index: 1,
                        height: 92,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildGalleryTile(
                        attachments[2],
                        galleryAttachments: attachments,
                        index: 2,
                        height: 92,
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          final visibleAttachments = attachments.take(4).toList();
          final extraCount = attachments.length - visibleAttachments.length;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: List.generate(visibleAttachments.length, (index) {
              final isTopLeft = index == 0;
              final isTopRight = index == 1;
              final isBottomLeft = index == 2;
              final isBottomRight = index == 3;
              final overlayText =
                  index == 3 && extraCount > 0 ? '+$extraCount' : null;

              return SizedBox(
                width: tileWidth,
                child: _buildGalleryTile(
                  visibleAttachments[index],
                  galleryAttachments: attachments,
                  index: index,
                  height: 104,
                  overlayText: overlayText,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isTopLeft ? 12 : 4),
                    topRight: Radius.circular(isTopRight ? 12 : 4),
                    bottomLeft: Radius.circular(isBottomLeft ? 12 : 4),
                    bottomRight: Radius.circular(isBottomRight ? 12 : 4),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  /// Builds one image or video tile inside a media gallery.
  Widget _buildGalleryTile(
    Attachment attachment, {
    required List<Attachment> galleryAttachments,
    required int index,
    required double height,
    required BorderRadius borderRadius,
    String? overlayText,
  }) {
    return GestureDetector(
      onTap: () => _openMediaViewer(
        attachments: galleryAttachments,
        initialIndex: index,
      ),
      child: Container(
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: widget.isMe
              ? Colors.white.withOpacity(0.04)
              : AppTheme.darkCard.withOpacity(0.28),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildGalleryTileMedia(attachment),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.32),
                    ],
                  ),
                ),
              ),
            ),
            if (attachment.isVideo)
              Center(
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.28),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                      width: 0.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            if (attachment.downloadProgress != null &&
                attachment.downloadProgress! < 1.0)
              Container(
                color: Colors.black.withOpacity(0.26),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    value: attachment.downloadProgress,
                    strokeWidth: 2,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    backgroundColor: Colors.white24,
                  ),
                ),
              ),
            if (overlayText != null)
              Container(
                color: Colors.black.withOpacity(0.34),
                alignment: Alignment.center,
                child: Text(
                  overlayText,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryTileMedia(Attachment attachment) {
    final autoDownloadEnabled = _autoDownloadEnabled;

    if (attachment.isImage) {
      final localPath = attachment.filePath.trim();
      if (localPath.isNotEmpty && File(localPath).existsSync()) {
        return Image.file(
          File(localPath),
          fit: BoxFit.cover,
        );
      }

      if (!autoDownloadEnabled) {
        return _buildDeferredMediaPlaceholder(
          icon: Icons.image_outlined,
        );
      }

      return CachedImageWidget(
        imageUrl: attachment.fileUrl,
        fit: BoxFit.cover,
        httpHeaders: _buildAttachmentHeaders(),
      );
    }

    final localThumbnailPath = _resolveLocalThumbnailPath(attachment);
    if (localThumbnailPath != null) {
      return Image.file(
        File(localThumbnailPath),
        fit: BoxFit.cover,
      );
    }

    if (attachment.thumbnailUrl != null &&
        attachment.thumbnailUrl!.isNotEmpty) {
      final resolvedThumbnailUrl =
          ImageUtils.resolveUrl(attachment.thumbnailUrl!);
      if (resolvedThumbnailUrl.isNotEmpty) {
        return Image.network(
          resolvedThumbnailUrl,
          fit: BoxFit.cover,
          headers: _buildAttachmentHeaders(),
          errorBuilder: (_, __, ___) =>
              _buildGeneratedVideoGalleryFallback(attachment),
        );
      }

      return _buildGeneratedVideoGalleryFallback(attachment);
    }

    return _buildGeneratedVideoGalleryFallback(attachment);
  }

  Widget _buildGeneratedVideoGalleryFallback(Attachment attachment) {
    return FutureBuilder<String?>(
      future: _buildVideoThumbnailForAttachment(attachment),
      builder: (context, snapshot) {
        final thumbPath = snapshot.data;
        if (thumbPath != null && File(thumbPath).existsSync()) {
          return Image.file(
            File(thumbPath),
            fit: BoxFit.cover,
          );
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkCard.withOpacity(0.8),
                AppTheme.darkSurface.withOpacity(0.6),
              ],
            ),
          ),
          child: Icon(
            Icons.videocam_rounded,
            size: 28,
            color: AppTheme.textMuted.withOpacity(0.55),
          ),
        );
      },
    );
  }

  Widget _buildDeferredMediaPlaceholder({required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard.withOpacity(0.82),
            AppTheme.darkSurface.withOpacity(0.64),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 28,
          color: AppTheme.textMuted.withOpacity(0.55),
        ),
      ),
    );
  }

  Future<String?> _buildVideoThumbnailForAttachment(
      Attachment attachment) async {
    final cachedThumbnailPath = _videoThumbnailCachePaths[attachment.id];
    if (cachedThumbnailPath != null && File(cachedThumbnailPath).existsSync()) {
      return cachedThumbnailPath;
    }

    final localPath = attachment.filePath.trim();
    if (localPath.isNotEmpty && File(localPath).existsSync()) {
      try {
        final generated = await VideoThumbnail.thumbnailFile(
          video: localPath,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 640,
          quality: 70,
          thumbnailPath: Directory.systemTemp.path,
        );
        if (generated != null) {
          _videoThumbnailCachePaths[attachment.id] = generated;
        }
        return generated;
      } catch (_) {
        return null;
      }
    }

    try {
      final cachedVideoPath = await _cacheProtectedVideoToTempFile(attachment);
      final generated = await VideoThumbnail.thumbnailFile(
        video: cachedVideoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 640,
        quality: 70,
        thumbnailPath: Directory.systemTemp.path,
      );
      if (generated != null) {
        _videoThumbnailCachePaths[attachment.id] = generated;
      }
      return generated;
    } catch (_) {
      return null;
    }
  }

  Future<String> _cacheProtectedVideoToTempFile(Attachment attachment) async {
    final existingPath = _remoteVideoCachePaths[attachment.id];
    if (existingPath != null && File(existingPath).existsSync()) {
      return existingPath;
    }

    final extension =
        attachment.fileExtension.isNotEmpty ? attachment.fileExtension : 'mp4';
    final targetPath =
        '${Directory.systemTemp.path}/chat_video_${attachment.id}.$extension';
    final targetFile = File(targetPath);
    if (targetFile.existsSync()) {
      _remoteVideoCachePaths[attachment.id] = targetPath;
      return targetPath;
    }

    final client = HttpClient();
    try {
      final resolvedVideoUrl = ImageUtils.resolveUrl(attachment.fileUrl);
      if (resolvedVideoUrl.isEmpty) {
        throw const HttpException('Video URL is empty');
      }

      final request = await client.getUrl(Uri.parse(resolvedVideoUrl));
      final headers = _buildAttachmentHeaders();
      headers?.forEach(request.headers.add);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Media download failed with status ${response.statusCode}',
          uri: Uri.parse(resolvedVideoUrl),
        );
      }

      final bytes = await consolidateHttpClientResponseBytes(response);
      await targetFile.writeAsBytes(bytes, flush: true);
      _remoteVideoCachePaths[attachment.id] = targetPath;
      return targetPath;
    } finally {
      client.close(force: true);
    }
  }

  void _openMediaViewer({
    required List<Attachment> attachments,
    required int initialIndex,
  }) {
    if (attachments.isEmpty) {
      return;
    }

    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatMediaViewerPage(
          attachments: attachments,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Map<String, String>? _buildAttachmentHeaders() {
    final token = sl<LocalStorageService>()
        .getData(StorageConstants.accessToken) as String?;
    if (token == null || token.isEmpty) {
      return null;
    }
    return {
      'Authorization': 'Bearer $token',
    };
  }

  /// Renders timestamp, edit state, and delivery status for the bubble.
  /// يرسم الوقت وحالة التعديل وحالة التسليم داخل الفقاعة.
  Widget _buildMinimalFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 10, 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.message.isEdited)
            Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Text(
                context.tr('chat.message.edited'),
                style: AppTextStyles.caption.copyWith(
                  color: widget.isMe
                      ? Colors.white.withOpacity(0.56)
                      : AppTheme.textMuted.withOpacity(0.46),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Text(
            _formatTime(widget.message.createdAt),
            style: AppTextStyles.caption.copyWith(
              color: widget.isMe
                  ? Colors.white.withOpacity(0.7)
                  : AppTheme.textMuted.withOpacity(0.58),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.isMe) ...[
            const SizedBox(width: 4),
            MessageStatusIndicator(
              status: widget.message.status,
              deliveryReceipt: widget.message.deliveryReceipt,
              color: Colors.white.withOpacity(0.7),
              size: 11,
            ),
          ],
        ],
      ),
    );
  }

  bool _shouldShowRetryState() {
    return widget.isMe &&
        widget.message.status.trim().toLowerCase() == 'failed' &&
        (widget.message.failureReason?.trim().isNotEmpty == true ||
            widget.onRetry != null);
  }

  Widget _buildFailureState() {
    final failureReason = widget.message.failureReason?.trim();

    return Padding(
      padding: EdgeInsets.only(
        top: 6,
        left: widget.isMe ? 0 : 8,
        right: widget.isMe ? 8 : 0,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: widget.isMe ? WrapAlignment.end : WrapAlignment.start,
        children: [
          if (failureReason != null && failureReason.isNotEmpty)
            Text(
              failureReason,
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.error.withOpacity(0.9),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (widget.onRetry != null)
            GestureDetector(
              onTap: widget.onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppTheme.error.withOpacity(0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 14,
                      color: AppTheme.error.withOpacity(0.92),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.tr('common.retry'),
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.error.withOpacity(0.96),
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
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

  String? _resolveLocalThumbnailPath(Attachment attachment) {
    final metadataPath = attachment.metadata?['localThumbnailPath'];
    if (metadataPath is String && metadataPath.trim().isNotEmpty) {
      final metadataFile = File(metadataPath.trim());
      if (metadataFile.existsSync()) {
        return metadataPath.trim();
      }
    }

    final normalizedPath = attachment.thumbnailUrl?.trim() ?? '';
    if (normalizedPath.isEmpty) {
      return null;
    }

    final file = File(normalizedPath);
    if (!file.existsSync()) {
      return null;
    }

    return normalizedPath;
  }

  /// Renders the grouped reaction chips shown under the message.
  /// يرسم شرائح التفاعل المجمعة أسفل الرسالة.
  Widget _buildMinimalReactions() {
    final groupedReactions = <String, int>{};
    for (final reaction in widget.message.reactions) {
      groupedReactions[reaction.reactionType] =
          (groupedReactions[reaction.reactionType] ?? 0) + 1;
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 2,
        left: widget.isMe ? 0 : 8,
        right: widget.isMe ? 8 : 0,
      ),
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        children: groupedReactions.entries.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppTheme.darkBorder.withOpacity(0.1),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getEmojiForReaction(entry.key),
                  style: const TextStyle(fontSize: 10),
                ),
                if (entry.value > 1) ...[
                  const SizedBox(width: 2),
                  Text(
                    entry.value.toString(),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textWhite.withOpacity(0.72),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds the small tail pointer that visually anchors the bubble.
  /// ينشئ الذيل الصغير الذي يثبت الفقاعة بصريًا.
  Widget _buildMinimalTail() {
    return Positioned(
      bottom: 0,
      left: widget.isMe ? null : -5,
      right: widget.isMe ? -5 : null,
      child: CustomPaint(
        painter: _MinimalTailPainter(
          color: widget.isMe
              ? AppTheme.primaryPurple.withOpacity(0.85)
              : AppTheme.darkCard.withOpacity(0.6),
          isMe: widget.isMe,
        ),
        size: const Size(6, 10),
      ),
    );
  }

  /// Computes the bubble radius so grouped messages can connect cleanly.
  /// يحسب نصف قطر الفقاعة حتى تتصل الرسائل المجمعة بشكل متناسق.
  BorderRadius _getBorderRadius(bool showTail) {
    const radius = 22.0;
    const smallRadius = 6.0;

    if (widget.isMe) {
      return BorderRadius.only(
        topLeft: const Radius.circular(radius),
        topRight: const Radius.circular(radius),
        bottomLeft: const Radius.circular(radius),
        bottomRight: Radius.circular(showTail ? smallRadius : radius),
      );
    } else {
      return BorderRadius.only(
        topLeft: const Radius.circular(radius),
        topRight: const Radius.circular(radius),
        bottomLeft: Radius.circular(showTail ? smallRadius : radius),
        bottomRight: const Radius.circular(radius),
      );
    }
  }

  /// Decides whether the bubble should render a tail based on the next
  /// message in the thread.
  /// يقرر ما إذا كانت الفقاعة تحتاج ذيلًا بناءً على الرسالة التالية في
  /// السلسلة.
  bool _shouldShowTail() {
    if (widget.nextMessage == null) return true;
    if (widget.nextMessage!.senderId != widget.message.senderId) return true;

    final timeDiff = widget.message.createdAt
        .difference(widget.nextMessage!.createdAt)
        .inMinutes;
    return timeDiff > 1;
  }

  /// Computes top spacing so consecutive messages from the same sender stay
  /// visually compact.
  /// يحسب التباعد العلوي حتى تبقى الرسائل المتتالية من نفس المرسل متقاربة
  /// بصريًا.
  double _getTopPadding() {
    if (widget.previousMessage == null) return 8;
    if (widget.previousMessage!.senderId != widget.message.senderId) {
      return 8;
    }

    final timeDiff = widget.previousMessage!.createdAt
        .difference(widget.message.createdAt)
        .inMinutes;
    return timeDiff > 1 ? 8 : 1.5;
  }

  /// Opens the message action sheet for reply, edit, delete, and copy flows.
  /// يفتح ورقة إجراءات الرسالة لمسارات الرد والتعديل والحذف والنسخ.
  void _showOptions() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MinimalMessageOptionsSheet(
        message: widget.message,
        isMe: widget.isMe,
        onReply: () {
          Navigator.pop(context);
          widget.onReply?.call();
        },
        onEdit: widget.onEdit != null
            ? () {
                Navigator.pop(context);
                widget.onEdit!();
              }
            : null,
        onDelete: widget.onDelete != null
            ? () {
                Navigator.pop(context);
                widget.onDelete!();
              }
            : null,
        onCopy: () {
          Navigator.pop(context);
          if (widget.message.content != null) {
            Clipboard.setData(ClipboardData(text: widget.message.content!));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.tr('chat.message.copied'),
                ),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppTheme.darkCard.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                margin: const EdgeInsets.all(8),
              ),
            );
          }
        },
      ),
    );
  }

  /// Formats a timestamp into the compact clock label shown inside bubbles.
  /// ينسق الطابع الزمني إلى تسمية وقت مختصرة تظهر داخل الفقاعات.
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Resolves the emoji used for a reaction chip.
  /// يحدد الإيموجي المستخدم لشريحة التفاعل.
  String _getEmojiForReaction(String reactionType) {
    switch (reactionType) {
      case 'like':
        return '👍';
      case 'love':
        return '❤️';
      case 'laugh':
        return '😂';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'wow':
        return '😮';
      default:
        return '👍';
    }
  }
}

/// Paints the small triangular tail attached to a message bubble.
/// يرسم الذيل المثلث الصغير المرفق بفقاعة الرسالة.
class _MinimalTailPainter extends CustomPainter {
  /// Tail fill color.
  /// لون تعبئة الذيل.
  final Color color;

  /// Whether the bubble belongs to the current user.
  /// يحدد ما إذا كانت الفقاعة تخص المستخدم الحالي.
  final bool isMe;

  /// Builds the painter for the bubble tail.
  /// ينشئ الرسّام الخاص بذيل الفقاعة.
  _MinimalTailPainter({
    required this.color,
    required this.isMe,
  });

  /// Draws the tail path on the provided canvas.
  /// يرسم مسار الذيل على اللوحة المحددة.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isMe) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height - 1.5);
      path.quadraticBezierTo(
        size.width / 2,
        size.height,
        size.width,
        size.height - 3,
      );
      path.lineTo(size.width, 0);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height - 1.5);
      path.quadraticBezierTo(
        size.width / 2,
        size.height,
        0,
        size.height - 3,
      );
      path.lineTo(0, 0);
    }

    canvas.drawPath(path, paint);
  }

  /// The tail shape is static, so repainting is not required.
  /// شكل الذيل ثابت، لذلك لا حاجة لإعادة الرسم.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bottom sheet that exposes message-specific actions in a compact form.
/// ورقة سفلية تعرض إجراءات الرسالة بشكل مضغوط.
class _MinimalMessageOptionsSheet extends StatelessWidget {
  /// Message that the action sheet operates on.
  /// الرسالة التي تعمل عليها ورقة الإجراءات.
  final Message message;

  /// Whether the current user owns the message.
  /// يحدد ما إذا كان المستخدم الحالي يملك الرسالة.
  final bool isMe;

  /// Invoked when the user chooses to reply.
  /// يُستدعى عندما يختار المستخدم الرد.
  final VoidCallback? onReply;

  /// Invoked when the user chooses to edit.
  /// يُستدعى عندما يختار المستخدم التعديل.
  final VoidCallback? onEdit;

  /// Invoked when the user chooses to delete.
  /// يُستدعى عندما يختار المستخدم الحذف.
  final VoidCallback? onDelete;

  /// Invoked when the user chooses to copy message text.
  /// يُستدعى عندما يختار المستخدم نسخ النص.
  final VoidCallback? onCopy;

  /// Builds the compact message action sheet.
  /// ينشئ ورقة إجراءات الرسالة المدمجة.
  const _MinimalMessageOptionsSheet({
    required this.message,
    required this.isMe,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onCopy,
  });

  /// Renders the compact set of actions for one message.
  /// يرسم مجموعة الإجراءات المضغوطة لرسالة واحدة.
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(16),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.darkCard.withOpacity(0.85),
                AppTheme.darkCard.withOpacity(0.9),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.08),
              width: 0.5,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.darkBorder.withOpacity(0.2),
                        AppTheme.darkBorder.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                if (onReply != null)
                  _buildOption(
                    icon: Icons.reply_rounded,
                    title: context.tr('chat.message.reply'),
                    onTap: onReply!,
                  ),
                if (message.content != null && onCopy != null)
                  _buildOption(
                    icon: Icons.copy_rounded,
                    title: context.tr('chat.message.copy'),
                    onTap: onCopy!,
                  ),
                if (isMe && onEdit != null)
                  _buildOption(
                    icon: Icons.edit_rounded,
                    title: context.tr('chat.message.edit'),
                    onTap: onEdit!,
                  ),
                if (isMe && onDelete != null)
                  _buildOption(
                    icon: Icons.delete_rounded,
                    title: context.tr('chat.message.delete'),
                    onTap: onDelete!,
                    isDestructive: true,
                  ),
                const SizedBox(height: 6),
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
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDestructive
                      ? [
                          AppTheme.error.withOpacity(0.12),
                          AppTheme.error.withOpacity(0.06),
                        ]
                      : [
                          AppTheme.primaryBlue.withOpacity(0.08),
                          AppTheme.primaryPurple.withOpacity(0.04),
                        ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: isDestructive
                    ? AppTheme.error.withOpacity(0.8)
                    : AppTheme.primaryBlue.withOpacity(0.8),
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDestructive
                    ? AppTheme.error.withOpacity(0.8)
                    : AppTheme.textWhite.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
