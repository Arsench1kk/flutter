import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:where_things_go/features/users/user.dart';

import '../../fixtures/user_json.dart';

void main() {
  group('User.fromJson', () {
    test('parses user 1, including the nested city and double latitude', () {
      final json = jsonDecode(userOneJson) as Map<String, dynamic>;
      final user = User.fromJson(json);
      expect(user.name, 'Leanne Graham');
      expect(user.address.city, 'Gwenborough');
      expect(user.address.geo.lat, isA<double>());
      expect(user.address.geo.lat, -37.3159);
    });

    test('throws TypeError when the id is a string', () {
      final json = jsonDecode(
        userOneJson.replaceFirst('"id": 1', '"id": "1"'),
      ) as Map<String, dynamic>;
      expect(() => User.fromJson(json), throwsA(isA<TypeError>()));
    });
  });
}
