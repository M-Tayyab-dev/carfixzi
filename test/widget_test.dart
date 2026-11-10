import 'package:flutter_test/flutter_test.dart';
import 'package:carfixzi/main.dart';

void main() {
  testWidgets('CARFIXZI app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CarfixziApp());

    // Verify CARFIXZI brand text is rendered
    expect(find.text('CARFIXZI'), findsOneWidget);
  });
}
