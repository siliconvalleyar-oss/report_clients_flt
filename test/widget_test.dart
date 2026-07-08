import 'package:flutter_test/flutter_test.dart';
import 'package:report_clients_flt/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ReportClientsApp());
    expect(find.text('Electromedicina Pro'), findsOneWidget);
  });
}
