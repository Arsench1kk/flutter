import 'package:flutter_test/flutter_test.dart';

import 'package:practice03/main.dart';

void main() {
  testWidgets('profile screen screenshot', (tester) async {
    await tester.pumpWidget(const MyApp());
    await expectLater(
      find.byType(MyApp),
      matchesGoldenFile('../screenshot.png'),
    );
  });
}
