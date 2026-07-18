import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/main_shell.dart';
import '../screens/dashboard_screen.dart';
import '../screens/customers_screen.dart';
import '../screens/customer_detail_screen.dart';
import '../screens/quotations_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/contacts_screen.dart';
import '../screens/profile_screen.dart';

GoRouter appRouter(AuthService auth) => GoRouter(
  initialLocation: '/dashboard',
  redirect: (ctx, state) {
    final loggedIn = auth.isLoggedIn;
    final isLogin = state.matchedLocation == '/login';
    if (!loggedIn && !isLogin) return '/login';
    if (loggedIn && isLogin) return '/dashboard';
    return null;
  },
  refreshListenable: auth,
  routes: [
    GoRoute(
      path: '/login',
      builder: (ctx, _) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (ctx, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/dashboard',  builder: (c, _) => const DashboardScreen()),
        GoRoute(path: '/customers',  builder: (c, _) => const CustomersScreen()),
        GoRoute(
          path: '/customers/:id',
          builder: (c, s) => CustomerDetailScreen(id: int.parse(s.pathParameters['id']!)),
        ),
        GoRoute(path: '/quotations', builder: (c, _) => const QuotationsScreen()),
        GoRoute(path: '/tasks',      builder: (c, _) => const TasksScreen()),
        GoRoute(path: '/contacts',   builder: (c, _) => const ContactsScreen()),
        GoRoute(path: '/profile',    builder: (c, _) => const ProfileScreen()),
      ],
    ),
  ],
);