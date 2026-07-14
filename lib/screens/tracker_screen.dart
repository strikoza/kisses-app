import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/activity_record.dart';
import '../state/app_state.dart';
import '../widgets/orgasm_stepper.dart';
import '../widgets/subtype_dropdown.dart';
import 'settings_screen.dart';

/// Home screen with the two big "add activity" buttons.
class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBigButton(
              context,
              loc.kissesLabel,
              const Text('💋', style: TextStyle(fontSize: 28)),
              ActivityType.kiss,
            ),
            const SizedBox(height: 30),
            _buildBigButton(
              context,
              loc.sexLabel,
              const Icon(Icons.local_fire_department, size: 38),
              ActivityType.sex,
              showOrgasmCounter: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigButton(
    BuildContext context,
    String title,
    Widget icon,
    ActivityType type, {
    bool showOrgasmCounter = false,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        backgroundColor: type.color.withValues(alpha: 0.1),
        foregroundColor: type.color,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      onPressed: () {
        HapticFeedback.mediumImpact();
        _showAddDialog(context, title, type, showOrgasmCounter);
      },
      icon: icon,
      label: Text(title, style: const TextStyle(fontSize: 24)),
    );
  }

  void _showAddDialog(
    BuildContext context,
    String title,
    ActivityType type,
    bool showOrgasmCounter,
  ) {
    final keys = subtypeKeysFor(type);
    String selectedSubtype = keys.first;
    int orgasmCount = 0;
    DateTime selectedDate = DateTime.now();
    final loc = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.addTitle(title),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () async {
                        HapticFeedback.selectionClick();
                        final d = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) setModalState(() => selectedDate = d);
                      },
                      child: Text(
                        DateFormat('dd.MM.yyyy').format(selectedDate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SubtypeDropdown(
                  keys: keys,
                  value: selectedSubtype,
                  onChanged: (v) => setModalState(() => selectedSubtype = v),
                ),
                if (showOrgasmCounter) ...[
                  const SizedBox(height: 20),
                  OrgasmStepper(
                    label: loc.orgasmCountLabel,
                    count: orgasmCount,
                    onChanged: (v) => setModalState(() => orgasmCount = v),
                  ),
                ],
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: type.color,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      final appState = context.read<AppState>();
                      appState.addRecord(
                        type,
                        selectedSubtype,
                        selectedDate,
                        orgasms: orgasmCount,
                      );
                      Navigator.pop(context);
                      // Sound playback lives in AppState (fire-and-forget), so
                      // there is no BuildContext use across an await here.
                      appState.playActivitySound(type);
                    },
                    child: Text(
                      loc.saveButton,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
