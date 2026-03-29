import 'dart:convert';
import 'package:hggzk/core/error/exceptions.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import 'package:hggzk/core/models/paginated_result.dart' as core;
import 'package:hggzk/features/home/data/models/section_item_models.dart';
import 'package:hggzk/core/services/local_storage_service.dart';
import '../../../../core/enums/section_type_enum.dart';
import '../../../../core/enums/section_target_enum.dart';
import '../models/section_model.dart';
import '../models/property_type_model.dart';
import '../models/unit_type_model.dart';

abstract class HomeLocalDataSource {
  // Analytics
  Future<void> recordSectionImpression({required String sectionId});
  Future<void> recordSectionInteraction({
    required String sectionId,
    required String interactionType,
    String? itemId,
    Map<String, dynamic>? metadata,
  });

  // Section Analytics Data
  Future<Map<String, int>> getSectionImpressions();
  Future<List<Map<String, dynamic>>> getSectionInteractions();
  Future<void> clearAnalyticsData();

  // Sections
  Future<void> cacheSections(List<SectionModel> sections);
  Future<core.PaginatedResult<SectionModel>> getCachedSections({
    int pageNumber = 1,
    int pageSize = 10,
    String? target,
    String? type,
  });
  Future<void> clearSectionsCache();

  // Section Property Items
  Future<void> cacheSectionPropertyItems({
    required String sectionId,
    required List<SectionPropertyItemModel> items,
  });
  Future<core.PaginatedResult<SectionPropertyItemModel>>
      getCachedSectionPropertyItems({
    required String sectionId,
    int pageNumber = 1,
    int pageSize = 10,
  });
  Future<void> clearSectionPropertyItemsCache({String? sectionId});

  // Property Types
  Future<void> cachePropertyTypes(List<PropertyTypeModel> propertyTypes);
  Future<List<PropertyTypeModel>> getCachedPropertyTypes();
  Future<void> clearPropertyTypesCache();

  // Unit Types
  Future<void> cacheUnitTypes({
    required String propertyTypeId,
    required List<UnitTypeModel> unitTypes,
  });
  Future<List<UnitTypeModel>> getCachedUnitTypes(
      {required String propertyTypeId});
  Future<void> clearUnitTypesCache({String? propertyTypeId});

  // General cache management
  Future<void> clearAllCache();
  Future<bool> isCacheExpired({required String key, int maxAgeMinutes = 30});
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final LocalStorageService localStorage;

  // Storage Keys
  static const String _sectionsKey = 'home_sections';
  static const String _sectionsTimestampKey = 'home_sections_timestamp';
  static const String _sectionItemsPrefix = 'section_items_';
  static const String _sectionItemsTimestampPrefix = 'section_items_timestamp_';
  static const String _propertyTypesKey = 'property_types';
  static const String _propertyTypesTimestampKey = 'property_types_timestamp';
  static const String _unitTypesPrefix = 'unit_types_';
  static const String _unitTypesTimestampPrefix = 'unit_types_timestamp_';
  static const String _sectionImpressionsKey = 'section_impressions';
  static const String _sectionInteractionsKey = 'section_interactions';
  HomeLocalDataSourceImpl({required this.localStorage});

  CacheException _cacheException() {
    return CacheException(
      AppLocalizations.translateSync('home.error.cache'),
    );
  }

  @override
  Future<void> recordSectionImpression({required String sectionId}) async {
    try {
      final impressionsJson = localStorage.getData(_sectionImpressionsKey);
      Map<String, int> impressions = {};

      if (impressionsJson != null && impressionsJson is String) {
        final decoded = jsonDecode(impressionsJson) as Map<String, dynamic>;
        impressions = decoded.map((key, value) => MapEntry(key, value as int));
      }

      impressions[sectionId] = (impressions[sectionId] ?? 0) + 1;

      await localStorage.saveData(
          _sectionImpressionsKey, jsonEncode(impressions));
    } catch (e) {
      throw _cacheException();
    }
  }

  @override
  Future<void> recordSectionInteraction({
    required String sectionId,
    required String interactionType,
    String? itemId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final interactionsJson = localStorage.getData(_sectionInteractionsKey);
      List<Map<String, dynamic>> interactions = [];

      if (interactionsJson != null && interactionsJson is String) {
        final decoded = jsonDecode(interactionsJson) as List<dynamic>;
        interactions = decoded.cast<Map<String, dynamic>>();
      }

      interactions.add({
        'sectionId': sectionId,
        'interactionType': interactionType,
        'itemId': itemId,
        'metadata': metadata,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Keep only last 1000 interactions to prevent storage overflow
      if (interactions.length > 1000) {
        interactions = interactions.sublist(interactions.length - 1000);
      }

      await localStorage.saveData(
          _sectionInteractionsKey, jsonEncode(interactions));
    } catch (e) {
      throw _cacheException();
    }
  }

  @override
  Future<Map<String, int>> getSectionImpressions() async {
    try {
      final impressionsJson = localStorage.getData(_sectionImpressionsKey);
      if (impressionsJson != null && impressionsJson is String) {
        final decoded = jsonDecode(impressionsJson) as Map<String, dynamic>;
        return decoded.map((key, value) => MapEntry(key, value as int));
      }
      return {};
    } catch (e) {
      throw _cacheException();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSectionInteractions() async {
    try {
      final interactionsJson = localStorage.getData(_sectionInteractionsKey);
      if (interactionsJson != null && interactionsJson is String) {
        final decoded = jsonDecode(interactionsJson) as List<dynamic>;
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw _cacheException();
    }
  }

  @override
  Future<void> clearAnalyticsData() async {
    try {
      await localStorage.removeData(_sectionImpressionsKey);
      await localStorage.removeData(_sectionInteractionsKey);
    } catch (e) {
      throw _cacheException();
    }
  }

  @override
  Future<void> cacheSections(List<SectionModel> sections) async {
    try {
      final sectionsJson = sections.map((s) => s.toJson()).toList();
      await localStorage.saveData(_sectionsKey, jsonEncode(sectionsJson));
      await localStorage.saveData(
          _sectionsTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      throw _cacheException();
    }
  }

  @override
  Future<core.PaginatedResult<SectionModel>> getCachedSections({
    int pageNumber = 1,
    int pageSize = 10,
    String? target,
    String? type,
  }) async {
    try {
      if (await isCacheExpired(key: _sectionsTimestampKey)) {
        throw _cacheException();
      }

      final sectionsJson = localStorage.getData(_sectionsKey);
      if (sectionsJson == null || sectionsJson is! String) {
        throw _cacheException();
      }

      final decoded = jsonDecode(sectionsJson) as List<dynamic>;
      List<SectionModel> sections =
          decoded.map((json) => SectionModel.fromJson(json)).toList();

      // Apply filters
      if (target != null) {
        sections = sections
            .where((s) =>
                s.target.backendName.toLowerCase() == target.toLowerCase())
            .toList();
      }
      if (type != null) {
        sections = sections
            .where((s) => s.type.value.toLowerCase() == type.toLowerCase())
            .toList();
      }

      // Apply pagination
      final startIndex = (pageNumber - 1) * pageSize;
      final endIndex = startIndex + pageSize;
      final paginatedSections =
          sections.skip(startIndex).take(pageSize).toList();

      return core.PaginatedResult<SectionModel>(
        items: paginatedSections,
        pageNumber: pageNumber,
        pageSize: pageSize,
        totalCount: sections.length,
      );
    } catch (e) {
      throw _cacheException();
    }
  }

  @override
  Future<void> clearSectionsCache() async {
    try {
      await localStorage.removeData(_sectionsKey);
      await localStorage.removeData(_sectionsTimestampKey);
    } catch (e) {
      throw _cacheException();
    }
  }

  @override
  Future<void> cacheSectionPropertyItems({
    required String sectionId,
    required List<SectionPropertyItemModel> items,
  }) async {
    try {
      final itemsJson = items.map((item) => item.toJson()).toList();
      await localStorage.saveData(
          '$_sectionItemsPrefix$sectionId', jsonEncode(itemsJson));
      await localStorage.saveData('$_sectionItemsTimestampPrefix$sectionId',
          DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      throw _cacheException();
    }
  }

  @override
  Future<core.PaginatedResult<SectionPropertyItemModel>>
      getCachedSectionPropertyItems({
    required String sectionId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      if (await isCacheExpired(
          key: '$_sectionItemsTimestampPrefix$sectionId')) {
        throw _cacheException();
      }

      final itemsJson = localStorage.getData('$_sectionItemsPrefix$sectionId');
      if (itemsJson == null || itemsJson is! String) {
        throw _cacheException();
      }

      final decoded = jsonDecode(itemsJson) as List<dynamic>;
      List<SectionPropertyItemModel> items = decoded
          .map((json) => SectionPropertyItemModel.fromJson(json))
          .toList();

      // Apply pagination
      final startIndex = (pageNumber - 1) * pageSize;
      final endIndex = startIndex + pageSize;
      final paginatedItems = items.skip(startIndex).take(pageSize).toList();

      return core.PaginatedResult<SectionPropertyItemModel>(
        items: paginatedItems,
        pageNumber: pageNumber,
        pageSize: pageSize,
        totalCount: items.length,
      );
    } catch (e) {
      throw _cacheException();
    }
  }

  @override
  Future<void> clearSectionPropertyItemsCache({String? sectionId}) async {
    try {
      if (sectionId != null) {
        await localStorage.removeData('$_sectionItemsPrefix$sectionId');
        await localStorage
            .removeData('$_sectionItemsTimestampPrefix$sectionId');
      } else {
        // Bulk remove not supported without key iteration; clear known prefixes by best-effort
        // Consider maintaining an index of keys if needed later
      }
    } catch (e) {
      throw _cacheException();
    }
  }

  @override
  Future<void> cachePropertyTypes(List<PropertyTypeModel> propertyTypes) async {
    try {
      final typesJson = propertyTypes.map((type) => type.toJson()).toList();
      await localStorage.saveData(_propertyTypesKey, jsonEncode(typesJson));
      await localStorage.saveData(
          _propertyTypesTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      throw _cacheException();
    }
  }

  @override
  Future<List<PropertyTypeModel>> getCachedPropertyTypes() async {
    try {
      if (await isCacheExpired(
          key: _propertyTypesTimestampKey, maxAgeMinutes: 60)) {
        throw _cacheException();
      }

      final typesJson = localStorage.getData(_propertyTypesKey);
      if (typesJson == null || typesJson is! String) {
        throw _cacheException();
      }

      final decoded = jsonDecode(typesJson) as List<dynamic>;
      return decoded.map((json) => PropertyTypeModel.fromJson(json)).toList();
    } catch (e) {
      throw _cacheException();
    }
  }

  @override
  Future<void> clearPropertyTypesCache() async {
    try {
      await localStorage.removeData(_propertyTypesKey);
      await localStorage.removeData(_propertyTypesTimestampKey);
    } catch (e) {
      throw _cacheException();
    }
  }

  @override
  Future<void> cacheUnitTypes({
    required String propertyTypeId,
    required List<UnitTypeModel> unitTypes,
  }) async {
    try {
      final typesJson = unitTypes.map((type) => type.toJson()).toList();
      await localStorage.saveData(
          '$_unitTypesPrefix$propertyTypeId', jsonEncode(typesJson));
      await localStorage.saveData('$_unitTypesTimestampPrefix$propertyTypeId',
          DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      throw _cacheException();
    }
  }

  @override
  Future<List<UnitTypeModel>> getCachedUnitTypes(
      {required String propertyTypeId}) async {
    try {
      if (await isCacheExpired(
          key: '$_unitTypesTimestampPrefix$propertyTypeId',
          maxAgeMinutes: 60)) {
        throw _cacheException();
      }

      final typesJson =
          localStorage.getData('$_unitTypesPrefix$propertyTypeId');
      if (typesJson == null || typesJson is! String) {
        throw _cacheException();
      }

      final decoded = jsonDecode(typesJson) as List<dynamic>;
      return decoded.map((json) => UnitTypeModel.fromJson(json)).toList();
    } catch (e) {
      throw _cacheException();
    }
  }

  @override
  Future<void> clearUnitTypesCache({String? propertyTypeId}) async {
    try {
      if (propertyTypeId != null) {
        await localStorage.removeData('$_unitTypesPrefix$propertyTypeId');
        await localStorage
            .removeData('$_unitTypesTimestampPrefix$propertyTypeId');
      } else {
        // Bulk remove not supported without key iteration; skip
      }
    } catch (e) {
      throw _cacheException();
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      await clearSectionsCache();
      await clearSectionPropertyItemsCache();
      await clearPropertyTypesCache();
      await clearUnitTypesCache();
      await clearAnalyticsData();
    } catch (e) {
      throw _cacheException();
    }
  }

  @override
  Future<bool> isCacheExpired(
      {required String key, int maxAgeMinutes = 30}) async {
    try {
      final timestamp = localStorage.getData(key);
      if (timestamp == null) return true;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
      final now = DateTime.now();
      final difference = now.difference(cacheTime).inMinutes;

      return difference > maxAgeMinutes;
    } catch (e) {
      return true; // Assume expired if we can't determine
    }
  }
}
