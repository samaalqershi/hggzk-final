import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'package:hggzk/core/error/failure_localizer.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import '../../domain/entities/support_message.dart';
import '../../domain/repositories/support_repository.dart';
import 'support_state.dart';

/// Coordinates support-message submission and enriches the request with
/// device metadata so the support team gets enough context to help quickly.
///
/// ينسق إرسال رسالة الدعم ويضيف بيانات الجهاز حتى يحصل فريق الدعم على
/// سياق كافٍ للمساعدة بسرعة.
class SupportCubit extends Cubit<SupportState> {
  /// Sends the final support payload to the backend.
  ///
  /// يرسل الحمولة النهائية لرسالة الدعم إلى الخادم.
  final SupportRepository repository;

  /// Creates the cubit with the repository that owns the support API call.
  ///
  /// ينشئ الـ cubit مع المستودع الذي يتولى استدعاء API الخاص بالدعم.
  SupportCubit({required this.repository}) : super(SupportInitial());

  /// Collects app and device context, then sends the support request and emits
  /// the matching success or error state.
  ///
  /// يجمع سياق التطبيق والجهاز ثم يرسل طلب الدعم ويصدر حالة النجاح أو الخطأ
  /// المناسبة.
  Future<void> sendSupportMessage({
    required String userName,
    required String userEmail,
    required String subject,
    required String message,
  }) async {
    emit(SupportLoading());

    try {
      String? deviceType;
      String? operatingSystem;
      String? osVersion;
      String? appVersion;

      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceType = androidInfo.model;
        operatingSystem = 'Android';
        osVersion = androidInfo.version.release;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceType = iosInfo.model;
        operatingSystem = 'iOS';
        osVersion = iosInfo.systemVersion;
      }

      final supportMessage = SupportMessage(
        userName: userName,
        userEmail: userEmail,
        subject: subject,
        message: message,
        deviceType: deviceType,
        operatingSystem: operatingSystem,
        osVersion: osVersion,
        appVersion: appVersion,
      );

      final result = await repository.sendSupportMessage(supportMessage);

      result.fold(
        (failure) =>
            emit(SupportError(message: FailureLocalizer.localize(failure))),
        (data) {
          final referenceNumber = data['referenceNumber'] ?? '';
          final responseMessage = data['message'] ??
              AppLocalizations.translateSync('support.messageSent');
          emit(SupportSuccess(
            message: responseMessage,
            referenceNumber: referenceNumber,
          ));
        },
      );
    } catch (e) {
      emit(SupportError(
        message: AppLocalizations.translateSync('support.error'),
      ));
    }
  }
}
