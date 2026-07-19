import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    _Tab('/dashboard',  Icons.dashboard_outlined,      Icons.dashboard,          'Dashboard'),
    _Tab('/customers',  Icons.people_outline,           Icons.people,             'Müştərilər'),
    _Tab('/quotations', Icons.receipt_long_outlined,    Icons.receipt_long,       'Təkliflər'),
    _Tab('/tasks',      Icons.check_circle_outline,     Icons.check_circle,       'Tapşırıqlar'),
    _Tab('/sales',      Icons.bar_chart_outlined,       Icons.bar_chart,          'Satışlar'),
    _Tab('/contacts',   Icons.contacts_outlined,        Icons.contacts,           'Kontaktlar'),
    _Tab('/team',       Icons.group_outlined,           Icons.group,              'Komanda'),
  ];

  int _currentIndex(String location) {
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _currentIndex(location);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicHeight(
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final tab   = _tabs[i];
                  final sel   = i == idx;
                  final color = sel ? AppTheme.primary : AppTheme.textMuted;
                  return GestureDetector(
                    onTap: () => context.go(tab.path),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(sel ? tab.activeIcon : tab.icon, color: color, size: 22),
                        const SizedBox(height: 3),
                        Text(tab.label,
                          style: TextStyle(color: color, fontSize: 10,
                              fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                      ]),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  final String path, label;
  final IconData icon, activeIcon;
  const _Tab(this.path, this.icon, this.activeIcon, this.label);
}