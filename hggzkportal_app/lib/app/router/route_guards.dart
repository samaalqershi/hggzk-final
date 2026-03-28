import 'package:hggzkportal/features/auth/presentation/bloc/auth_state.dart';

/// يميّز الحالة التي تمثل مستخدمًا مسجل الدخول حتى يقرر الراوتر ما إذا كان
/// يسمح بالمرور إلى المسارات المحمية.
/// Identifies the auth state that represents a signed-in user so the router
/// can decide whether protected paths may be entered.
bool isAuthenticated(AuthState state) => state is AuthAuthenticated;

/// يتحقق من صلاحيات الإدارة الفعلية للمستخدم بدل الاعتماد على اسم الشاشة أو
/// المسار وحده.
/// Checks the user's real administrative access instead of trusting the
/// visible screen name or route alone.
bool isAdmin(AuthState state) {
  if (state is! AuthAuthenticated) return false;
  final accountRole = (state.user.accountRole ?? '').toLowerCase();
  if (accountRole == 'admin' || accountRole == 'owner') return true;
  final roles = state.user.roles.map((e) => e.toLowerCase()).toList();
  return roles.contains('admin') ||
      roles.contains('superadmin') ||
      roles.contains('super_admin') ||
      roles.contains('owner');
}

/// يحدد المسارات التي يجب أن تبقى داخل منطقة الإدارة ويجب ألا تُفتح
/// للمستخدمين العاديين مباشرة.
/// Identifies routes that belong to the admin area and should not open
/// directly for regular users.
bool isAdminPath(String path) => path.startsWith('/admin');

/// يحدد المسارات التي لا معنى لفتحها من دون جلسة نشطة لأنها تعرض بيانات
/// شخصية أو عمليات مرتبطة بالحساب.
/// Identifies routes that require an active session because they expose
/// personal data or account-bound operations.
bool isProtectedPath(String path) {
  return path.startsWith('/profile') ||
      path.startsWith('/complete-profile') ||
      path.startsWith('/conversations') ||
      path.startsWith('/chat') ||
      path.startsWith('/notifications') ||
      path.startsWith('/admin');
}
