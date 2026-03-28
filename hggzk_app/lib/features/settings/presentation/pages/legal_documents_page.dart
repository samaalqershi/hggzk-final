import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

/// تعرض نقطة دخول موحدة للسياسات والصفحات القانونية حتى يصل المستخدم
/// بسرعة إلى المستند المناسب دون مغادرة سياق الإعدادات.
/// Presents a single entry point for legal and policy pages so the user can
/// reach the right document without leaving the settings flow.
class LegalDocumentsPage extends StatelessWidget {
  /// الرابط الأساسي الذي تُبنى فوقه المسارات القانونية الداخلية.
  /// The base URL used to resolve the internal legal-document paths.
  final String baseUrl;

  /// Creates the legal-documents page with the site's base URL.
  const LegalDocumentsPage({
    super.key,
    required this.baseUrl,
  });

  /// يبني قائمة الاختصارات القانونية التي تظهر للمستخدم بحسب الصفحة
  /// المتاحة على الموقع.
  /// Builds the set of legal shortcuts shown to the user based on the pages
  /// available on the site.
  List<_LegalItem> _items() {
    return [
      _LegalItem(
        title: 'سياسة الخصوصية',
        path: '/privacy',
        icon: Icons.privacy_tip_rounded,
        color: AppTheme.primaryCyan,
      ),
      _LegalItem(
        title: 'كيف نعمل',
        path: '/how-we-work',
        icon: Icons.lightbulb_outline_rounded,
        color: AppTheme.primaryBlue,
      ),
      _LegalItem(
        title: 'شروط الشركاء',
        path: '/terms-partners',
        icon: Icons.handshake_rounded,
        color: AppTheme.success,
      ),
      _LegalItem(
        title: 'شروط العملاء',
        path: '/terms-customers',
        icon: Icons.receipt_long_rounded,
        color: AppTheme.warning,
      ),
      _LegalItem(
        title: 'الدعم والمساعدة',
        path: '/support',
        icon: Icons.support_agent_rounded,
        color: AppTheme.primaryCyan,
      ),
      _LegalItem(
        title: 'حذف الحساب',
        path: '/delete-account',
        icon: Icons.delete_forever_rounded,
        color: AppTheme.error,
      ),
    ];
  }

  /// يرسم صفحة اختيار المستندات القانونية مع قائمة قابلة للنقر تنقل إلى
  /// الصفحة أو الـ WebView المناسبة.
  /// Renders the legal-document selector with tappable rows that navigate to
  /// the matching page or web view.
  @override
  Widget build(BuildContext context) {
    final items = _items();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          const _LegalBackground(),
          SafeArea(
            child: Column(
              children: [
                _LegalHeader(
                  title: 'السياسات والشروط',
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.darkCard.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.darkBorder.withOpacity(0.1),
                              width: 0.5,
                            ),
                          ),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: items.length,
                            separatorBuilder: (_, __) => Container(
                              height: 0.5,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              color: AppTheme.darkBorder.withOpacity(0.08),
                            ),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return _LegalListItem(
                                icon: item.icon,
                                title: item.title,
                                color: item.color,
                                onTap: () {
                                  if (item.path == '/support') {
                                    context.push('/legal/webview',
                                        extra: <String, dynamic>{
                                          'title': "المساعدة والدعم",
                                          'url':
                                              'https://www.hggzk.com/support',
                                        });
                                    return;
                                  }
                                  final url = _normalizeUrl(baseUrl, item.path);
                                  context.push(
                                    '/legal/webview',
                                    extra: <String, dynamic>{
                                      'title': item.title,
                                      'url': url,
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// يضمن أن الرابط النهائي لا يحتوي على شرطة مائلة مكررة بين الأساس
  /// والمسار.
  /// Ensures the final URL does not contain a duplicate slash between the
  /// base and the path.
  String _normalizeUrl(String baseUrl, String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$normalizedBase$path';
  }
}

/// يمثل بندًا واحدًا في قائمة المستندات القانونية مع عنوانه ومساره وأيقونة
/// العرض.
/// Represents one legal-document entry with its title, navigation path, and
/// display icon.
class _LegalItem {
  /// اسم العنصر الظاهر للمستخدم.
  /// The label shown to the user.
  final String title;

  /// المسار النسبي الذي يحدد الصفحة أو المستند المرتبط بهذا العنصر.
  /// The relative path that resolves to the linked page or document.
  final String path;

  /// الأيقونة المستخدمة لتمييز هذا المستند داخل القائمة.
  /// The icon used to visually distinguish this document in the list.
  final IconData icon;

  /// لون الواجهة الذي يعطي العنصر هويته البصرية.
  /// The accent color that gives the item its visual identity.
  final Color color;

  /// Creates a single legal shortcut entry for the selector list.
  const _LegalItem({
    required this.title,
    required this.path,
    required this.icon,
    required this.color,
  });
}

/// يضيف طبقة خلفية متدرجة وهادئة تجعل شاشة المستندات القانونية متناسقة
/// مع بقية واجهات التطبيق الداكنة.
/// Adds a calm gradient background so the legal-documents page matches the
/// app's dark visual language.
class _LegalBackground extends StatelessWidget {
  /// Creates the background layer used behind the legal-document list.
  const _LegalBackground();

  /// يرسم الخلفية فقط من دون إضافة أي تفاعل حتى تبقى الطبقة سلبية.
  /// Paints only the decorative background so the layer stays non-interactive.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkBackground,
            AppTheme.darkSurface.withOpacity(0.8),
            AppTheme.darkCard.withOpacity(0.3),
          ],
        ),
      ),
    );
  }
}

/// يعرض الشريط العلوي للصفحة مع عنوان واضح وزر رجوع ثابت للسياق.
/// Renders the page header with a clear title and a stable back action.
class _LegalHeader extends StatelessWidget {
  /// عنوان الصفحة الذي يوضح نوع المستندات المعروضة.
  /// The page title that clarifies which documents are being shown.
  final String title;

  /// دالة الرجوع التي يستدعيها الزر الأيسر.
  /// The back callback triggered by the leading button.
  final VoidCallback onBack;

  /// Creates the branded legal header with title and back action.
  const _LegalHeader({
    required this.title,
    required this.onBack,
  });

  /// يرسم رأسًا زجاجيًا خفيفًا يركّز الانتباه على عنوان الصفحة.
  /// Builds a subtle glass-like header that keeps attention on the page
  /// title.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.darkCard.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.darkBorder.withOpacity(0.12),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.darkBorder.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: AppTheme.textWhite,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.h4.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// يعرض سطرًا تفاعليًا واحدًا داخل قائمة المستندات مع أيقونة ولون ومؤشر
/// انتقال.
/// Renders one interactive row in the document list with icon, accent color,
/// and a navigation affordance.
class _LegalListItem extends StatelessWidget {
  /// الأيقونة التي تمثل المستند.
  /// The icon representing the document.
  final IconData icon;

  /// نص العنصر الظاهر في القائمة.
  /// The label displayed in the list.
  final String title;

  /// لون التمييز البصري المستخدم للأيقونة والحافة.
  /// The accent color used for the icon and border.
  final Color color;

  /// الإجراء الذي ينفذ عند النقر على العنصر.
  /// The action executed when the row is tapped.
  final VoidCallback onTap;

  /// Creates a tappable document row for the legal selector list.
  const _LegalListItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  /// يبني صفًا تفاعليًا يوازن بين الوضوح البصري وسهولة التنقل.
  /// Builds an interactive row that balances visual clarity and easy
  /// navigation.
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: color.withOpacity(0.15),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppTheme.textMuted.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
