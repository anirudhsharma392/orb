import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('Orb App playback test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ExampleApp());

    // Verify play button exists and we start idle
    expect(find.text('Standing By'), findsOneWidget);
    expect(find.byType(GestureDetector).last, findsOneWidget);

    // Tap play button
    // It's a custom gesture detector button now, we can tap the Icon
    await tester.tap(find.byIcon(Icons.mic_rounded));
    // Provide a small pump, don't use pumpAndSettle due to infinite spin controller
    await tester.pump(const Duration(milliseconds: 200)); 

    // Verify state changed
    expect(find.text('Listening...'), findsOneWidget);

    // Stop playback
    await tester.tap(find.byIcon(Icons.stop_rounded));
    await tester.pump(const Duration(milliseconds: 200)); 
    
    expect(find.text('Standing By'), findsOneWidget);
  });
}
