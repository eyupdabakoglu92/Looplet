import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/main.dart';

void main() {
  testWidgets('app boots to the placeholder shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LoopletApp());
    expect(find.text('LOOPLET'), findsOneWidget);
  });
}
