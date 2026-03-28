import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attachment.dart';
import '../repositories/chat_repository.dart';

/// يعرّف الكلاس `UploadAttachmentUseCase`.
/// Describes the `UploadAttachmentUseCase` class.
class UploadAttachmentUseCase
    implements UseCase<Attachment, UploadAttachmentParams> {
  /// يخزن العضو `repository`.
  /// Holds the `repository` member.
  final ChatRepository repository;

  /// ينشئ مثيلاً من `UploadAttachmentUseCase`.
  /// Builds an instance of `UploadAttachmentUseCase`.
  UploadAttachmentUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, Attachment>> call(
      UploadAttachmentParams params) async {
    return await repository.uploadAttachment(
      conversationId: params.conversationId,
      filePath: params.filePath,
      messageType: params.messageType,
      thumbnailPath: params.thumbnailPath,
      onSendProgress: params.onSendProgress,
    );
  }
}

/// يعرّف الكلاس `UploadAttachmentParams`.
/// Describes the `UploadAttachmentParams` class.
class UploadAttachmentParams extends Equatable {
  /// Holds the `conversationId` value.
  /// العربية: يخزن القيمة `conversationId`.
  final String conversationId;

  /// يخزن العضو `filePath`.
  /// Holds the `filePath` member.
  final String filePath;

  /// يخزن العضو `messageType`.
  /// Holds the `messageType` member.
  final String messageType;

  /// يخزن العضو `onSendProgress`.
  /// Holds the `onSendProgress` member.
  final ProgressCallback? onSendProgress;

  /// يخزن العضو `thumbnailPath`.
  /// Holds the `thumbnailPath` member.
  final String? thumbnailPath;

  /// ينشئ مثيلاً من `UploadAttachmentParams`.
  /// Builds an instance of `UploadAttachmentParams`.
  const UploadAttachmentParams({
    required this.conversationId,
    required this.filePath,
    required this.messageType,
    this.thumbnailPath,
    this.onSendProgress,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [
        conversationId,
        filePath,
        messageType,
      ];
}
