
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/focus_dependencies.dart';
import '../providers/focus_providers.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  final FocusDependencies dependencies;

  const MainScreen({
    super.key,
    required this.dependencies,
  });

  @override
  ConsumerState<MainScreen> createState() =>
      _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final GlobalKey<DashboardScreenState> _dashboardKey =
      GlobalKey<DashboardScreenState>();

  final GlobalKey<HistoryScreenState> _historyKey =
      GlobalKey<HistoryScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      DashboardScreen(
        key: _dashboardKey,
        dependencies: widget.dependencies,
      ),
      HistoryScreen(
        key: _historyKey,
        dependencies: widget.dependencies,
      ),
      const SettingsScreen(),
    ];
  }

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      ref.invalidate(focusPresetsProvider);
      ref.invalidate(sessionHistoryProvider);
      _dashboardKey.currentState?.reload();
    } else if (index == 1) {
      ref.invalidate(sessionHistoryProvider);
      _historyKey.currentState?.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wideScreen = MediaQuery.sizeOf(context).width >= 700;

    final content = IndexedStack(
      index: _selectedIndex,
      children: _screens,
    );

    if (wideScreen) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: Colors.white,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _selectTab,
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(
                color: AppTheme.primaryColor,
                size: 27,
              ),
              selectedLabelTextStyle: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
              indicatorColor: const Color(0xFFDBEAFE),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history),
                  label: Text('History'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: content),
          ],
        ),
      );
    }

    return Scaffold(
      body: content,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDBEAFE),
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(
              Icons.dashboard,
              color: AppTheme.primaryColor,
            ),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(
              Icons.history,
              color: AppTheme.primaryColor,
            ),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(
              Icons.settings,
              color: AppTheme.primaryColor,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
