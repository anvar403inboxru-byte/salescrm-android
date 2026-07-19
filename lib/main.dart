import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'services/auth_service.dart';
import 'services/update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthService();
  await auth.init();
  runApp(
    ChangeNotifierProvider.value(
      value: auth,
      child: const OrbitsonApp(),
    ),
  );
}

class OrbitsonApp extends StatelessWidget {
  const OrbitsonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ORBITSON CRM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: appRouter(context.watch<AuthService>()),
      builder: (context, child) => _UpdateWrapper(child: child!),
    );
  }
}

class _UpdateWrapper extends StatefulWidget {
  final Widget child;
  const _UpdateWrapper({required this.child});

  @override
  State<_UpdateWrapper> createState() => _UpdateWrapperState();
}

class _UpdateWrapperState extends State<_UpdateWrapper> {
  @override
  void initState() {
    super.initState();
    // App açıldıqdan 3 saniyə sonra yoxla
    Future.delayed(const Duration(seconds: 3), _checkUpdate);
  }

  Future<void> _checkUpdate() async {
    if (!mounted) return;
    final update = await UpdateService.checkForUpdate();
    if (update != null && mounted) {
      await UpdateService.showUpdateDialog(context, update);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}