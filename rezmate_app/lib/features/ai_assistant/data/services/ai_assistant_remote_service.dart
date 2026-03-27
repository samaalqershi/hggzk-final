import 'package:dio/dio.dart';

import '../../../../core/localization/locale_manager.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/utils/timezone_helper.dart';
import '../models/ai_assistant_models.dart';

class AiAssistantRemoteService {
  final ApiClient apiClient;

  AiAssistantRemoteService({required this.apiClient});

  Future<void> resetConversation() async {
    try {
      final response = await apiClient.post(
        '/api/client/ai-assistant/reset',
        options: Options(
          extra: {
            'suppressErrorToast': true,
          },
        ),
      );

      final raw = response.data;
      if (raw is! Map) {
        throw ApiException(message: 'استجابة غير متوقعة من الخادم.');
      }

      final body = raw.map((key, value) => MapEntry(key.toString(), value));
      final success = (body['success'] as bool?) ??
          (body['isSuccess'] as bool?) ??
          (body['Success'] as bool?) ??
          false;

      if (!success) {
        final serverMessage =
            (body['message'] ?? 'تعذر بدء محادثة جديدة.').toString();
        throw ApiException(
          message: serverMessage,
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'تعذر إعادة تعيين المحادثة: $e');
    }
  }

  Future<AiAssistantChatResponse> sendMessage({
    required String message,
    required List<AiAssistantHistoryMessage> history,
  }) async {
    final text = message.trim();
    if (text.isEmpty) {
      throw ApiException(message: 'الرسالة فارغة.');
    }

    String? timeZone;
    try {
      timeZone = await TimezoneHelper.getDeviceTimezone();
    } catch (_) {
      timeZone = null;
    }

    final locale = LocaleManager.getCurrentLocale().languageCode;

    try {
      final response = await apiClient.post(
        '/api/client/ai-assistant/chat',
        data: {
          'message': text,
          'history': history.map((e) => e.toJson()).toList(),
          'startFresh': history.isEmpty,
          'locale': locale,
          'timeZone': timeZone,
        },
        options: Options(
          extra: {
            'suppressErrorToast': true,
          },
        ),
      );

      final raw = response.data;
      if (raw is! Map) {
        throw ApiException(message: 'استجابة غير متوقعة من الخادم.');
      }

      final body = raw.map((key, value) => MapEntry(key.toString(), value));
      final success = (body['success'] as bool?) ??
          (body['isSuccess'] as bool?) ??
          (body['Success'] as bool?) ??
          false;
      if (!success) {
        final serverMessage =
            (body['message'] ?? 'فشل تنفيذ الطلب.').toString();
        throw ApiException(
            message: serverMessage, statusCode: response.statusCode);
      }

      final dynamic data = body['data'];
      final dynamic effectiveData = data ?? body['Data'];
      if (effectiveData is! Map) {
        throw ApiException(message: 'لم يتم استلام بيانات صالحة من الخادم.');
      }

      final mappedData =
          effectiveData.map((key, value) => MapEntry(key.toString(), value));
      return AiAssistantChatResponse.fromJson(mappedData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'تعذر الاتصال بالمساعد الذكي: $e');
    }
  }
}
