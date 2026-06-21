class ReviewPromptPolicy {
  static const int minimumSuccessfulSessions = 2;

  const ReviewPromptPolicy();

  bool shouldShow({
    required int successfulSessionCount,
    required bool promptDismissed,
    required int failedDeletionCount,
  }) {
    if (promptDismissed) return false;
    if (failedDeletionCount > 0) return false;
    return successfulSessionCount >= minimumSuccessfulSessions;
  }
}
