import 'subtypes.dart';

enum ActivityType { kiss, sex }

/// A single tracked activity. [subtype] holds a stable, locale-independent key
/// (see `subtypes.dart`) — never display text.
class ActivityRecord {
  final String id;
  final DateTime date;
  final ActivityType type;
  final String subtype;
  final int orgasmCount;

  ActivityRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.subtype,
    this.orgasmCount = 0,
  });

  ActivityRecord copyWith({
    String? subtype,
    int? orgasmCount,
    DateTime? date,
  }) {
    return ActivityRecord(
      id: id,
      date: date ?? this.date,
      type: type,
      subtype: subtype ?? this.subtype,
      orgasmCount: orgasmCount ?? this.orgasmCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'type': type.index,
        'subtype': subtype,
        'orgasmCount': orgasmCount,
      };

  factory ActivityRecord.fromJson(Map<String, dynamic> json) {
    return ActivityRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: ActivityType.values[json['type'] as int],
      // Legacy records stored Ukrainian display strings; normalize to keys.
      subtype: normalizeSubtypeKey(json['subtype'] as String),
      orgasmCount: (json['orgasmCount'] as int?) ?? 0,
    );
  }
}

/// The canonical subtype keys available for a given activity [type].
List<String> subtypeKeysFor(ActivityType type) =>
    type == ActivityType.kiss ? kissSubtypeKeys : sexSubtypeKeys;
