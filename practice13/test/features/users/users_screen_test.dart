import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:where_things_go/core/api/api_exception.dart';
import 'package:where_things_go/features/users/user_repository.dart';
import 'package:where_things_go/features/users/users_model.dart';
import 'package:where_things_go/features/users/users_screen.dart';

import '../../fakes/fake_user_repository.dart';

class _BadResponseRepository extends FakeUserRepository {
  @override
  Future<UsersResult> getAll() async =>
      throw const BadResponseException('users: lat is not a String');
}

Widget _usersApp(UsersModel model) => MaterialApp(
  home: ChangeNotifierProvider.value(value: model, child: const UsersScreen()),
);

void main() {
  testWidgets('shows the offline view and Retry', (tester) async {
    const delay = Duration(milliseconds: 50);
    final model = UsersModel(FakeUserRepository(fail: true, delay: delay));
    addTearDown(model.dispose);

    final load = model.load();
    await tester.pump();
    await tester.pump(delay);
    await load;

    await tester.pumpWidget(_usersApp(model));
    expect(find.text('No connection'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(delay);
    await tester.pumpAndSettle();
    expect(find.text('No connection'), findsOneWidget);
  });

  testWidgets('shows the generic message for a bad response', (tester) async {
    final model = UsersModel(_BadResponseRepository());
    addTearDown(model.dispose);
    await model.load();

    await tester.pumpWidget(_usersApp(model));

    expect(
      find.text('The server returned an unexpected response.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
