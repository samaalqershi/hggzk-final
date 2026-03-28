import 'package:hggzkportal/features/chat/domain/entities/message.dart';

/// يعرّف الكلاس `DeliveryReceiptModel`.
/// Describes the `DeliveryReceiptModel` class.
class DeliveryReceiptModel extends DeliveryReceipt {
  /// Initializes a new `DeliveryReceiptModel` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `DeliveryReceiptModel`.
  const DeliveryReceiptModel({
    super.deliveredAt,
    super.readAt,
    super.readBy,
  });

  /// ينشئ مثيلاً من `DeliveryReceiptModel`.
  /// Builds an instance of `DeliveryReceiptModel`.
  factory DeliveryReceiptModel.fromJson(Map<String, dynamic> json) {
    return DeliveryReceiptModel(
      deliveredAt: json['deliveredAt'] != null || json['delivered_at'] != null
          ? DateTime.parse(json['deliveredAt'] ?? json['delivered_at'])
          : null,
      readAt: json['readAt'] != null || json['read_at'] != null
          ? DateTime.parse(json['readAt'] ?? json['read_at'])
          : null,
      readBy: json['readBy'] != null
          ? List<String>.from(json['readBy'])
          : json['read_by'] != null
              ? List<String>.from(json['read_by'])
              : [],
    );
  }

  /// ينفذ العملية `toJson`.
  /// Runs the `toJson` operation.
  Map<String, dynamic> toJson() {
    return {
      if (deliveredAt != null) 'delivered_at': deliveredAt!.toIso8601String(),
      if (readAt != null) 'read_at': readAt!.toIso8601String(),
      'read_by': readBy,
    };
  }
}
