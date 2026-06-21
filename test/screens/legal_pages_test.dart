import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:epura/screens/privacy_policy_screen.dart';
import 'package:epura/screens/terms_of_service_screen.dart';
import 'package:epura/widgets/epura_components.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('Privacy policy keeps legal copy in the Epura panel layout', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext();

    await tester.pumpWidget(
      buildTestApp(home: const PrivacyPolicyScreen(), context: context),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(EpuraPanel), findsAtLeastNWidgets(3));
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Local only'), findsAtLeastNWidgets(1));
    expect(find.text('Last updated: April 13, 2026'), findsOneWidget);
    expect(
      find.text(
        'Epura does not collect, transmit, or share any personal data.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'No data leaves your device. No analytics, no tracking, no accounts required.',
      ),
      findsOneWidget,
    );
    expect(find.text('Permissions'), findsOneWidget);
    expect(find.text('View online'), findsOneWidget);
  });

  testWidgets('Terms screen keeps terms copy in the Epura panel layout', (
    WidgetTester tester,
  ) async {
    configureTestViewport(tester);
    addTearDown(() => resetTestViewport(tester));

    final context = await createTestContext();

    await tester.pumpWidget(
      buildTestApp(home: const TermsOfServiceScreen(), context: context),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(EpuraPanel), findsAtLeastNWidgets(3));
    expect(find.text('Terms of Service'), findsAtLeastNWidgets(1));
    expect(find.text('Local only'), findsAtLeastNWidgets(1));
    expect(find.text('Last updated: March 20, 2026'), findsOneWidget);
    expect(
      find.text('By using Epura, you agree to the following terms.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'When you choose to delete a file, it is permanently removed from your device. Epura is not responsible for any data loss resulting from your decisions.',
      ),
      findsOneWidget,
    );
    expect(find.text('View online'), findsOneWidget);
  });
}
