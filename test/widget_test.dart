import 'package:flutter_test/flutter_test.dart';

import 'package:epura/app.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EpuraApp());
    expect(find.text('epura'), findsOneWidget);
  });
}
