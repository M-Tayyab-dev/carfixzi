import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CARFIXZI brand smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('CARFIXZI'),
          ),
        ),
      ),
    );

    expect(find.text('CARFIXZI'), findsOneWidget);
  });
}
