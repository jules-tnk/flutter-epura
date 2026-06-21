import 'package:flutter_test/flutter_test.dart';

import 'package:epura/utils/format_utils.dart';

void main() {
  group('formatDurationSeconds', () {
    test('formats sub-hour durations as minutes and two-digit seconds', () {
      expect(formatDurationSeconds(0), '0:00');
      expect(formatDurationSeconds(4), '0:04');
      expect(formatDurationSeconds(125), '2:05');
    });

    test('formats hour-long durations with padded minutes and seconds', () {
      expect(formatDurationSeconds(3665), '1:01:05');
    });

    test('clamps negative durations to zero', () {
      expect(formatDurationSeconds(-12), '0:00');
    });
  });
}
