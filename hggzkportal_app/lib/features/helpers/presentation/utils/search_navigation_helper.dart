import 'package:flutter/material.dart';
import '../../../admin_users/domain/entities/user.dart';
import '../../../admin_properties/domain/entities/property.dart';
import '../../../admin_units/domain/entities/unit.dart';
import '../../../admin_cities/domain/entities/city.dart';
import '../../../admin_notifications/presentation/pages/user_selector_page.dart'
    as an_selector;
import '../pages/property_search_page.dart';
import '../pages/unit_search_page.dart';
import '../pages/city_search_page.dart';
import '../pages/booking_search_page.dart';

/// يجمع مسارات البحث المتكررة في واجهة واحدة حتى تستخدم الشاشات
/// نفس سلوك الانتقال والاختيار بدل تكراره في كل صفحة.
/// Groups repeated search flows behind one helper so screens reuse
/// the same navigation and selection behavior instead of duplicating it.
class SearchNavigationHelper {
  /// يفتح منتقي المستخدمين ويعيد مستخدمًا واحدًا عندما يكون الربط
  /// فرديًا.
  /// Opens the user picker and returns a single user when the
  /// relation is one-to-one.
  static Future<User?> searchSingleUser(
    BuildContext context, {
    String? initialSearchTerm,
  }) async {
    User? result;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => an_selector.AdminUserSelectorPage(
          initialSearchTerm: initialSearchTerm,
          allowMultiSelect: false,
          onUserSelected: (user) => result = user,
        ),
      ),
    );
    return result;
  }

  /// يفتح منتقي المستخدمين في وضع التحديد المتعدد عندما تحتاج
  /// العملية إلى أكثر من مستخدم.
  /// Opens the user picker in multi-select mode when the workflow
  /// needs more than one user.
  static Future<List<User>?> searchMultipleUsers(
    BuildContext context, {
    String? initialSearchTerm,
  }) async {
    List<User>? result;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => an_selector.AdminUserSelectorPage(
          initialSearchTerm: initialSearchTerm,
          allowMultiSelect: true,
          onUsersSelected: (users) => result = users,
        ),
      ),
    );
    return result;
  }

  /// يمرر البحث إلى شاشة العقارات ويعيد عقارًا واحدًا بعد الاختيار.
  /// Delegates the search to the property screen and returns one
  /// property after selection.
  static Future<Property?> searchSingleProperty(
    BuildContext context, {
    String? initialSearchTerm,
  }) async {
    Property? result;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertySearchPage(
          initialSearchTerm: initialSearchTerm,
          allowMultiSelect: false,
          onPropertySelected: (property) => result = property,
        ),
      ),
    );
    return result;
  }

  /// يستخدم شاشة العقارات في وضع متعدد عندما يتطلب التدفق أكثر من
  /// عقار.
  /// Uses the property screen in multi-select mode when the flow
  /// needs several properties.
  static Future<List<Property>?> searchMultipleProperties(
    BuildContext context, {
    String? initialSearchTerm,
  }) async {
    List<Property>? result;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertySearchPage(
          initialSearchTerm: initialSearchTerm,
          allowMultiSelect: true,
          onPropertiesSelected: (properties) => result = properties,
        ),
      ),
    );
    return result;
  }

  /// يفتح شاشة الوحدات مع إمكانية تقييدها بالعقار الحالي.
  /// Opens the unit screen and can constrain it to the current
  /// property.
  static Future<Unit?> searchSingleUnit(
    BuildContext context, {
    String? initialSearchTerm,
    String? propertyId,
  }) async {
    Unit? result;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnitSearchPage(
          initialSearchTerm: initialSearchTerm,
          propertyId: propertyId,
          allowMultiSelect: false,
          onUnitSelected: (unit) => result = unit,
        ),
      ),
    );
    return result;
  }

  /// يعيد مجموعة وحدات مختارة عندما يكون الربط جماعيًا.
  /// Exposes a selected group of units when the relation is
  /// multi-valued.
  static Future<List<Unit>?> searchMultipleUnits(
    BuildContext context, {
    String? initialSearchTerm,
    String? propertyId,
  }) async {
    List<Unit>? result;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnitSearchPage(
          initialSearchTerm: initialSearchTerm,
          propertyId: propertyId,
          allowMultiSelect: true,
          onUnitsSelected: (units) => result = units,
        ),
      ),
    );
    return result;
  }

  /// يفتح منتقي المدن ويمكن تقييده بدولة معينة لتقليل نطاق البحث.
  /// Opens the city picker and can narrow the search to one country.
  static Future<City?> searchSingleCity(
    BuildContext context, {
    String? initialSearchTerm,
    String? country,
  }) async {
    City? result;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CitySearchPage(
          initialSearchTerm: initialSearchTerm,
          country: country,
          allowMultiSelect: false,
          onCitySelected: (city) => result = city,
        ),
      ),
    );
    return result;
  }

  /// يتيح اختيار أكثر من مدينة عندما تحتاج الفلاتر إلى نطاق أوسع.
  /// Allows selecting multiple cities when filters need broader
  /// geographic coverage.
  static Future<List<City>?> searchMultipleCities(
    BuildContext context, {
    String? initialSearchTerm,
    String? country,
  }) async {
    List<City>? result;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CitySearchPage(
          initialSearchTerm: initialSearchTerm,
          country: country,
          allowMultiSelect: true,
          onCitiesSelected: (cities) => result = cities,
        ),
      ),
    );
    return result;
  }

  /// يربط البحث بالحجوزات ويعيد حجزًا واحدًا مع إمكان تضييق النتائج
  /// بواسطة المستخدم أو الوحدة.
  /// Connects the booking search and returns one booking while
  /// optionally narrowing results by user or unit.
  static Future<Map<String, dynamic>?> searchSingleBooking(
    BuildContext context, {
    String? initialSearchTerm,
    String? userId,
    String? unitId,
  }) async {
    Map<String, dynamic>? result;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSearchPage(
          initialSearchTerm: initialSearchTerm,
          userId: userId,
          unitId: unitId,
          allowMultiSelect: false,
          onBookingSelected: (booking) => result = booking,
        ),
      ),
    );
    return result;
  }

  /// يفتح البحث متعدد الاختيار للحجوزات عندما تتطلب العملية قائمة
  /// بدل سجل واحد.
  /// Opens the booking picker in multi-select mode when the workflow
  /// needs a list instead of a single record.
  static Future<List<Map<String, dynamic>>?> searchMultipleBookings(
    BuildContext context, {
    String? initialSearchTerm,
    String? userId,
    String? unitId,
  }) async {
    List<Map<String, dynamic>>? result;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSearchPage(
          initialSearchTerm: initialSearchTerm,
          userId: userId,
          unitId: unitId,
          allowMultiSelect: true,
          onBookingsSelected: (bookings) => result = bookings,
        ),
      ),
    );
    return result;
  }
}
