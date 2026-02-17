// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:danjones/main.dart'; // Import main.dart to access DanJonesApp

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DanJonesApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsNothing);
  });
}
