import 'package:flutter_test/flutter_test.dart';

import 'package:productivity_and_management_tools/main.dart';

void main() {
  testWidgets('app shows main navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('FocusFlow'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Timer'), findsOneWidget);
  });
}
