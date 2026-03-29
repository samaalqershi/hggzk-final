# مصفوفة المطابقة بين الكود والتوثيق

> الغرض من هذا الملف هو توفير تدقيق شبه ميكانيكي يربط عناصر الكود الأساسية بمواضع تغطيتها داخل الملفات التوثيقية الحالية.
>
> الملفات المرجعية:
>
> - `CODECANYON_HGGZK_PRODUCT_PROFILE_AR.md`
> - `CODECANYON_HGGZKAPP_FULL_PROFILE_AR.md`
> - `CODECANYON_HGGZKPORTAL_FULL_PROFILE_AR.md`

## 1. الملخص العددي

| النطاق | العدد المفحوص | المرجع التوثيقي الأساسي |
|---|---:|---|
| Controllers في `backend` | 74 | `CODECANYON_HGGZK_PRODUCT_PROFILE_AR.md` |
| Features في `backend/hggzk.Application` | 25 | `CODECANYON_HGGZK_PRODUCT_PROFILE_AR.md` |
| Pages في `hggzk_app` | 41 | `CODECANYON_HGGZKAPP_FULL_PROFILE_AR.md` |
| Pages في `hggzkportal_app` | 85 | `CODECANYON_HGGZKPORTAL_FULL_PROFILE_AR.md` |

## 2. شرح حالة التغطية

| الحالة | المعنى |
|---|---|
| `Covered` | العنصر مذكور بوضوح أو مغطى مباشرة في قسم/فقرة محددة |
| `Covered (Grouped)` | العنصر مغطى ضمن مجموعة وظيفية أو نطاق أكبر وليس بوصف منفصل باسمه |
| `Infra / Support` | العنصر بنيوي/مساند وغير مهم عادة كميزة بيع مستقلة، لكنه تم التحقق من موضعه الوظيفي |

## 3. مطابقة Features طبقة التطبيق في الباك إند

| Feature | الحالة | موضع التغطية |
|---|---|---|
| `Accounting` | Covered | `Product Profile` §4.11, §5.2 |
| `Amenities` | Covered | `Product Profile` §5.1, §5.2 |
| `Analytics` | Covered | `Product Profile` §4.10, §5.2 |
| `AuditLog` | Covered | `Product Profile` §4.10, §5.1, §5.2 |
| `Authentication` | Covered | `Product Profile` §4.13, §5.2 |
| `Bookings` | Covered | `Product Profile` §4.6, §5.2 |
| `Chat` | Covered | `Product Profile` §4.8, §5.2 |
| `DailySchedules` | Covered | `Product Profile` §5.1, §7.1, §12 |
| `DynamicFields` | Covered | `Product Profile` §4.2, §4.3, §5.2 |
| `Favorites` | Covered | `Product Profile` §6.2, §12 |
| `Notifications` | Covered | `Product Profile` §4.9, §5.2 |
| `Payments` | Covered | `Product Profile` §4.7, §5.2 |
| `Policies` | Covered | `Product Profile` §5.1, §5.2, §7.1 |
| `Properties` | Covered | `Product Profile` §5.1, §5.2, §7.1 |
| `PropertyServices` | Covered | `Product Profile` §5.1, §5.2 |
| `PropertyTypes` | Covered | `Product Profile` §4.2, §5.1, §7.1 |
| `Reports` | Covered | `Product Profile` §4.10, §4.15, §5.1 |
| `Reviews` | Covered | `Product Profile` §5.1, §6.2, §7.1 |
| `Scheduling` | Covered | `Product Profile` §4.16, §5.2 |
| `SearchAndFilters` | Covered | `Product Profile` §4.4, §4.5, §4.10, §5.2 |
| `Sections` | Covered | `Product Profile` §4.1, §5.1, §7.1 |
| `Staffs` | Covered | `Product Profile` §5.1, §5.2 |
| `Support` | Covered | `Product Profile` §5.1, §6.1, §7.1 |
| `Units` | Covered | `Product Profile` §4.2, §4.6, §5.1, §5.2, §7.1 |
| `Users` | Covered | `Product Profile` §5.1, §5.2, §7.1 |

## 4. مطابقة Controllers الباك إند

### 4.1 Admin Controllers

| Controller | الحالة | موضع التغطية |
|---|---|---|
| `Admin/AccountingController.cs` | Covered | `Product Profile` §4.11, §5.1 |
| `Admin/AmenitiesController.cs` | Covered | `Product Profile` §5.1, §7.1 |
| `Admin/AuditLogsController.cs` | Covered | `Product Profile` §4.10, §5.1 |
| `Admin/BaseAdminController.cs` | Infra / Support | `Product Profile` §3.1, §4.15 |
| `Admin/BookingsController.cs` | Covered | `Product Profile` §4.6, §5.1, §7.1 |
| `Admin/DailyScheduleController.cs` | Covered | `Product Profile` §5.1, §7.1, §12 |
| `Admin/DashboardController.cs` | Covered | `Product Profile` §4.10, §5.1 |
| `Admin/FieldGroupsController.cs` | Covered | `Product Profile` §4.3, §4.15 |
| `Admin/FinancialReportsController.cs` | Covered | `Product Profile` §4.10, §4.11, §5.1 |
| `Admin/FloskController.cs` | Covered | `Product Profile` §4.7, §4.15 |
| `Admin/NotificationChannelsController.cs` | Covered | `Product Profile` §4.9, §5.1 |
| `Admin/NotificationsController.cs` | Covered | `Product Profile` §4.9, §5.1 |
| `Admin/PaymentsController.cs` | Covered | `Product Profile` §4.7, §5.1 |
| `Admin/PropertiesController.cs` | Covered | `Product Profile` §5.1, §7.1 |
| `Admin/PropertyInSectionImagesController.cs` | Covered | `Product Profile` §4.1, §4.12, §7.1 |
| `Admin/PropertyPoliciesController.cs` | Covered | `Product Profile` §5.1, §7.1 |
| `Admin/PropertyServicesController.cs` | Covered | `Product Profile` §5.1, §7.1 |
| `Admin/PropertyTypesController.cs` | Covered | `Product Profile` §4.2, §5.1, §7.1 |
| `Admin/ReportsController.cs` | Covered | `Product Profile` §4.10, §5.1 |
| `Admin/ReviewsController.cs` | Covered | `Product Profile` §5.1, §6.2, §7.1 |
| `Admin/RolesController.cs` | Covered | `Product Profile` §4.16, §5.1, §4.13 |
| `Admin/SearchAnalyticsController.cs` | Covered | `Product Profile` §4.10, §4.15 |
| `Admin/SearchFiltersAnalyticsController.cs` | Covered | `Product Profile` §4.10, §4.15 |
| `Admin/SearchLogsController.cs` | Covered | `Product Profile` §4.10, §4.15 |
| `Admin/SectionImagesController.cs` | Covered | `Product Profile` §4.1, §4.12, §7.1 |
| `Admin/SectionsController.cs` | Covered | `Product Profile` §4.1, §5.1, §7.1 |
| `Admin/StaffController.cs` | Covered | `Product Profile` §5.1, §5.2 |
| `Admin/StatisticsController.cs` | Covered | `Product Profile` §4.10, §5.1 |
| `Admin/SystemSettingsController.cs` | Covered | `Product Profile` §5.1, §4.15 |
| `Admin/UnitInSectionImagesController.cs` | Covered | `Product Profile` §4.1, §4.12, §7.1 |
| `Admin/UnitTypeFieldsController.cs` | Covered | `Product Profile` §4.2, §4.15 |
| `Admin/UnitTypesController.cs` | Covered | `Product Profile` §4.2, §5.1, §7.1 |
| `Admin/UnitsController.cs` | Covered | `Product Profile` §4.2, §4.6, §5.1, §7.1 |
| `Admin/UploadImageController.cs` | Covered | `Product Profile` §4.12, §4.15 |
| `Admin/UsersController.cs` | Covered | `Product Profile` §5.1, §7.1 |

### 4.2 Client Controllers

| Controller | الحالة | موضع التغطية |
|---|---|---|
| `Client/AiAssistantController.cs` | Covered | `Product Profile` §4.15, §6.2 |
| `Client/AmenitiesController.cs` | Covered | `Product Profile` §4.4, §5.1 |
| `Client/AnalyticsController.cs` | Covered | `Product Profile` §4.10, §6.2 |
| `Client/AuthController.cs` | Covered | `Product Profile` §4.13, §6.1 |
| `Client/BaseClientController.cs` | Infra / Support | `Product Profile` §3.1 |
| `Client/BookingController.cs` | Covered | `Product Profile` §4.6, §6.1 |
| `Client/FavoritesController.cs` | Covered | `Product Profile` §6.2, §12 |
| `Client/GeneralController.cs` | Covered | `Product Profile` §4.16 |
| `Client/NotificationsController.cs` | Covered | `Product Profile` §4.9, §6.1 |
| `Client/PaymentsController.cs` | Covered | `Product Profile` §4.7, §6.1 |
| `Client/PropertiesController.cs` | Covered | `Product Profile` §4.4, §6.1 |
| `Client/PropertyServicesController.cs` | Covered | `Product Profile` §4.6, §5.1 |
| `Client/PropertyTypesController.cs` | Covered | `Product Profile` §4.4, §6.1 |
| `Client/ReportsController.cs` | Covered | `Product Profile` §4.16 |
| `Client/ReviewsController.cs` | Covered | `Product Profile` §6.1, §6.2 |
| `Client/SearchController.cs` | Covered | `Product Profile` §4.4, §4.5, §6.2 |
| `Client/SearchFiltersController.cs` | Covered | `Product Profile` §4.4, §4.10, §6.2 |
| `Client/SectionsController.cs` | Covered | `Product Profile` §4.1, §6.2 |
| `Client/SettingsController.cs` | Covered | `Product Profile` §6.1, §6.2 |
| `Client/StatisticsController.cs` | Covered | `Product Profile` §4.16 |
| `Client/SupportController.cs` | Covered | `Product Profile` §5.1, §6.1 |
| `Client/UnitTypesController.cs` | Covered | `Product Profile` §4.2, §4.4, §6.2 |
| `Client/UnitsController.cs` | Covered | `Product Profile` §4.4, §6.1 |

### 4.3 Common / Infra Controllers

| Controller | الحالة | موضع التغطية |
|---|---|---|
| `Common/AuthController.cs` | Covered | `Product Profile` §4.16, §4.13, §4.15 |
| `Common/BaseCommonController.cs` | Infra / Support | `Product Profile` §3.1, §4.15 |
| `Common/ChatAttachmentController.cs` | Covered | `Product Profile` §4.8, §4.15 |
| `Common/ChatController.cs` | Covered | `Product Profile` §4.8, §4.15 |
| `Common/FcmController.cs` | Covered | `Product Profile` §4.9, §4.14, §4.15 |
| `Common/NotificationsController.cs` | Covered | `Product Profile` §4.9, §4.15 |
| `Common/PropertiesController.cs` | Covered | `Product Profile` §4.16, §4.15 |
| `Common/SearchController.cs` | Covered | `Product Profile` §4.4, §4.5, §4.15 |
| `Common/SystemSettingsController.cs` | Covered | `Product Profile` §4.15, §5.1 |
| `Common/UsersController.cs` | Covered | `Product Profile` §5.1, §4.15 |
| `CallbacksController.cs` | Covered | `Product Profile` §4.13, §4.15 |
| `HealthCheckController.cs` | Covered | `Product Profile` §4.14, §4.15 |
| `Images/ImagesController.cs` | Covered | `Product Profile` §4.12, §4.15 |
| `Images/UploadImageRequest.cs` | Infra / Support | `Product Profile` §4.12 |
| `SearchController.cs` | Covered | `Product Profile` §4.16, §4.4, §4.5 |
| `TestLastSeenController.cs` | Covered | `Product Profile` §4.16, §4.8, §4.15 |

## 5. مطابقة صفحات تطبيق العميل `hggzk_app`

> جميع صفحات العميل موثقة بالاسم داخل `CODECANYON_HGGZKAPP_FULL_PROFILE_AR.md` §6، لذلك الربط هنا مباشر ودقيق مثل ملف البورتال.

| Page Path | العنصر الموثق | الحالة | موضع التغطية |
|---|---|---|---|
| `app/presentation/pages/main_shell_page.dart` | `MainScreen` | Covered | `Client Profile` §6.1 / item 1 |
| `features/ai_assistant/presentation/pages/ai_chat_page.dart` | `AiChatPage` | Covered | `Client Profile` §6.9 / item 41 |
| `features/auth/presentation/pages/change_password_page.dart` | `ChangePasswordPage` | Covered | `Client Profile` §6.2 / item 10 |
| `features/auth/presentation/pages/edit_profile_page.dart` | `EditProfilePage` | Covered | `Client Profile` §6.2 / item 9 |
| `features/auth/presentation/pages/forgot_password_page.dart` | `ForgotPasswordPage` | Covered | `Client Profile` §6.2 / item 6 |
| `features/auth/presentation/pages/login_page.dart` | `LoginPage` | Covered | `Client Profile` §6.2 / item 4 |
| `features/auth/presentation/pages/profile_page.dart` | `ProfilePage` | Covered | `Client Profile` §6.2 / item 8 |
| `features/auth/presentation/pages/register_page.dart` | `RegisterPage` | Covered | `Client Profile` §6.2 / item 5 |
| `features/auth/presentation/pages/verify_email_modern_page.dart` | `VerifyEmailModernPage` | Covered | `Client Profile` §6.2 / item 7 |
| `features/booking/presentation/pages/booking_confirmation_page.dart` | `BookingConfirmationPage` | Covered | `Client Profile` §6.6 / item 24 |
| `features/booking/presentation/pages/booking_details_page.dart` | `BookingDetailsPage` | Covered | `Client Profile` §6.6 / item 25 |
| `features/booking/presentation/pages/booking_form_page.dart` | `BookingFormPage` | Covered | `Client Profile` §6.6 / item 21 |
| `features/booking/presentation/pages/booking_payment_page.dart` | `BookingPaymentPage` | Covered | `Client Profile` §6.6 / item 23 |
| `features/booking/presentation/pages/booking_summary_page.dart` | `BookingSummaryPage` | Covered | `Client Profile` §6.6 / item 22 |
| `features/booking/presentation/pages/my_bookings_page.dart` | `MyBookingsPage` | Covered | `Client Profile` §6.6 / item 26 |
| `features/chat/presentation/pages/chat_page.dart` | `ChatPage` | Covered | `Client Profile` §6.9 / item 38 |
| `features/chat/presentation/pages/chat_settings_page.dart` | `ChatSettingsPage` | Covered | `Client Profile` §6.9 / item 40 |
| `features/chat/presentation/pages/conversations_page.dart` | `ConversationsPage` | Covered | `Client Profile` §6.9 / item 37 |
| `features/chat/presentation/pages/new_conversation_page.dart` | `NewConversationPage` | Covered | `Client Profile` §6.9 / item 39 |
| `features/favorites/presentation/pages/favorites_page.dart` | `FavoritesPage` | Covered | `Client Profile` §6.7 / item 29 |
| `features/home/presentation/pages/all_sections_page.dart` | `AllSectionsPage` | Covered | `Client Profile` §6.3 / item 12 |
| `features/home/presentation/pages/futuristic_home_page.dart` | `HomePage` | Covered | `Client Profile` §6.3 / item 11 |
| `features/home/presentation/pages/section_details_page.dart` | `SectionDetailsPage` | Covered | `Client Profile` §6.3 / item 13 |
| `features/notifications/presentation/pages/notification_settings_page.dart` | `NotificationSettingsPage` | Covered | `Client Profile` §6.8 / item 31 |
| `features/notifications/presentation/pages/notifications_page.dart` | `NotificationsPage` | Covered | `Client Profile` §6.8 / item 30 |
| `features/onboarding/presentation/pages/select_city_currency_page.dart` | `SelectCityCurrencyPage` | Covered | `Client Profile` §6.1 / item 3 |
| `features/property/presentation/pages/property_details_page.dart` | `PropertyDetailsPage` | Covered | `Client Profile` §6.5 / item 17 |
| `features/property/presentation/pages/property_gallery_page.dart` | `PropertyGalleryPage` | Covered | `Client Profile` §6.5 / item 18 |
| `features/property/presentation/pages/property_units_page.dart` | `PropertyUnitsPage` | Covered | `Client Profile` §6.5 / item 19 |
| `features/property/presentation/pages/unit_gallery_page.dart` | `UnitGalleryPage` | Covered | `Client Profile` §6.5 / item 20 |
| `features/review/presentation/pages/reviews_list_page.dart` | `ReviewsListPage` | Covered | `Client Profile` §6.7 / item 27 |
| `features/review/presentation/pages/write_review_page.dart` | `WriteReviewPage` | Covered | `Client Profile` §6.7 / item 28 |
| `features/search/presentation/pages/search_filters_page.dart` | `SearchFiltersPage` | Covered | `Client Profile` §6.4 / item 15 |
| `features/search/presentation/pages/search_page.dart` | `SearchPage` | Covered | `Client Profile` §6.4 / item 14 |
| `features/search/presentation/pages/search_results_map_page.dart` | `SearchResultsMapPage` | Covered | `Client Profile` §6.4 / item 16 |
| `features/settings/presentation/pages/in_app_webview_page.dart` | `InAppWebViewPage` | Covered | `Client Profile` §6.8 / item 35 |
| `features/settings/presentation/pages/language_settings_page.dart` | `LanguageSettingsPage` | Covered | `Client Profile` §6.8 / item 33 |
| `features/settings/presentation/pages/legal_documents_page.dart` | `LegalDocumentsPage` | Covered | `Client Profile` §6.8 / item 34 |
| `features/settings/presentation/pages/settings_page.dart` | `SettingsPage` | Covered | `Client Profile` §6.8 / item 32 |
| `features/splash/presentation/pages/splash_screen.dart` | `SplashScreen` | Covered | `Client Profile` §6.1 / item 2 |
| `features/support/presentation/pages/support_page.dart` | `SupportPage` | Covered | `Client Profile` §6.8 / item 36 |

## 6. مطابقة صفحات تطبيق البورتال `hggzkportal_app`

> جميع صفحات البورتال موثقة بالاسم داخل `CODECANYON_HGGZKPORTAL_FULL_PROFILE_AR.md` §6، لذلك الربط هنا مباشر ودقيق.

| Page Path | العنصر الموثق | الحالة | موضع التغطية |
|---|---|---|---|
| `app/presentation/pages/futuristic_main_screen.dart` | `MainScreen` | Covered | `Portal Profile` §6.1 / item 1 |
| `app/presentation/pages/splash_screen.dart` | `SplashScreen` | Covered | `Portal Profile` §6.1 / item 2 |
| `features/admin_amenities/presentation/pages/amenities_management_page.dart` | `AmenitiesManagementPage` | Covered | `Portal Profile` §6.8 / item 33 |
| `features/admin_amenities/presentation/pages/create_amenity_page.dart` | `CreateAmenityPage` | Covered | `Portal Profile` §6.8 / item 34 |
| `features/admin_amenities/presentation/pages/edit_amenity_page.dart` | `EditAmenityPage` | Covered | `Portal Profile` §6.8 / item 35 |
| `features/admin_audit_logs/presentation/pages/audit_logs_page.dart` | `AuditLogsPage` | Covered | `Portal Profile` §6.21 / item 84 |
| `features/admin_bookings/presentation/pages/booking_analytics_page.dart` | `BookingAnalyticsPage` | Covered | `Portal Profile` §6.18 / item 73 |
| `features/admin_bookings/presentation/pages/booking_audit_timeline_page.dart` | `BookingAuditTimelinePage` | Covered | `Portal Profile` §6.18 / item 71 |
| `features/admin_bookings/presentation/pages/booking_calendar_page.dart` | `BookingCalendarPage` | Covered | `Portal Profile` §6.18 / item 72 |
| `features/admin_bookings/presentation/pages/booking_details_page.dart` | `BookingDetailsPage` | Covered | `Portal Profile` §6.18 / item 69 |
| `features/admin_bookings/presentation/pages/booking_timeline_page.dart` | `BookingTimelinePage` | Covered | `Portal Profile` §6.18 / item 70 |
| `features/admin_bookings/presentation/pages/bookings_list_page.dart` | `BookingsListPage` | Covered | `Portal Profile` §6.18 / item 68 |
| `features/admin_bookings/presentation/pages/register_payment_page.dart` | `RegisterPaymentPage` | Covered | `Portal Profile` §6.18 / item 74 |
| `features/admin_cities/presentation/pages/admin_cities_page.dart` | `AdminCitiesPage` | Covered | `Portal Profile` §6.6 / item 29 |
| `features/admin_cities/presentation/pages/city_form_page.dart` | `CityFormPage` | Covered | `Portal Profile` §6.6 / item 30 |
| `features/admin_currencies/presentation/pages/currencies_management_page.dart` | `CurrenciesManagementPage` | Covered | `Portal Profile` §6.6 / item 31 |
| `features/admin_daily_schedule/presentation/pages/daily_schedule_page.dart` | `DailySchedulePage` | Covered | `Portal Profile` §6.22 / item 85 |
| `features/admin_financial/presentation/pages/chart_of_accounts_page.dart` | `ChartOfAccountsPage` | Covered | `Portal Profile` §6.20 / item 81 |
| `features/admin_financial/presentation/pages/financial_dashboard_page.dart` | `FinancialDashboardPage` | Covered | `Portal Profile` §6.20 / item 80 |
| `features/admin_financial/presentation/pages/financial_settings_page.dart` | `FinancialSettingsPage` | Covered | `Portal Profile` §6.20 / item 83 |
| `features/admin_financial/presentation/pages/transactions_list_page.dart` | `TransactionsListPage` | Covered | `Portal Profile` §6.20 / item 82 |
| `features/admin_hub/presentation/pages/admin_hub_page.dart` | `AdminHubPage` | Covered | `Portal Profile` §6.1 / item 3 |
| `features/admin_notifications/presentation/pages/admin_notifications_page.dart` | `AdminNotificationsPage` | Covered | `Portal Profile` §6.16 / item 60 |
| `features/admin_notifications/presentation/pages/create_admin_notification_page.dart` | `CreateAdminNotificationPage` | Covered | `Portal Profile` §6.16 / item 61 |
| `features/admin_notifications/presentation/pages/user_notifications_page.dart` | `UserNotificationsPage` | Covered | `Portal Profile` §6.16 / item 62 |
| `features/admin_notifications/presentation/pages/user_selector_page.dart` | `AdminUserSelectorPage` | Covered | `Portal Profile` §6.16 / item 63 |
| `features/admin_payments/presentation/pages/payment_analytics_page.dart` | `PaymentAnalyticsPage` | Covered | `Portal Profile` §6.19 / item 77 |
| `features/admin_payments/presentation/pages/payment_details_page.dart` | `PaymentDetailsPage` | Covered | `Portal Profile` §6.19 / item 76 |
| `features/admin_payments/presentation/pages/payments_list_page.dart` | `PaymentsListPage` | Covered | `Portal Profile` §6.19 / item 75 |
| `features/admin_payments/presentation/pages/refunds_management_page.dart` | `RefundsManagementPage` | Covered | `Portal Profile` §6.19 / item 78 |
| `features/admin_payments/presentation/pages/revenue_dashboard_page.dart` | `RevenueDashboardPage` | Covered | `Portal Profile` §6.19 / item 79 |
| `features/admin_policies/presentation/pages/create_policy_page.dart` | `CreatePolicyPage` | Covered | `Portal Profile` §6.10 / item 40 |
| `features/admin_policies/presentation/pages/edit_policy_page.dart` | `EditPolicyPage` | Covered | `Portal Profile` §6.10 / item 41 |
| `features/admin_policies/presentation/pages/policies_management_page.dart` | `PoliciesManagementPage` | Covered | `Portal Profile` §6.10 / item 39 |
| `features/admin_properties/presentation/pages/create_property_page.dart` | `CreatePropertyPage` | Covered | `Portal Profile` §6.11 / item 43 |
| `features/admin_properties/presentation/pages/edit_property_page.dart` | `EditPropertyPage` | Covered | `Portal Profile` §6.11 / item 44 |
| `features/admin_properties/presentation/pages/properties_list_page.dart` | `PropertiesListPage` | Covered | `Portal Profile` §6.11 / item 42 |
| `features/admin_properties/presentation/pages/property_details_page.dart` | `PropertyDetailsPage` | Covered | `Portal Profile` §6.11 / item 45 |
| `features/admin_reviews/presentation/pages/review_details_page.dart` | `ReviewDetailsPage` | Covered | `Portal Profile` §6.14 / item 56 |
| `features/admin_reviews/presentation/pages/reviews_list_page.dart` | `ReviewsListPage` | Covered | `Portal Profile` §6.14 / item 55 |
| `features/admin_sections/presentation/pages/create_section_page.dart` | `CreateSectionPage` | Covered | `Portal Profile` §6.13 / item 52 |
| `features/admin_sections/presentation/pages/edit_section_page.dart` | `EditSectionPage` | Covered | `Portal Profile` §6.13 / item 53 |
| `features/admin_sections/presentation/pages/section_items_management_page.dart` | `SectionItemsManagementPage` | Covered | `Portal Profile` §6.13 / item 54 |
| `features/admin_sections/presentation/pages/sections_list_page.dart` | `SectionsListPage` | Covered | `Portal Profile` §6.13 / item 51 |
| `features/admin_services/presentation/pages/admin_services_page.dart` | `AdminServicesPage` | Covered | `Portal Profile` §6.9 / item 36 |
| `features/admin_services/presentation/pages/create_service_page.dart` | `CreateServicePage` | Covered | `Portal Profile` §6.9 / item 37 |
| `features/admin_services/presentation/pages/edit_service_page.dart` | `EditServicePage` | Covered | `Portal Profile` §6.9 / item 38 |
| `features/admin_units/presentation/pages/create_unit_page.dart` | `CreateUnitPage` | Covered | `Portal Profile` §6.12 / item 47 |
| `features/admin_units/presentation/pages/edit_unit_page.dart` | `EditUnitPage` | Covered | `Portal Profile` §6.12 / item 48 |
| `features/admin_units/presentation/pages/unit_details_page.dart` | `UnitDetailsPage` | Covered | `Portal Profile` §6.12 / item 49 |
| `features/admin_units/presentation/pages/unit_gallery_page.dart` | `UnitGalleryPage` | Covered | `Portal Profile` §6.12 / item 50 |
| `features/admin_units/presentation/pages/units_list_page.dart` | `UnitsListPage` | Covered | `Portal Profile` §6.12 / item 46 |
| `features/admin_users/presentation/pages/create_user_page.dart` | `CreateUserPage` | Covered | `Portal Profile` §6.15 / item 58 |
| `features/admin_users/presentation/pages/user_details_page.dart` | `UserDetailsPage` | Covered | `Portal Profile` §6.15 / item 59 |
| `features/admin_users/presentation/pages/users_list_page.dart` | `UsersListPage` | Covered | `Portal Profile` §6.15 / item 57 |
| `features/auth/presentation/pages/change_password_page.dart` | `ChangePasswordPage` | Covered | `Portal Profile` §6.2 / item 11 |
| `features/auth/presentation/pages/edit_profile_page.dart` | `EditProfilePage` | Covered | `Portal Profile` §6.2 / item 10 |
| `features/auth/presentation/pages/forgot_password_page.dart` | `ForgotPasswordPage` | Covered | `Portal Profile` §6.2 / item 7 |
| `features/auth/presentation/pages/login_page.dart` | `LoginPage` | Covered | `Portal Profile` §6.2 / item 5 |
| `features/auth/presentation/pages/profile_page.dart` | `ProfilePage` | Covered | `Portal Profile` §6.2 / item 9 |
| `features/auth/presentation/pages/register_page.dart` | `RegisterPage` | Covered | `Portal Profile` §6.2 / item 6 |
| `features/auth/presentation/pages/verify_email_page.dart` | `VerifyEmailPage` | Covered | `Portal Profile` §6.2 / item 8 |
| `features/chat/presentation/pages/chat_page.dart` | `ChatPage` | Covered | `Portal Profile` §6.4 / item 21 |
| `features/chat/presentation/pages/chat_settings_page.dart` | `ChatSettingsPage` | Covered | `Portal Profile` §6.4 / item 23 |
| `features/chat/presentation/pages/conversations_page.dart` | `ConversationsPage` | Covered | `Portal Profile` §6.4 / item 20 |
| `features/chat/presentation/pages/new_conversation_page.dart` | `NewConversationPage` | Covered | `Portal Profile` §6.4 / item 22 |
| `features/helpers/presentation/pages/booking_search_page.dart` | `BookingSearchPage` | Covered | `Portal Profile` §6.5 / item 24 |
| `features/helpers/presentation/pages/city_search_page.dart` | `CitySearchPage` | Covered | `Portal Profile` §6.5 / item 25 |
| `features/helpers/presentation/pages/property_search_page.dart` | `PropertySearchPage` | Covered | `Portal Profile` §6.5 / item 26 |
| `features/helpers/presentation/pages/unit_search_page.dart` | `UnitSearchPage` | Covered | `Portal Profile` §6.5 / item 27 |
| `features/helpers/presentation/pages/user_search_page.dart` | `UserSearchPage` | Covered | `Portal Profile` §6.5 / item 28 |
| `features/notification_channels/presentation/pages/channel_users_management_page.dart` | `ChannelUsersManagementPage` | Covered | `Portal Profile` §6.17 / item 67 |
| `features/notification_channels/presentation/pages/channels_management_page.dart` | `ChannelsManagementPage` | Covered | `Portal Profile` §6.17 / item 64 |
| `features/notification_channels/presentation/pages/create_channel_page.dart` | `CreateChannelPage` | Covered | `Portal Profile` §6.17 / item 65 |
| `features/notification_channels/presentation/pages/edit_channel_page.dart` | `EditChannelPage` | Covered | `Portal Profile` §6.17 / item 66 |
| `features/notifications/presentation/pages/notification_settings_page.dart` | `NotificationSettingsPage` | Covered | `Portal Profile` §6.3 / item 13 |
| `features/notifications/presentation/pages/notifications_page.dart` | `NotificationsPage` | Covered | `Portal Profile` §6.3 / item 12 |
| `features/onboarding/presentation/pages/select_city_currency_page.dart` | `SelectCityCurrencyPage` | Covered | `Portal Profile` §6.1 / item 4 |
| `features/property_types/presentation/pages/property_types_page.dart` | `AdminPropertyTypesPage` | Covered | `Portal Profile` §6.7 / item 32 |
| `features/settings/presentation/pages/about_page.dart` | `AboutPage` | Covered | `Portal Profile` §6.3 / item 18 |
| `features/settings/presentation/pages/in_app_webview_page.dart` | `InAppWebViewPage` | Covered | `Portal Profile` §6.3 / item 17 |
| `features/settings/presentation/pages/language_settings_page.dart` | `LanguageSettingsPage` | Covered | `Portal Profile` §6.3 / item 15 |
| `features/settings/presentation/pages/legal_documents_page.dart` | `LegalDocumentsPage` | Covered | `Portal Profile` §6.3 / item 16 |
| `features/settings/presentation/pages/settings_page.dart` | `SettingsPage` | Covered | `Portal Profile` §6.3 / item 14 |
| `features/support/presentation/pages/support_page.dart` | `SupportPage` | Covered | `Portal Profile` §6.3 / item 19 |

## 7. ملاحظات ختامية

| الملاحظة | النتيجة |
|---|---|
| كل صفحات `hggzkportal_app` الحالية موثقة بالاسم | نعم |
| كل صفحات `hggzk_app` الحالية مغطاة ضمن ملف المنتج العام | نعم |
| Features طبقة `Application` في الباك إند مغطاة | نعم |
| Controllers الباك إند المهمة مغطاة صراحة أو ضمن نطاقاتها الوظيفية | نعم |
| العناصر البنيوية غير التسويقية مثل `Base*` أو request/support files | تم تعليمها كـ `Infra / Support` |

الخلاصة:

هذه المصفوفة لا تعني أن التوثيق يشرح كل سطر برمجي، لكنها تؤكد أن العناصر الكبيرة والمهمة تجاريًا ووظيفيًا في النظام أصبحت مرتبطة بوضوح مع مواضع شرحها داخل ملفات التوثيق الحالية.
