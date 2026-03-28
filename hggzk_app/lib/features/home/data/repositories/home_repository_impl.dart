import 'package:dartz/dartz.dart';
import 'package:hggzk/core/error/error_handler.dart';
import 'package:hggzk/core/error/failures.dart';
import 'package:hggzk/core/network/network_info.dart';
import 'package:hggzk/core/models/paginated_result.dart' as core;
import 'package:hggzk/features/home/data/models/section_item_models.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/entities/property_type.dart' as domain;
import '../../domain/entities/unit_type.dart' as domain;
import '../../domain/entities/section.dart' as section_domain;
import '../datasources/home_local_datasource.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/property_type_with_units_model.dart';
import '../../domain/entities/property_types_with_units.dart'
    as combined_domain;

/// يطبّق عقد الصفحة الرئيسية عبر الموازنة بين الخادم والكاش المحلي بحيث تبقى
/// الواجهة سريعة، وتستعيد البيانات المحفوظة عند ضعف الاتصال أو انقطاعه.
/// Implements the home repository by balancing remote calls with local cache
/// so the UI stays fast and can recover stored data when connectivity is weak
/// or unavailable.
class HomeRepositoryImpl implements HomeRepository {
  /// المصدر البعيد الذي يوفر بيانات الأقسام والأنواع والتحليلات من الخادم.
  /// Remote source that provides sections, types, and analytics calls from the
  /// backend.
  final HomeRemoteDataSource remoteDataSource;

  /// المصدر المحلي المستخدم للكاش السريع واسترجاع البيانات عند غياب الشبكة.
  /// Local source used for fast caching and offline-style restoration.
  final HomeLocalDataSource localDataSource;

  /// واجهة معرفة حالة الشبكة قبل تقرير ما إذا كنا سنعتمد على الخادم أو الكاش.
  /// Connectivity abstraction used to decide whether to rely on the backend or
  /// cached data.
  final NetworkInfo networkInfo;

  /// يربط التنفيذ بمصادر البيانات وحالة الشبكة التي يحتاجها لاتخاذ القرار
  /// بين القراءة البعيدة والمحلية.
  /// Binds the implementation to the data sources and network state it needs to
  /// choose between remote and local reads.
  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  @override
  Future<Either<Failure, void>> recordSectionImpression({
    required String sectionId,
  }) async {
    try {
      // نحفظ الانطباع محليًا أولًا حتى تبقى الاستجابة فورية حتى لو تأخرت
      // مزامنة الخادم.
      // Record the impression locally first so the response stays immediate
      // even if backend sync is delayed.
      await localDataSource.recordSectionImpression(sectionId: sectionId);

      // نحاول بعد ذلك مزامنة السجل مع الخادم ما دام الاتصال متاحًا.
      // Then try to synchronize the record with the backend whenever the device
      // is online.
      if (await networkInfo.isConnected) {
        await remoteDataSource.recordSectionImpression(sectionId: sectionId);
      }
      return const Right(null);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  @override
  Future<Either<Failure, combined_domain.PropertyTypesWithUnits>>
      getPropertyTypesWithUnits() async {
    if (await networkInfo.isConnected) {
      try {
        final List<PropertyTypeWithUnitsModel> result =
            await remoteDataSource.getPropertyTypesWithUnits();

        // نحول استجابة الشبكة إلى الكيانات التي تستخدمها بقية طبقات التطبيق.
        // Convert the network response into the domain entities consumed by the
        // rest of the application.
        final propertyTypes =
            result.map((e) => e.propertyType.toEntity()).toList();
        final Map<String, List<domain.UnitType>> unitTypesByPt = {};
        for (final item in result) {
          unitTypesByPt[item.propertyType.id] =
              item.unitTypes.map((m) => m.toEntity()).toList();
        }

        return Right(combined_domain.PropertyTypesWithUnits(
          propertyTypes: propertyTypes,
          unitTypesByPropertyTypeId: unitTypesByPt,
        ));
      } catch (e) {
        return ErrorHandler.handle(e);
      }
    } else {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, void>> recordSectionInteraction({
    required String sectionId,
    required String interactionType,
    String? itemId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // نسجل التفاعل محليًا أولًا حتى لا تنتظر الواجهة الرحلة الشبكية.
      // Store the interaction locally first so the UI does not wait for a
      // network round trip.
      await localDataSource.recordSectionInteraction(
        sectionId: sectionId,
        interactionType: interactionType,
        itemId: itemId,
        metadata: metadata,
      );

      // بعد ذلك نحاول إرسال نفس السجل إلى الخادم إذا كانت الشبكة متاحة.
      // After that, try to push the same record to the backend when online.
      if (await networkInfo.isConnected) {
        await remoteDataSource.recordSectionInteraction(
          sectionId: sectionId,
          interactionType: interactionType,
          itemId: itemId,
          metadata: metadata,
        );
      }

      return const Right(null);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  @override
  Future<Either<Failure, core.PaginatedResult<section_domain.Section>>>
      getSections({
    int pageNumber = 1,
    int pageSize = 10,
    String? target,
    String? type,
    bool forceRefresh = false,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // نبدأ دائمًا بنسخة جديدة من الخادم عندما تكون الشبكة متاحة.
        // Start with a fresh server copy whenever connectivity is available.
        final result = await remoteDataSource.getSections(
          pageNumber: pageNumber,
          pageSize: pageSize,
          target: target,
          type: type,
        );

        // نخزن النتيجة الجديدة محليًا حتى تصبح متاحة عند الانقطاع أو التراجع.
        // Cache the fresh result locally so it can be reused when connectivity
        // drops or later calls need a fallback.
        await localDataSource.cacheSections(result.items);

        // نحول الموديلات القادمة من طبقة البيانات إلى كيانات المجال المعتمدة.
        // Convert data-layer models into the domain entities the rest of the
        // feature expects.
        final mapped = core.PaginatedResult<section_domain.Section>(
          items: result.items.map((m) => m.toEntity()).toList(),
          pageNumber: result.pageNumber,
          pageSize: result.pageSize,
          totalCount: result.totalCount,
          metadata: result.metadata,
        );

        return Right(mapped);
      } catch (e) {
        // إذا فشل الخادم نحاول إنقاذ التجربة من الكاش بدل إسقاط الشاشة كاملة.
        // If the backend fails, rescue the experience from local cache instead
        // of collapsing the whole screen.
        try {
          final cachedSections = await localDataSource.getCachedSections(
            pageNumber: pageNumber,
            pageSize: pageSize,
            target: target,
            type: type,
          );
          final mapped = core.PaginatedResult<section_domain.Section>(
            items: cachedSections.items.map((m) => m.toEntity()).toList(),
            pageNumber: cachedSections.pageNumber,
            pageSize: cachedSections.pageSize,
            totalCount: cachedSections.totalCount,
            metadata: cachedSections.metadata,
          );
          return Right(mapped);
        } catch (cacheError) {
          return ErrorHandler.handle(e);
        }
      }
    } else {
      // عند غياب الشبكة نعتمد مباشرة على النسخة المحلية المخزنة.
      // When offline, rely directly on the locally cached snapshot.
      try {
        final cachedSections = await localDataSource.getCachedSections(
          pageNumber: pageNumber,
          pageSize: pageSize,
          target: target,
          type: type,
        );
        final mapped = core.PaginatedResult<section_domain.Section>(
          items: cachedSections.items.map((m) => m.toEntity()).toList(),
          pageNumber: cachedSections.pageNumber,
          pageSize: cachedSections.pageSize,
          totalCount: cachedSections.totalCount,
          metadata: cachedSections.metadata,
        );
        return Right(mapped);
      } catch (e) {
        return const Left(
            NetworkFailure('لا يوجد اتصال بالإنترنت ولا توجد بيانات محفوظة'));
      }
    }
  }

  @override
  Future<Either<Failure, core.PaginatedResult<SectionPropertyItemModel>>>
      getSectionPropertyItems({
    required String sectionId,
    int pageNumber = 1,
    int pageSize = 10,
    bool forceRefresh = false,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // نحتسب فتح عناصر القسم كإشارة إلى أن المستخدم وصل فعلًا إلى هذا
        // المحتوى.
        // Treat opening section items as a signal that the user actually
        // reached this content.
        await recordSectionImpression(sectionId: sectionId);

        // نجلب الصفحة الجديدة من الخادم ما دمنا متصلين.
        // Fetch the fresh page from the backend while connectivity exists.
        final result = await remoteDataSource.getSectionPropertyItems(
          sectionId: sectionId,
          pageNumber: pageNumber,
          pageSize: pageSize,
        );

        // نخزن النتيجة حتى تبقى متاحة لو احتجنا الرجوع إليها لاحقًا.
        // Cache the result so it remains available for later fallback.
        await localDataSource.cacheSectionPropertyItems(
          sectionId: sectionId,
          items: result.items,
        );

        return Right(result);
      } catch (e) {
        // إذا أخفق الطلب البعيد نعيد المحاولة من النسخة المحلية.
        // If the remote request fails, retry against the local snapshot.
        try {
          final cachedItems =
              await localDataSource.getCachedSectionPropertyItems(
            sectionId: sectionId,
            pageNumber: pageNumber,
            pageSize: pageSize,
          );
          return Right(cachedItems);
        } catch (cacheError) {
          return ErrorHandler.handle(e);
        }
      }
    } else {
      // من دون شبكة نرجع مباشرة إلى البيانات المخزنة لهذا القسم.
      // Without connectivity, fall back directly to stored section data.
      try {
        final cachedItems = await localDataSource.getCachedSectionPropertyItems(
          sectionId: sectionId,
          pageNumber: pageNumber,
          pageSize: pageSize,
        );
        return Right(cachedItems);
      } catch (e) {
        return const Left(
            NetworkFailure('لا يوجد اتصال بالإنترنت ولا توجد بيانات محفوظة'));
      }
    }
  }

  @override
  Future<Either<Failure, List<domain.PropertyType>>> getPropertyTypes() async {
    if (await networkInfo.isConnected) {
      try {
        // نجلب أحدث أنواع العقارات من الخادم لتغذية واجهة الاختيار الأولى.
        // Fetch the latest property types from the backend for the primary
        // selector UI.
        final result = await remoteDataSource.getPropertyTypes();

        // نخزن النسخة الحديثة محليًا حتى تبقى متاحة للجلسات التالية.
        // Save the fresh copy locally so it remains available in later sessions.
        await localDataSource.cachePropertyTypes(result);

        return Right(result.map((model) => model.toEntity()).toList());
      } catch (e) {
        // إذا تعذر الجلب البعيد نعود إلى الكاش بدل إسقاط التدفق.
        // If the remote fetch fails, fall back to cache rather than breaking
        // the flow.
        try {
          final cachedTypes = await localDataSource.getCachedPropertyTypes();
          return Right(cachedTypes.map((model) => model.toEntity()).toList());
        } catch (cacheError) {
          return ErrorHandler.handle(e);
        }
      }
    } else {
      // في وضع عدم الاتصال نستخدم الكاش مباشرة لأنه المصدر الوحيد المتاح.
      // In offline mode, use the cache directly because it is the only
      // available source.
      try {
        final cachedTypes = await localDataSource.getCachedPropertyTypes();
        return Right(cachedTypes.map((model) => model.toEntity()).toList());
      } catch (e) {
        return const Left(
            NetworkFailure('لا يوجد اتصال بالإنترنت ولا توجد بيانات محفوظة'));
      }
    }
  }

  @override
  Future<Either<Failure, List<domain.UnitType>>> getUnitTypes({
    required String propertyTypeId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // نجلب أحدث أنواع الوحدات التابعة لنوع العقار المختار من الخادم.
        // Fetch the latest unit types for the selected property type from the
        // backend.
        final result = await remoteDataSource.getUnitTypes(
          propertyTypeId: propertyTypeId,
        );

        // نخزن النتيجة حتى تبقى مرتبطة بنوع العقار نفسه للاستخدام اللاحق.
        // Cache the result so it remains available for the same property-type
        // context later.
        await localDataSource.cacheUnitTypes(
          propertyTypeId: propertyTypeId,
          unitTypes: result,
        );

        return Right(result.map((model) => model.toEntity()).toList());
      } catch (e) {
        // إذا فشل المصدر البعيد نحاول إنقاذ الطلب من الكاش المحلي.
        // If the remote source fails, try to fulfill the request from local
        // cache.
        try {
          final cachedTypes = await localDataSource.getCachedUnitTypes(
            propertyTypeId: propertyTypeId,
          );
          return Right(cachedTypes.map((model) => model.toEntity()).toList());
        } catch (cacheError) {
          return ErrorHandler.handle(e);
        }
      }
    } else {
      // من دون شبكة نعيد البيانات المخزنة لهذا النوع مباشرة.
      // Without connectivity, return the cached data for this type directly.
      try {
        final cachedTypes = await localDataSource.getCachedUnitTypes(
          propertyTypeId: propertyTypeId,
        );
        return Right(cachedTypes.map((model) => model.toEntity()).toList());
      } catch (e) {
        return const Left(
            NetworkFailure('لا يوجد اتصال بالإنترنت ولا توجد بيانات محفوظة'));
      }
    }
  }
}
