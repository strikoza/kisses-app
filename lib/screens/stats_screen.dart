import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/activity_record.dart';
import '../models/subtypes.dart';
import '../state/app_state.dart';

/// Statistics screen: pie chart + sortable per-subtype table, tabbed by type.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  int _touchedIndexKiss = -1;
  int _touchedIndexSex = -1;

  // Sorting state
  bool _sortAscendingKiss = false;
  bool _sortAscendingSex = false;
  bool _sortByOrgasmsSex = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.selectionClick();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final kissStats = state.getStatsByType(ActivityType.kiss);
    final sexStats = state.getStatsByType(ActivityType.sex);
    final sexOrgasmStats = state.getOrgasmStatsByType(ActivityType.sex);
    final loc = AppLocalizations.of(context)!;

    final activeColor = _tabController.index == 0 ? Colors.pink : Colors.purple;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: activeColor,
          indicatorWeight: 3,
          labelPadding: EdgeInsets.zero,
          overlayColor:
              WidgetStateProperty.all(activeColor.withValues(alpha: 0.1)),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('💋', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(loc.kissesLabel,
                      style: const TextStyle(
                          color: Colors.pink, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.purple, size: 22),
                  const SizedBox(width: 8),
                  Text(loc.sexLabel,
                      style: const TextStyle(
                          color: Colors.purple, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatPage(
            context,
            data: kissStats,
            orgasmData: null,
            baseColor: Colors.pink,
            touchedIndex: _touchedIndexKiss,
            onTouch: (idx) {
              if (idx != -1 && idx != _touchedIndexKiss) {
                HapticFeedback.selectionClick();
              }
              setState(() => _touchedIndexKiss = idx);
            },
            enableAnimation: state.isAnimationEnabled,
            isAscending: _sortAscendingKiss,
            onSortToggle: () {
              HapticFeedback.selectionClick();
              setState(() => _sortAscendingKiss = !_sortAscendingKiss);
            },
            sortByOrgasms: false,
            onSortByOrgasmsToggle: () {},
          ),
          _buildStatPage(
            context,
            data: sexStats,
            orgasmData: sexOrgasmStats,
            baseColor: Colors.purple,
            touchedIndex: _touchedIndexSex,
            onTouch: (idx) {
              if (idx != -1 && idx != _touchedIndexSex) {
                HapticFeedback.selectionClick();
              }
              setState(() => _touchedIndexSex = idx);
            },
            enableAnimation: state.isAnimationEnabled,
            isAscending: _sortAscendingSex,
            onSortToggle: () {
              HapticFeedback.selectionClick();
              setState(() {
                if (_sortByOrgasmsSex) {
                  _sortByOrgasmsSex = false;
                  _sortAscendingSex = false;
                } else {
                  _sortAscendingSex = !_sortAscendingSex;
                }
              });
            },
            sortByOrgasms: _sortByOrgasmsSex,
            onSortByOrgasmsToggle: () {
              HapticFeedback.selectionClick();
              setState(() {
                if (!_sortByOrgasmsSex) {
                  _sortByOrgasmsSex = true;
                  _sortAscendingSex = false;
                } else {
                  _sortAscendingSex = !_sortAscendingSex;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatPage(
    BuildContext context, {
    required Map<String, int> data,
    required Map<String, int>? orgasmData,
    required Color baseColor,
    required int touchedIndex,
    required Function(int) onTouch,
    required bool enableAnimation,
    required bool isAscending,
    required VoidCallback onSortToggle,
    required bool sortByOrgasms,
    required VoidCallback onSortByOrgasmsToggle,
  }) {
    final loc = AppLocalizations.of(context)!;

    if (data.isEmpty) {
      return Center(child: Text(loc.statsEmpty));
    }

    final totalCount = data.values.fold(0, (sum, val) => sum + val);
    final totalOrgasms = orgasmData?.values.fold(0, (sum, val) => sum + val) ?? 0;

    // Sort entries by the active metric before display.
    final sortedEntries = data.entries.toList();
    sortedEntries.sort((a, b) {
      final int valA;
      final int valB;
      if (sortByOrgasms && orgasmData != null) {
        valA = orgasmData[a.key] ?? 0;
        valB = orgasmData[b.key] ?? 0;
      } else {
        valA = a.value;
        valB = b.value;
      }
      return isAscending ? valA.compareTo(valB) : valB.compareTo(valA);
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSummaryCard(loc.summaryTotal, '$totalCount', baseColor),
              if (orgasmData != null) ...[
                const SizedBox(width: 40),
                _buildSummaryCard(
                    loc.summaryOrgasms, '$totalOrgasms', Colors.green),
              ]
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: PieChart(
              duration: Duration(milliseconds: enableAnimation ? 500 : 0),
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      return;
                    }
                    if (event is FlPointerHoverEvent) {
                      return;
                    }
                    onTouch(
                        pieTouchResponse.touchedSection!.touchedSectionIndex);
                  },
                ),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: sortedEntries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final kv = entry.value;
                  final isTouched = index == touchedIndex;

                  final color = baseColor
                      .withValues(alpha: 1.0 - (index * 0.15).clamp(0.0, 0.5));

                  final double opacity =
                      (touchedIndex == -1 || isTouched) ? 1.0 : 0.4;
                  final double radius =
                      isTouched && enableAnimation ? 70.0 : 60.0;

                  return PieChartSectionData(
                    color: color.withValues(alpha: color.a * opacity),
                    value: kv.value.toDouble(),
                    title: '${kv.value}',
                    radius: radius,
                    titleStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                    child: Text(loc.statsType,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey))),
                // Count header
                InkWell(
                  onTap: onSortToggle,
                  child: SizedBox(
                    width: 70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: !sortByOrgasms ? 1.0 : 0.0,
                          child: Icon(
                              isAscending
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 16,
                              color: Colors.blue),
                        ),
                        Text(loc.statsCount,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    !sortByOrgasms ? Colors.blue : Colors.grey)),
                      ],
                    ),
                  ),
                ),
                // Orgasms header
                if (orgasmData != null) ...[
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: onSortByOrgasmsToggle,
                    child: SizedBox(
                      width: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: sortByOrgasms ? 1.0 : 0.0,
                            child: Icon(
                                isAscending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 16,
                                color: Colors.blue),
                          ),
                          Text(loc.statsOrgasms,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: sortByOrgasms
                                      ? Colors.blue
                                      : Colors.green)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: sortedEntries.asMap().entries.map((entry) {
                final index = entry.key;
                final e = entry.value;
                final count = e.value;
                final orgasms = orgasmData?[e.key] ?? 0;
                final isTouched = index == touchedIndex;
                final displayedSubtype = subtypeLabel(loc, e.key);

                return Container(
                  color: isTouched ? baseColor.withValues(alpha: 0.1) : null,
                  child: ListTile(
                    onTap: () => onTouch(index == touchedIndex ? -1 : index),
                    leading: CircleAvatar(backgroundColor: baseColor, radius: 5),
                    title: Text(
                      displayedSubtype,
                      style: TextStyle(
                        fontWeight:
                            isTouched ? FontWeight.bold : FontWeight.normal,
                        color: isTouched ? baseColor : Colors.black,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 70,
                          child: Text('$count',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        if (orgasmData != null) ...[
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 90,
                            child: Text('$orgasms',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green)),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
