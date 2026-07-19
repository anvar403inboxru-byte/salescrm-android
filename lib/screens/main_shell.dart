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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
        ),
        child: NavigationBar(
          selectedIndex: idx,
          backgroundColor: AppTheme.surface,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          height: 62,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          indicatorColor: AppTheme.primary.withOpacity(0.15),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, size: 22),
              selectedIcon: Icon(Icons.dashboard_rounded, size: 22, color: AppTheme.primary),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded, size: 22),
              selectedIcon: Icon(Icons.people_rounded, size: 22, color: AppTheme.primary),
              label: 'Müştərilər',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined, size: 22),
              selectedIcon: Icon(Icons.receipt_long_rounded, size: 22, color: AppTheme.primary),
              label: 'Təkliflər',
            ),
            NavigationDestination(
              icon: Icon(Icons.check_circle_outline_rounded, size: 22),
              selectedIcon: Icon(Icons.check_circle_rounded, size: 22, color: AppTheme.primary),
              label: 'Tapşırıqlar',
            ),
            NavigationDestination(
              icon: Icon(Icons.contacts_outlined, size: 22),
              selectedIcon: Icon(Icons.contacts_rounded, size: 22, color: AppTheme.primary),
              label: 'Kontaktlar',
            ),
          ],
        ),
      ),
    );
  }
}