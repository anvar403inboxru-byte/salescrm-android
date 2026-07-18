import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/dashboard'))  return 0;
    if (loc.startsWith('/customers'))  return 1;
    if (loc.startsWith('/quotations')) return 2;
    if (loc.startsWith('/tasks'))      return 3;
    if (loc.startsWith('/contacts'))   return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.primary.withOpacity(0.2),
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/dashboard');  break;
            case 1: context.go('/customers');  break;
            case 2: context.go('/quotations'); break;
            case 3: context.go('/tasks');      break;
            case 4: context.go('/contacts');   break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.people_outline),    selectedIcon: Icon(Icons.people),    label: 'Müştərilər'),
          NavigationDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description), label: 'Təkliflər'),
          NavigationDestination(icon: Icon(Icons.task_outlined),     selectedIcon: Icon(Icons.task),      label: 'Tapşırıqlar'),
          NavigationDestination(icon: Icon(Icons.contacts_outlined), selectedIcon: Icon(Icons.contacts),  label: 'Kontaktlar'),
        ],
      ),
    );
  }
}