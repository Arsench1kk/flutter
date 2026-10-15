import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:never_overflows/contact_card.dart';
import 'package:never_overflows/contacts.dart';
import 'package:never_overflows/main.dart';

void main() {
  testWidgets('shows twenty contacts and wraps the long name', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(contacts, hasLength(20));
    expect(find.text('20 contacts'), findsOneWidget);
    expect(find.text(contacts[4].name), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unread badge is omitted at zero and shown otherwise', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ContactCard(contact: contacts[0])),
      ),
    );
    expect(find.byType(Positioned), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ContactCard(contact: contacts[1])),
      ),
    );
    expect(find.byType(Positioned), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('uses matching seed-based light and dark themes', (tester) async {
    await tester.pumpWidget(const MyApp());

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.system);
    expect(app.theme?.colorScheme.brightness, Brightness.light);
    expect(app.darkTheme?.colorScheme.brightness, Brightness.dark);
  });
}
