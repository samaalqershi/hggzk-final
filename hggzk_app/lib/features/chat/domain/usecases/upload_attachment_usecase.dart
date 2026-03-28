import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attachment.dart';
import '../repositories/chat_repository.dart';

/// العربية: ينفذ حالة الاستخدام `UploadAttachmentUseCase`.
class UploadAttachmentUseCase
    implements UseCase<Attachment, UploadAttachmentParams> {
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `UploadAttachmentUseCase`.
  UploadAttachmentUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, Attachment>> call(
      UploadAttachmentParams params) async {
    return await repository.uploadAttachment(
      conversationId: params.conversationId,
      filePath: params.filePath,
      messageType: params.messageType,
      onSendProgress: params.onSendProgress,
    );
  }
}

/// العربية: يمثل `UploadAttachmentParams`.
class UploadAttachmentParams extends Equatable {
  /// العربية: يخزن القيمة `conversationId`.
  final String conversationId;

  /// العربية: يخزن القيمة `filePath`.
  final String filePath;

  /// العربية: يخزن القيمة `messageType`.
  final String messageType;

  /// العربية: يخزن القيمة `onSendProgress`.
  final ProgressCallback? onSendProgress;

  /// العربية: ينشئ مثيلًا جديدًا من `UploadAttachmentParams`.
  const UploadAttachmentParams({
    required this.conversationId,
    required this.filePath,
    required this.messageType,
    this.onSendProgress,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [
        conversationId,
        filePath,
        messageType,
      ];
}
