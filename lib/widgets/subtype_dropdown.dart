import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/subtypes.dart';

/// A dropdown over subtype [keys] that displays localized labels but reports
/// the stable key as its value.
class SubtypeDropdown extends StatelessWidget {
  const SubtypeDropdown({
    super.key,
    required this.keys,
    required this.value,
    required this.onChanged,
  });

  final List<String> keys;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: loc.addType,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      items: keys
          .map((k) => DropdownMenuItem<String>(
                value: k,
                child: Text(subtypeLabel(loc, k)),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
