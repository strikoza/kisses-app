import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../l10n/app_localizations.dart';
import '../models/activity_record.dart';
import '../models/subtypes.dart';
import '../state/app_state.dart';
import '../widgets/orgasm_stepper.dart';
import '../widgets/subtype_dropdown.dart';

/// Calendar view with a per-day list of records and an edit/delete sheet.
class CalendarHistoryScreen extends StatefulWidget {
  const CalendarHistoryScreen({super.key});

  @override
  State<CalendarHistoryScreen> createState() => _CalendarHistoryScreenState();
}

class _CalendarHistoryScreenState extends State<CalendarHistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _showEditDialog(BuildContext context, ActivityRecord record) {
    final loc = AppLocalizations.of(context)!;
    final isSex = record.type == ActivityType.sex;

    // Keep the record's current key selectable even if it is a legacy/custom
    // value no longer in the standard list.
    final keys = List<String>.from(subtypeKeysFor(record.type));
    if (!keys.contains(record.subtype)) keys.add(record.subtype);

    String currentSubtype = record.subtype;
    int currentOrgasms = record.orgasmCount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.editRecordTitle,
                        style: Theme.of(context).textTheme.headlineSmall),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: Text(loc.deleteQuestion),
                            content: Text(loc.deleteIrreversible),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(c),
                                  child: Text(loc.cancelButton)),
                              TextButton(
                                onPressed: () {
                                  HapticFeedback.heavyImpact();
                                  context
                                      .read<AppState>()
                                      .deleteRecord(record.id);
                                  Navigator.pop(c);
                                  Navigator.pop(context);
                                },
                                child: Text(loc.yesDeleteButton,
                                    style: const TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
                const SizedBox(height: 20),
                SubtypeDropdown(
                  keys: keys,
                  value: currentSubtype,
                  onChanged: (v) => setModalState(() => currentSubtype = v),
                ),
                if (isSex) ...[
                  const SizedBox(height: 20),
                  OrgasmStepper(
                    label: loc.orgasmCountLabel,
                    count: currentOrgasms,
                    onChanged: (v) => setModalState(() => currentOrgasms = v),
                  ),
                ],
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: isSex ? Colors.purple : Colors.pink,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.read<AppState>().updateRecord(
                            record.copyWith(
                              subtype: currentSubtype,
                              orgasmCount: currentOrgasms,
                            ),
                          );
                      Navigator.pop(context);
                    },
                    child: Text(loc.updateButton),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final events = state.getRecordsForDay(_selectedDay ?? _focusedDay);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              eventLoader: (day) => state.getRecordsForDay(day),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(
                    color: Colors.pinkAccent, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                      BorderSide(color: Colors.pinkAccent, width: 2.0)),
                  color: Colors.transparent,
                ),
                todayTextStyle:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return null;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: events.take(3).map((e) {
                      final rec = e as ActivityRecord;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: rec.type == ActivityType.sex
                              ? Colors.purple
                              : Colors.pink,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const Divider(indent: 16, endIndent: 16),
            Expanded(
              child: events.isEmpty
                  ? Center(
                      child: Text(loc.nothingToday,
                          style: const TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final e = events[index];
                        final displayedSubtype = subtypeLabel(loc, e.subtype);

                        return ListTile(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _showEditDialog(context, e);
                          },
                          leading: e.type == ActivityType.sex
                              ? const Icon(Icons.local_fire_department,
                                  color: Colors.purple)
                              : const Text('💋', style: TextStyle(fontSize: 20)),
                          title: Text(displayedSubtype,
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: (e.type == ActivityType.sex &&
                                  e.orgasmCount > 0)
                              ? Text(
                                  loc.orgasmsCountShort(e.orgasmCount),
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(DateFormat('HH:mm').format(e.date),
                                  style: const TextStyle(color: Colors.grey)),
                              const SizedBox(width: 8),
                              const Icon(Icons.edit, size: 16, color: Colors.grey),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
