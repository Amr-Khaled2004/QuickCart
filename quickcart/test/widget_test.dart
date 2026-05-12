import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quickcart/app.dart';
import 'package:quickcart/providers/app_state_provider.dart';
import 'package:quickcart/widgets/common/app_logo.dart';

void main() {
  testWidgets('QuickCart app renders the splash screen', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppStateProvider(),
        child: const QuickCartApp(),
      ),
    );

    expect(find.byType(AppLogo), findsOneWidget);
  });
}
