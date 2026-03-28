import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking_model.dart';

/// يعرّف عقد التخزين المحلي لبيانات الحجوزات حتى تبقى آخر لقطة قابلة
/// للاسترجاع عند انقطاع الشبكة أو تعذر الجلب.
/// Defines the local storage contract for bookings so the latest snapshot
/// remains recoverable when the network is unavailable or fetching fails.
abstract class BookingsLocalDataSource {
  /// يخزن قائمة الحجوزات الكاملة بصيغة JSON قابلة لإعادة التحميل لاحقًا.
  /// Stores the full bookings list as JSON so it can be reloaded later.
  Future<void> cacheBookings(List<BookingModel> bookings);

  /// يعيد الحجوزات المخزنة محليًا كما كانت في آخر مزامنة ناجحة.
  /// Returns the locally cached bookings exactly as they were in the last
  /// successful sync.
  Future<List<BookingModel>> getCachedBookings();

  /// يخزن تفاصيل حجز واحد تحت مفتاح مستقل ليستعملها وضع عدم الاتصال.
  /// Stores a single booking's details under a dedicated key for offline use.
  Future<void> cacheBookingDetails(String bookingId, BookingModel booking);

  /// يعيد تفاصيل الحجز المخزنة محليًا إذا كانت موجودة.
  /// Returns the locally cached booking details when available.
  Future<BookingModel?> getCachedBookingDetails(String bookingId);

  /// يمسح الكاش الكامل للحجوزات وتفاصيلها الفردية.
  /// Clears the full bookings cache together with individual booking details.
  Future<void> clearCache();
}

/// ينفذ تخزين الحجوزات محليًا باستخدام `SharedPreferences` مع الحفاظ على
/// لقطة خفيفة وسهلة الاسترجاع.
/// Implements local bookings storage with `SharedPreferences` while keeping
/// the snapshot lightweight and easy to restore.
class BookingsLocalDataSourceImpl implements BookingsLocalDataSource {
  /// مخزن القيم المفتاحية الذي يحتفظ بقائمة الحجوزات وتفاصيلها الفردية.
  /// Key-value store that holds the bookings list and individual booking
  /// details.
  final SharedPreferences sharedPreferences;

  /// المفتاح الذي تُخزن تحته قائمة الحجوزات الكاملة.
  /// Key used to store the full bookings list.
  static const CACHED_BOOKINGS = 'CACHED_BOOKINGS';

  /// البادئة المستخدمة لمفاتيح تفاصيل الحجز الفردية.
  /// Prefix used for individual booking-detail cache keys.
  static const CACHED_BOOKING_PREFIX = 'CACHED_BOOKING_';

  /// يربط مصدر البيانات المحلي بمثيل `SharedPreferences` المحقون.
  /// Binds the local datasource to the injected `SharedPreferences`
  /// instance.
  BookingsLocalDataSourceImpl({required this.sharedPreferences});

  @override

  /// يحول الحجوزات إلى JSON ويخزنها تحت المفتاح العام للقائمة.
  /// Converts bookings to JSON and stores them under the shared list key.
  Future<void> cacheBookings(List<BookingModel> bookings) async {
    final jsonList = bookings.map((booking) => booking.toJson()).toList();
    await sharedPreferences.setString(
      CACHED_BOOKINGS,
      json.encode(jsonList),
    );
  }

  @override

  /// يقرأ قائمة الحجوزات المخزنة ويعيدها ككيانات قابلة للاستخدام.
  /// Reads the stored bookings list and returns it as usable entities.
  Future<List<BookingModel>> getCachedBookings() async {
    final jsonString = sharedPreferences.getString(CACHED_BOOKINGS);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => BookingModel.fromJson(json)).toList();
    }
    return [];
  }

  @override

  /// يخزن تفاصيل حجز واحد بصيغة JSON تحت مفتاح خاص بالمعرف.
  /// Stores a single booking's details as JSON under an id-specific key.
  Future<void> cacheBookingDetails(
      String bookingId, BookingModel booking) async {
    await sharedPreferences.setString(
      '$CACHED_BOOKING_PREFIX$bookingId',
      json.encode(booking.toJson()),
    );
  }

  @override

  /// يعيد تفاصيل حجز واحد من الكاش إذا كانت متوفرة.
  /// Returns a single booking's details from the cache when available.
  Future<BookingModel?> getCachedBookingDetails(String bookingId) async {
    final jsonString = sharedPreferences.getString(
      '$CACHED_BOOKING_PREFIX$bookingId',
    );
    if (jsonString != null) {
      return BookingModel.fromJson(json.decode(jsonString));
    }
    return null;
  }

  @override

  /// يمسح قائمة الحجوزات وكل تفاصيل الحجوزات الفردية المخزنة.
  /// Clears the bookings list and every stored individual booking detail.
  Future<void> clearCache() async {
    await sharedPreferences.remove(CACHED_BOOKINGS);
    // Clear individual booking details
    final keys = sharedPreferences.getKeys();
    for (final key in keys) {
      if (key.startsWith(CACHED_BOOKING_PREFIX)) {
        await sharedPreferences.remove(key);
      }
    }
  }
}
