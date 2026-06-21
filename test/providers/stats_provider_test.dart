import 'package:flutter_test/flutter_test.dart';

import 'package:epura/models/review_session.dart';
import 'package:epura/providers/stats_provider.dart';

import '../test_helpers.dart';

void main() {
  test('StatsProvider exposes current month progress', () async {
    final context = await createTestContext();
    final now = DateTime.now();
    await context.database.insertSession(
      ReviewSession(
        id: 'this-month',
        date: DateTime(now.year, now.month, 12),
        keptCount: 2,
        deletedCount: 3,
        skippedCount: 1,
        bytesFreed: 4096,
      ),
    );
    await context.database.insertSession(
      ReviewSession(
        id: 'previous-month',
        date: DateTime(now.year, now.month - 1, 12),
        keptCount: 10,
        deletedCount: 10,
        skippedCount: 0,
        bytesFreed: 8192,
      ),
    );

    final stats = StatsProvider();
    await stats.loadStats(context.database);

    expect(stats.monthlyBytesFreed, 4096);
    expect(stats.monthlyFilesReviewed, 6);
    expect(stats.monthlyDeleted, 3);
  });
}
