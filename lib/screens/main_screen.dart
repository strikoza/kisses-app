import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import 'calendar_history_screen.dart';
import 'stats_screen.dart';
import 'tracker_screen.dart';

/// The bottom-navigation shell hosting the three primary screens.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    TrackerScreen(),
    CalendarHistoryScreen(),
    StatsScreen(),
  ];

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      HapticFeedback.lightImpact();
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AppState, bool>((s) => s.isLoading);
    final loc = AppLocalizations.of(context)!;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        backgroundColor:
            Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.95),
        elevation: 0,
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.add_circle_outline),
              label: loc.trackerTitle),
          NavigationDestination(
              icon: const Icon(Icons.calendar_month), label: loc.calendarTitle),
          NavigationDestination(
              icon: const Icon(Icons.bar_chart), label: loc.statsTitle),
        ],
      ),
    );
  }
}
