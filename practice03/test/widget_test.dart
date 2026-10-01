import 'package:flutter_test/flutter_test.dart';

import 'package:practice03/main.dart';

void main() {
  testWidgets('profile screen shows the profile data', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Arsen Abduhalyk'), findsOneWidget);
    expect(find.text('Kazakh-British Technical University'), findsOneWidget);
    expect(find.text('Favourite widget'), findsOneWidget);
    expect(find.text('Column'), findsOneWidget);
  });
}
