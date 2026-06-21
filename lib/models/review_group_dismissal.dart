class ReviewGroupDismissal {
  final String groupKey;
  final String mode;
  final DateTime dismissedAt;

  const ReviewGroupDismissal({
    required this.groupKey,
    required this.mode,
    required this.dismissedAt,
  });
}
