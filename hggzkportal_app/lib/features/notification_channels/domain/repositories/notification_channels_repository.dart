import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification_channel.dart';

/// الـ BLoC حتى يظل منفصلًا عن تفاصيل الشبكة والتخزين.
/// channels feature.
/// defines what the BLoC needs so it stays separate from network and storage
/// details.
abstract class INotificationChannelsRepository {
  /// فلترتها محليًا.
  /// download everything and trim it locally.
  Future<Either<Failure, List<NotificationChannel>>> getChannels({
    String? search,
    String? type,
    bool? isActive,
    int page = 1,
    int pageSize = 20,
  });

  /// أو إلى بيانات ما قبل التعديل.
  /// pre-edit state.
  Future<Either<Failure, NotificationChannel>> getChannel(String id);

  /// العربية: هذا التوقيع يوضح أن الخادم هو صاحب القرار النهائي بشأن
  /// المعرّف الفعلي والسجل الناتج.
  /// fields.
  /// persisted identity and returned record.
  Future<Either<Failure, NotificationChannel>> createChannel({
    required String name,
    required String identifier,
    String? description,
    String? type,
    String? icon,
    String? color,
  });
  Future<Either<Failure, NotificationChannel>> updateChannel(
    String id, {
    String? name,
    String? description,
    bool? isActive,
    String? icon,
    String? color,
  });

  /// the operation.
  Future<Either<Failure, bool>> deleteChannel(String id);

  /// الوصول الفعلي للقناة.
  /// actually has access to the channel.
  Future<Either<Failure, List<UserChannelSubscription>>> getChannelSubscribers(
    String channelId, {
    bool activeOnly = true,
  });
  Future<Either<Failure, int>> addSubscribers(
    String channelId,
    List<String> userIds,
  );
  Future<Either<Failure, int>> removeSubscribers(
    String channelId,
    List<String> userIds,
  );

  /// resulting send history record.
  Future<Either<Failure, ChannelNotificationHistory>> sendChannelNotification(
    String channelId, {
    required String title,
    required String content,
    String? type,
    Map<String, String>? data,
  });
  Future<Either<Failure, List<ChannelNotificationHistory>>> getChannelHistory(
    String channelId, {
    int page = 1,
    int pageSize = 20,
  });
  Future<Either<Failure, ChannelStatistics>> getStatistics();

  /// summary.
  Future<Either<Failure, Map<String, dynamic>>> getChannelStatistics(
      String channelId);

  /// الشخصي أو الإدارة مع اشتراكاته.
  /// admin screen matches that user’s subscriptions.
  Future<Either<Failure, List<NotificationChannel>>> getUserChannels(
      String userId);

  /// العملية نفسها.
  /// removing others in the same operation.
  Future<Either<Failure, bool>> updateUserSubscriptions(
    String userId, {
    List<String>? channelsToAdd,
    List<String>? channelsToRemove,
  });
}
