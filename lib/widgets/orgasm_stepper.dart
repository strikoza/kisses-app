import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A green +/- counter for the orgasm count, shared by the add and edit sheets.
class OrgasmStepper extends StatelessWidget {
  const OrgasmStepper({
    super.key,
    required this.label,
    required this.count,
    required this.onChanged,
  });

  final String label;
  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.green),
                onPressed: () {
                  if (count > 0) {
                    HapticFeedback.selectionClick();
                    onChanged(count - 1);
                  }
                },
              ),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.green),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onChanged(count + 1);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
