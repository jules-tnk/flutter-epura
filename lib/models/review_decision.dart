enum ReviewDecisionType {
  later('later'),
  neverAskAgain('never_ask_again');

  final String storageValue;

  const ReviewDecisionType(this.storageValue);

  static ReviewDecisionType fromStorage(String value) {
    return ReviewDecisionType.values.firstWhere(
      (type) => type.storageValue == value,
      orElse: () => ReviewDecisionType.later,
    );
  }
}

class ReviewDecision {
  final String fileKey;
  final ReviewDecisionType type;
  final DateTime decidedAt;

  const ReviewDecision({
    required this.fileKey,
    required this.type,
    required this.decidedAt,
  });
}
