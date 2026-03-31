import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attachment.dart';
import '../repositories/chat_repository.dart';

/// العربية: ينفذ حالة الاستخدام `UpdateChatSettingsUseCase`.
class UpdateChatSettingsUseCase
    implements UseCase<ChatSettings, UpdateChatSettingsParams> {
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `UpdateChatSettingsUseCase`.
  UpdateChatSettingsUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, ChatSettings>> call(
      UpdateChatSettingsParams params) async {
    return await repository.updateChatSettings(
      notificationsEnabled: params.notificationsEnabled,
      soundEnabled: params.soundEnabled,
      showReadReceipts: params.showReadReceipts,
      showTypingIndicator: params.showTypingIndicator,
      theme: params.theme,
      fontSize: params.fontSize,
      autoDownloadMedia: params.autoDownloadMedia,
      backupMessages: params.backupMessages,
    );
  }
}

/// العربية: يمثل `UpdateChatSettingsParams`.
class UpdateChatSettingsParams extends Equatable {
  /// العربية: يخزن القيمة `notificationsEnabled`.
  final bool? notificationsEnabled;

  /// العربية: يخزن القيمة `soundEnabled`.
  final bool? soundEnabled;

  /// العربية: يخزن القيمة `showReadReceipts`.
  final bool? showReadReceipts;

  /// العربية: يخزن القيمة `showTypingIndicator`.
  final bool? showTypingIndicator;

  /// العربية: يخزن القيمة `theme`.
  final String? theme;

  /// العربية: يخزن القيمة `fontSize`.
  final String? fontSize;

  /// العربية: يخزن القيمة `autoDownloadMedia`.
  final bool? autoDownloadMedia;

  /// العربية: يخزن القيمة `backupMessages`.
  final bool? backupMessages;

  /// العربية: ينشئ مثيلًا جديدًا من `UpdateChatSettingsParams`.
  const UpdateChatSettingsParams({
    this.notificationsEnabled,
    this.soundEnabled,
    this.showReadReceipts,
    this.showTypingIndicator,
    this.theme,
    this.fontSize,
    this.autoDownloadMedia,
    this.backupMessages,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [
        notificationsEnabled,
        soundEnabled,
        showReadReceipts,
        showTypingIndicator,
        theme,
        fontSize,
        autoDownloadMedia,
        backupMessages,
      ];
}
