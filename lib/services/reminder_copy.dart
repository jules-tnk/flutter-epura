class ReminderCopy {
  final String title;
  final String body;

  const ReminderCopy({required this.title, required this.body});

  static ReminderCopy forSettings({
    required String interval,
    String? localeCode,
  }) {
    final language = localeCode?.toLowerCase();
    final weekly = interval == 'weekly';

    if (language == 'fr') {
      if (weekly) {
        return const ReminderCopy(
          title: 'Votre revue Epura hebdomadaire',
          body: 'Prenez quelques minutes pour examiner les fichiers récents.',
        );
      }

      return const ReminderCopy(
        title: 'Prêt pour une revue Epura rapide ?',
        body: "Examinez les fichiers récents avant qu'ils s'accumulent.",
      );
    }

    if (weekly) {
      return const ReminderCopy(
        title: 'Your weekly Epura review is ready',
        body: 'Take a few minutes to review recent files.',
      );
    }

    return const ReminderCopy(
      title: 'Ready for a quick Epura review?',
      body: 'Review recent files before they pile up.',
    );
  }
}
