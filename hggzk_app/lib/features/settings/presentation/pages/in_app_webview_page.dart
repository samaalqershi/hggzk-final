import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

/// تعرض صفحة ويب داخلية لفتح الروابط أو المستندات من دون مغادرة التطبيق.
/// Presents an in-app web view for opening links or documents without leaving
/// the application.
class InAppWebViewPage extends StatefulWidget {
  /// العنوان الذي يظهر في ترويسة الصفحة فوق محتوى الويب.
  /// Title shown in the page header above the web content.
  final String title;

  /// الرابط الذي سيتم تحميله داخل عارض الويب المضمن.
  /// URL that will be loaded inside the embedded web view.
  final String url;

  /// ينشئ صفحة ويب داخلية بعنوان ورابط محددين.
  /// Creates the in-app web page with a specific title and URL.
  const InAppWebViewPage({
    super.key,
    required this.title,
    required this.url,
  });

  /// ينشئ الحالة التي تدير متحكم الـ WebView وحالة التحميل.
  /// Creates the state object that manages the web view controller and loading
  /// progress.
  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

/// تدير تحميل صفحة الويب وتتبع تقدّمها لعرض شريط تقدم مناسب.
/// Manages loading the web page and tracks its progress so the UI can show an
/// appropriate progress bar.
class _InAppWebViewPageState extends State<InAppWebViewPage> {
  /// المتحكم المسؤول عن تهيئة صفحة الويب وإعادة تحميلها عند الحاجة.
  /// Controller responsible for configuring and reloading the web page.
  late final WebViewController _controller;

  /// نسبة التقدم الحالية لتحميل الصفحة بين 0 و100.
  /// Current page-loading progress percentage from 0 to 100.
  int _progress = 0;

  /// يهيئ الـ WebView ويضبط آلية تتبع التقدم مباشرة بعد إنشاء الصفحة.
  /// Initializes the web view and wires progress tracking right after the
  /// page is created.
  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _progress = progress;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  /// يبني صفحة الويب الداخلية مع الخلفية والترويسة وشريط التقدم.
  /// Builds the in-app web page with its background, header, and progress
  /// indicator.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          _WebBackground(),
          SafeArea(
            child: Column(
              children: [
                _WebHeader(
                  title: widget.title,
                  onBack: () => context.pop(),
                  onReload: () => _controller.reload(),
                ),
                if (_progress < 100)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _progress / 100.0,
                        minHeight: 2,
                        backgroundColor: AppTheme.darkCard.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryBlue.withOpacity(0.85),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.darkCard.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.darkBorder.withOpacity(0.12),
                              width: 0.5,
                            ),
                          ),
                          child: WebViewWidget(controller: _controller),
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
}

/// يرسم خلفية بسيطة ومتدرجة خلف صفحة الويب المضمنة.
/// Paints a simple gradient background behind the embedded web page.
class _WebBackground extends StatelessWidget {
  /// يبني الطبقة الخلفية التي تمنح الصفحة عمقًا بصريًا متناسقًا مع الثيم.
  /// Builds the background layer that gives the page visual depth consistent
  /// with the theme.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkBackground,
            AppTheme.darkSurface.withOpacity(0.85),
            AppTheme.darkCard.withOpacity(0.25),
          ],
        ),
      ),
    );
  }
}

/// يعرض ترويسة صفحة الويب مع عنوان الصفحة وأزرار الرجوع وإعادة التحميل.
/// Displays the in-app web page header with the title plus back and reload
/// actions.
class _WebHeader extends StatelessWidget {
  /// النص الذي يعرّف محتوى الصفحة المفتوحة.
  /// Text label that identifies the currently opened page.
  final String title;

  /// الإجراء الذي يعيد المستخدم إلى الشاشة السابقة.
  /// Action that returns the user to the previous screen.
  final VoidCallback onBack;

  /// الإجراء الذي يعيد تحميل الصفحة الحالية داخل الـ WebView.
  /// Action that reloads the current page inside the web view.
  final VoidCallback onReload;

  /// ينشئ ترويسة صفحة الويب مع الإجراءات الأساسية للتنقل والتحكم.
  /// Creates the web page header with its core navigation and control actions.
  const _WebHeader({
    required this.title,
    required this.onBack,
    required this.onReload,
  });

  /// يبني الترويسة الزجاجية التي تضم العنوان وأزرار التحكم.
  /// Builds the glass-style header that contains the title and control
  /// buttons.
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h4.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onReload,
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
                      Icons.refresh_rounded,
                      size: 18,
                      color: AppTheme.textWhite,
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
