import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:where_things_go/features/users/users_model.dart';
import 'package:where_things_go/features/users/users_screen.dart';

import '../../fakes/fake_user_repository.dart';

void main() {
  testWidgets('shows the offline view and Retry', (tester) async {
    const delay = Duration(milliseconds: 50);
    final model = UsersModel(FakeUserRepository(fail: true, delay: delay));
    addTearDown(model.dispose);

    final load = model.load();
    await tester.pump();
    await tester.pump(delay);
    await load;

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: model,
          child: const UsersScreen(),
        ),
      ),
    );
    expect(find.text('No connection'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(delay);
    await tester.pumpAndSettle();
    expect(find.text('No connection'), findsOneWidget);
  });
}
