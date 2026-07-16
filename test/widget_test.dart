import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shifting_wallah_driver/app/app.dart';

void main() {
  testWidgets('shows driver splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DriverApp()));

    expect(find.text('Shifting Wallah Driver'), findsOneWidget);
    expect(find.text('Driver App'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('navigates from splash to login', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DriverApp()));

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Driver Login'), findsOneWidget);
  });
}
