// =======================================================================
// test/widget_test.dart
// (Local-only version)
// =======================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_app_flutter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PersonalFinanceApp());

    // Verify that our login screen is shown.
    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}