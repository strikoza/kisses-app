// Verifies that legacy Ukrainian subtype strings migrate to stable keys and
// that records round-trip through JSON unchanged.

import 'package:flutter_test/flutter_test.dart';
import 'package:kisses_app/models/activity_record.dart';

ActivityRecord _decode({
  required ActivityType type,
  required String subtype,
  int orgasmCount = 0,
}) {
  return ActivityRecord.fromJson({
    'id': 'test-id',
    'date': '2024-01-01T10:00:00.000',
    'type': type.index,
    'subtype': subtype,
    'orgasmCount': orgasmCount,
  });
}

void main() {
  group('legacy subtype migration', () {
    test('maps legacy Ukrainian kiss strings to stable keys', () {
      expect(_decode(type: ActivityType.kiss, subtype: 'Ніжний').subtype,
          'tender');
      expect(
          _decode(type: ActivityType.kiss, subtype: 'Цьом ніби не любить')
              .subtype,
          'reluctant');
    });

    test('maps legacy Ukrainian intimacy strings to stable keys', () {
      final record =
          _decode(type: ActivityType.sex, subtype: 'Оральний (куні)', orgasmCount: 2);
      expect(record.subtype, 'oralCuni');
      expect(record.orgasmCount, 2);
    });

    test('leaves already-migrated keys unchanged', () {
      expect(_decode(type: ActivityType.kiss, subtype: 'passionate').subtype,
          'passionate');
    });

    test('passes unknown/custom values through unchanged', () {
      expect(_decode(type: ActivityType.kiss, subtype: 'custom value').subtype,
          'custom value');
    });

    test('round-trips through toJson/fromJson', () {
      final original = ActivityRecord(
        id: '4',
        date: DateTime.parse('2024-05-05T12:00:00.000'),
        type: ActivityType.sex,
        subtype: 'vaginal',
        orgasmCount: 1,
      );
      final restored = ActivityRecord.fromJson(original.toJson());
      expect(restored.subtype, 'vaginal');
      expect(restored.type, ActivityType.sex);
      expect(restored.orgasmCount, 1);
      expect(restored.id, '4');
    });
  });
}
