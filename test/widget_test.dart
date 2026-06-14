import 'package:fifth_element/src/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FifthElementApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('A personal time machine'), findsOneWidget);
  });
}
