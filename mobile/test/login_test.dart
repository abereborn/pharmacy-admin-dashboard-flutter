import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mobile/login_page.dart';

void main() {
  testWidgets('Input login test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    await tester.enterText(find.byType(TextField).at(0), 'admin');
    await tester.enterText(find.byType(TextField).at(1), '123');

    expect(find.text('admin'), findsOneWidget);
  });
}
