class ReviewSession {
  final String id;
  final DateTime date;
  final int keptCount;
  final int deletedCount;
  final int skippedCount;
  final int bytesFreed;

  const ReviewSession({
    required this.id,
    required this.date,
    required this.keptCount,
    required this.deletedCount,
    required this.skippedCount,
    required this.bytesFreed,
  });

  int get totalReviewed => keptCount + deletedCount + skippedCount;

  ReviewSession copyWith({
    String? id,
    DateTime? date,
    int? keptCount,
    int? deletedCount,
    int? skippedCount,
    int? bytesFreed,
  }) {
    return ReviewSession(
      id: id ?? this.id,
      date: date ?? this.date,
      keptCount: keptCount ?? this.keptCount,
      deletedCount: deletedCount ?? this.deletedCount,
      skippedCount: skippedCount ?? this.skippedCount,
      bytesFreed: bytesFreed ?? this.bytesFreed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewSession &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ReviewSession(id: $id, date: $date, deleted: $deletedCount, bytesFreed: $bytesFreed)';
}
