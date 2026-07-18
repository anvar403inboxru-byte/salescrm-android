import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'services/auth_service.dart';

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
    );
  }
}