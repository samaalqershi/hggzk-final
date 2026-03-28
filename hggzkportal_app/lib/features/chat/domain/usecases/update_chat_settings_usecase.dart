import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attachment.dart';
import '../repositories/chat_repository.dart';

/// يعرّف الكلاس `UpdateChatSettingsUseCase`.
/// Describes the `UpdateChatSettingsUseCase` class.
class UpdateChatSettingsUseCase
    implements UseCase<ChatSettings, UpdateChatSettingsParams> {
  /// يخزن العضو `repository`.
  /// Holds the `repository` member.
  final ChatRepository repository;

  /// ينشئ مثيلاً من `UpdateChatSettingsUseCase`.
  /// Builds an instance of `UpdateChatSettingsUseCase`.
  UpdateChatSettingsUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
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

/// يعرّف الكلاس `UpdateChatSettingsParams`.
/// Describes the `UpdateChatSettingsParams` class.
class UpdateChatSettingsParams extends Equatable {
  /// Holds the `notificationsEnabled` value.
  /// العربية: يخزن القيمة `notificationsEnabled`.
  final bool? notificationsEnabled;

  /// يخزن العضو `soundEnabled`.
  /// Holds the `soundEnabled` member.
  final bool? soundEnabled;

  /// يخزن العضو `showReadReceipts`.
  /// Holds the `showReadReceipts` member.
  final bool? showReadReceipts;

  /// يخزن العضو `showTypingIndicator`.
  /// Holds the `showTypingIndicator` member.
  final bool? showTypingIndicator;

  /// يخزن العضو `theme`.
  /// Holds the `theme` member.
  final String? theme;

  /// يخزن العضو `fontSize`.
  /// Holds the `fontSize` member.
  final String? fontSize;

  /// يخزن العضو `autoDownloadMedia`.
  /// Holds the `autoDownloadMedia` member.
  final bool? autoDownloadMedia;

  /// يخزن العضو `backupMessages`.
  /// Holds the `backupMessages` member.
  final bool? backupMessages;

  /// ينشئ مثيلاً من `UpdateChatSettingsParams`.
  /// Builds an instance of `UpdateChatSettingsParams`.
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

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
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
