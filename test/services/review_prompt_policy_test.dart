import 'package:flutter_test/flutter_test.dart';

import 'package:epura/services/review_prompt_policy.dart';

void main() {
  const policy = ReviewPromptPolicy();

  test('review prompt does not show too early or after failed deletions', () {
    expect(
      policy.shouldShow(
        successfulSessionCount: 0,
        promptDismissed: false,
        failedDeletionCount: 0,
      ),
      isFalse,
    );
    expect(
      policy.shouldShow(
        successfulSessionCount: 1,
        promptDismissed: false,
        failedDeletionCount: 0,
      ),
      isFalse,
    );
    expect(
      policy.shouldShow(
        successfulSessionCount: 2,
        promptDismissed: false,
        failedDeletionCount: 1,
      ),
      isFalse,
    );
  });

  test('review prompt shows after repeated successful local sessions', () {
    expect(
      policy.shouldShow(
        successfulSessionCount: 2,
        promptDismissed: false,
        failedDeletionCount: 0,
      ),
      isTrue,
    );
    expect(
      policy.shouldShow(
        successfulSessionCount: 2,
        promptDismissed: true,
        failedDeletionCount: 0,
      ),
      isFalse,
    );
  });
}
