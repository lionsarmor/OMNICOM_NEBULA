import 'package:flutter_test/flutter_test.dart';

import 'package:omnicom_frontend/main.dart';

void main() {
  testWidgets('shows the Nebula sign-on screen', (WidgetTester tester) async {
    await tester.pumpWidget(const NebulaApp());

    await tester.pump();

    expect(find.text('SIGN ON TO NEBULA'), findsOneWidget);
    expect(find.text('Create New Nebula ID'), findsOneWidget);
  });
}
