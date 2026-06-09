import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:contable_uxser_app/app.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ContableUxserApp()));
    expect(find.byType(ContableUxserApp), findsOneWidget);
  });
}
