import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'mocks.mocks.dart';

void main() {
  group('Login API', () {
    test('should return 200 and contain user data', () async {
      final client = MockClient();
      final url = Uri.parse('https://smart-analysis-of-health-condition.onrender.com/api/custom_login/');

      // Fake response
      when(client.post(
        url,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer(
            (_) async => http.Response(jsonEncode({
          "access": "fake_access_token",
          "refresh": "fake_refresh_token",
          "user": {"id": 1, "username": "testuser"},
          "patient": {"id": 1, "name": "Test Patient"},
        }), 200),
      );

      final response = await client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": "test", "password": "123456"}),
      );

      expect(response.statusCode, 200);

      final data = jsonDecode(response.body);
      expect(data['access'], isNotNull);
      expect(data['user']['username'], "testuser");
      expect(data.containsKey('patient'), true);
    });

    test('should fail with 400 status code', () async {
      final client = MockClient();
      final url = Uri.parse('https://smart-analysis-of-health-condition.onrender.com/api/custom_login/');

      when(client.post(
        url,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer(
            (_) async => http.Response("Bad request", 400),
      );

      final response = await client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": "", "password": ""}),
      );

      expect(response.statusCode, 400);
    });
  });
}
