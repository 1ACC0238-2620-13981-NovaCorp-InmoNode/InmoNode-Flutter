import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/main.dart';

void main() {
  testWidgets('App starts and shows InmoNode', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('InmoNode'), findsOneWidget);
  });
}
