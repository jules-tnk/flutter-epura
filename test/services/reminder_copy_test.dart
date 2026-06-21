import 'package:flutter_test/flutter_test.dart';

import 'package:epura/services/reminder_copy.dart';

void main() {
  test('daily reminder copy is local and action-focused', () {
    final copy = ReminderCopy.forSettings(interval: 'daily', localeCode: 'en');

    expect(copy.title, 'Ready for a quick Epura review?');
    expect(copy.body, contains('recent files'));
  });

  test('weekly reminder copy respects French locale', () {
    final copy = ReminderCopy.forSettings(interval: 'weekly', localeCode: 'fr');

    expect(copy.title, 'Votre revue Epura hebdomadaire');
    expect(copy.body, contains('quelques minutes'));
  });
}
