import 'package:flutter_test/flutter_test.dart';

import 'package:field_ops/main.dart';

void main() {
  testWidgets('App boots to placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(const FieldOpsApp());
    expect(find.text('FieldOps'), findsOneWidget);
  });
}