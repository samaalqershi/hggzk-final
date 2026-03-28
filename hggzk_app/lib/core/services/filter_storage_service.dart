import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// يحفظ حالة البحث والاختيارات الأساسية حتى تعود الواجهة إلى نفس السياق لاحقًا.
/// Persists the core search state so the UI can return to the same context later.
class FilterStorageService {
  /// مخزن التفضيلات الذي نكتب إليه قيم البحث والاختيارات.
  /// Preferences store used to persist search and selection state.
  final SharedPreferences _prefs;

  /// يربط الخدمة بمخزن الإعدادات المجهز من خارجها.
  /// Binds the service to the externally prepared preferences instance.
  FilterStorageService(this._prefs);

  /// مفتاح آخر نوع عقار اختاره المستخدم في الصفحة الرئيسية.
  /// Key for the last property type selected in the home flow.
  static const String _kLastPropertyTypeId = 'filter_last_property_type_id';

  /// مفتاح آخر نوع وحدة تم اختياره داخل نفس رحلة البحث.
  /// Key for the last unit type selected in the same search context.
  static const String _kLastUnitTypeId = 'filter_last_unit_type_id';

  /// مفتاح تاريخ الوصول المستخدم عند إعادة فتح الفلاتر.
  /// Key for the saved check-in date across sessions.
  static const String _kCheckIn = 'filter_check_in';

  /// مفتاح تاريخ المغادرة المستخدم عند إعادة فتح الفلاتر.
  /// Key for the saved check-out date across sessions.
  static const String _kCheckOut = 'filter_check_out';

  /// مفتاح عدد البالغين داخل حالة البحث المحفوظة.
  /// Key for the adult guest count in the saved search.
  static const String _kAdults = 'filter_adults';

  /// مفتاح عدد الأطفال داخل حالة البحث المحفوظة.
  /// Key for the child guest count in the saved search.
  static const String _kChildren = 'filter_children';

  /// مفتاح النسخة المجمعة من الفلاتر التي نعيد بناءها عند العودة للتطبيق.
  /// Key for the serialized filter snapshot restored when the app returns.
  static const String _kCurrentFilters = 'filter_current_filters';

  /// مفتاح المدينة المختارة حتى يبقى البحث مرتبطًا بالموقع نفسه.
  /// Key for the selected city so the search stays tied to the same location.
  static const String _kCity = 'filter_city';

  /// مفتاح آخر نص بحث كتبه المستخدم.
  /// Key for the latest search phrase entered by the user.
  static const String _kSearchTerm = 'filter_search_term';

  /// يحفظ اختيارات الصفحة الرئيسية المختصرة حتى نعيد بناء السياق دون إعادة الإدخال.
  /// Saves the compact home-selection state so the browsing context can be rebuilt.
  Future<void> saveHomeSelections({
    String? propertyTypeId,
    String? unitTypeId,
    required Map<String, dynamic> dynamicFieldValues,
  }) async {
    if (propertyTypeId != null) {
      await _prefs.setString(_kLastPropertyTypeId, propertyTypeId);
    }
    if (unitTypeId != null) {
      await _prefs.setString(_kLastUnitTypeId, unitTypeId);
    }

    final DateTime? checkIn = dynamicFieldValues['checkIn'] is DateTime
        ? dynamicFieldValues['checkIn'] as DateTime
        : null;
    final DateTime? checkOut = dynamicFieldValues['checkOut'] is DateTime
        ? dynamicFieldValues['checkOut'] as DateTime
        : null;
    final int adults = (dynamicFieldValues['adults'] as int?) ?? 0;
    final int children = (dynamicFieldValues['children'] as int?) ?? 0;

    if (checkIn != null) {
      await _prefs.setString(_kCheckIn, checkIn.toIso8601String());
    } else {
      await _prefs.remove(_kCheckIn);
    }
    if (checkOut != null) {
      await _prefs.setString(_kCheckOut, checkOut.toIso8601String());
    } else {
      await _prefs.remove(_kCheckOut);
    }
    await _prefs.setInt(_kAdults, adults);
    await _prefs.setInt(_kChildren, children);

    // نحتفظ هنا فقط بالمدخلات التي يفهمها التطبيق مباشرة عند الاستعادة.
  }

  /// يعيد حالة التصفح المختصرة، مع إسقاط القيم المنتهية الصلاحية.
  /// Restores the compact browsing state and drops stale dates.
  Map<String, dynamic> getHomeSelections() {
    final map = <String, dynamic>{};

    final pt = _prefs.getString(_kLastPropertyTypeId);
    final ut = _prefs.getString(_kLastUnitTypeId);
    if (pt != null) map['propertyTypeId'] = pt;
    if (ut != null) map['unitTypeId'] = ut;

    final checkInStr = _prefs.getString(_kCheckIn);
    final checkOutStr = _prefs.getString(_kCheckOut);
    bool hasExpiredSavedDates = false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime? checkIn;
    if (checkInStr != null) {
      final parsed = DateTime.tryParse(checkInStr);
      if (parsed != null) {
        if (parsed.isBefore(today)) {
          hasExpiredSavedDates = true;
        } else {
          checkIn = parsed;
        }
      }
    }

    DateTime? checkOut;
    if (checkOutStr != null) {
      final parsed = DateTime.tryParse(checkOutStr);
      if (parsed != null) {
        final minAllowed = checkIn ?? today;
        if (parsed.isBefore(minAllowed)) {
          hasExpiredSavedDates = true;
        } else {
          checkOut = parsed;
        }
      }
    }

    if (checkIn != null) map['checkIn'] = checkIn;
    if (checkOut != null) map['checkOut'] = checkOut;

    final adults = _prefs.getInt(_kAdults) ?? 0;
    final children = _prefs.getInt(_kChildren) ?? 0;
    map['adults'] = adults;
    map['children'] = children;

    // نعيد فقط الحقول التي تستخدمها الشاشة عند إعادة ملء النماذج.
    final dynamicFieldValuesCombined = {
      if (map['checkIn'] != null) 'checkIn': map['checkIn'],
      if (map['checkOut'] != null) 'checkOut': map['checkOut'],
      'adults': adults,
      'children': children,
    };
    map['dynamicFieldValues'] = dynamicFieldValuesCombined;

    if (hasExpiredSavedDates) {
      map['hasExpiredSavedDates'] = true;
    }

    final city = _prefs.getString(_kCity);
    final searchTerm = _prefs.getString(_kSearchTerm);
    if (city != null) map['city'] = city;
    if (searchTerm != null) map['searchTerm'] = searchTerm;

    return map;
  }

  /// يحفظ نسخة قابلة للاسترجاع من الفلاتر الحالية بما في ذلك التواريخ والنصوص.
  /// Saves a restorable snapshot of the active filters, including dates and text fields.
  Future<void> saveCurrentFilters(Map<String, dynamic> filters) async {
    final f = Map<String, dynamic>.from(filters);
    if (f['checkIn'] is DateTime) {
      f['checkIn'] = (f['checkIn'] as DateTime).toIso8601String();
    }
    if (f['checkOut'] is DateTime) {
      f['checkOut'] = (f['checkOut'] as DateTime).toIso8601String();
    }
    final serializedMap = _serializeMap(f);
    await _prefs.setString(_kCurrentFilters, jsonEncode(serializedMap));

    if (f['propertyTypeId'] is String) {
      await _prefs.setString(_kLastPropertyTypeId, f['propertyTypeId']);
    }
    if (f['unitTypeId'] is String) {
      await _prefs.setString(_kLastUnitTypeId, f['unitTypeId']);
    }
    final city = f['city']?.toString().trim();
    if (city != null && city.isNotEmpty) {
      await _prefs.setString(_kCity, city);
      f['city'] = city;
    } else {
      f.remove('city');
      await _prefs.remove(_kCity);
    }
    final searchTerm = f['searchTerm']?.toString().trim();
    if (searchTerm != null && searchTerm.isNotEmpty) {
      await _prefs.setString(_kSearchTerm, searchTerm);
      f['searchTerm'] = searchTerm;
    } else {
      f.remove('searchTerm');
      await _prefs.remove(_kSearchTerm);
    }
  }

  /// يعيد الفلاتر المحفوظة بعد إعادة بناء القيم غير النصية إلى صورتها الأصلية.
  /// Restores the saved filters and rebuilds non-string values to their runtime types.
  Map<String, dynamic>? getCurrentFilters() {
    final jsonStr = _prefs.getString(_kCurrentFilters);
    if (jsonStr == null) return null;
    try {
      final decoded = Map<String, dynamic>.from(jsonDecode(jsonStr));
      final m = _deserializeMap(decoded);
      if (m['checkIn'] is String) {
        m['checkIn'] = DateTime.tryParse(m['checkIn']);
      }
      if (m['checkOut'] is String) {
        m['checkOut'] = DateTime.tryParse(m['checkOut']);
      }
      final city = m['city']?.toString().trim();
      if (city == null || city.isEmpty) {
        m.remove('city');
      } else {
        m['city'] = city;
      }
      final searchTerm = m['searchTerm']?.toString().trim();
      if (searchTerm == null || searchTerm.isEmpty) {
        m.remove('searchTerm');
      } else {
        m['searchTerm'] = searchTerm;
      }
      return m;
    } catch (_) {
      return null;
    }
  }

  /// يمسح الاختيارات السريعة حتى يبدأ المستخدم من نقطة بحث جديدة.
  /// Clears the short-lived selection state so a new search can start cleanly.
  Future<void> clearSelections() async {
    await _prefs.remove(_kLastPropertyTypeId);
    await _prefs.remove(_kLastUnitTypeId);
    await _prefs.remove(_kCheckIn);
    await _prefs.remove(_kCheckOut);
    await _prefs.remove(_kAdults);
    await _prefs.remove(_kChildren);
  }

  /// يحذف snapshot الفلاتر الكامل عندما لا يعود صالحًا.
  /// Drops the stored filter snapshot when it should no longer be reused.
  Future<void> clearCurrentFilters() async {
    await _prefs.remove(_kCurrentFilters);
  }

  /// يحول القيم القابلة للتخزين إلى تمثيل آمن داخل `SharedPreferences`.
  /// Converts runtime values into a `SharedPreferences`-safe representation.
  dynamic _serializeValue(dynamic value) {
    if (value is RangeValues) {
      return {
        '_type': 'RangeValues',
        'start': value.start,
        'end': value.end,
      };
    }
    return value;
  }

  /// يعيد بناء القيم التي تم تسلسلها إلى النوع المتوقع داخل الواجهة.
  /// Rehydrates serialized values back into the runtime types the UI expects.
  dynamic _deserializeValue(dynamic value) {
    if (value is Map && value['_type'] == 'RangeValues') {
      return RangeValues(
        (value['start'] as num).toDouble(),
        (value['end'] as num).toDouble(),
      );
    }
    return value;
  }

  /// يمر على خريطة الفلاتر ويفصل القيم التي لا يمكن تخزينها مباشرة.
  /// Walks the filter map and serializes values that cannot be stored directly.
  Map<String, dynamic> _serializeMap(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        result[key] = _serializeMap(value);
      } else {
        result[key] = _serializeValue(value);
      }
    });
    return result;
  }

  /// يعيد تشكيل خريطة الفلاتر بعد القراءة من التخزين المحلي.
  /// Restores a filter map after it has been read from local storage.
  Map<String, dynamic> _deserializeMap(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      if (value is Map &&
          value['_type'] == null &&
          value is Map<String, dynamic>) {
        result[key] = _deserializeMap(value);
      } else {
        result[key] = _deserializeValue(value);
      }
    });
    return result;
  }
}
