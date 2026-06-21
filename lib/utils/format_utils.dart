String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}

String formatDurationSeconds(int seconds) {
  final clamped = seconds < 0 ? 0 : seconds;
  final duration = Duration(seconds: clamped);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final remainingSeconds = duration.inSeconds.remainder(60);
  final twoDigitSeconds = remainingSeconds.toString().padLeft(2, '0');

  if (hours == 0) {
    return '$minutes:$twoDigitSeconds';
  }

  final twoDigitMinutes = minutes.toString().padLeft(2, '0');
  return '$hours:$twoDigitMinutes:$twoDigitSeconds';
}
