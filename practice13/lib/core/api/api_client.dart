import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show SocketException;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../storage/secure_store.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(
    this._client,
    this._store, {
    this.host = 'jsonplaceholder.typicode.com',
  });

  final http.Client _client;
  final SecureStore _store;
  final String host;

  Future<Map<String, String>> _headers() async {
    try {
      return {
        'Accept': 'application/json',
        if (await _store.readToken() case final token?)
          'Authorization': 'Bearer $token',
      };
    } on PlatformException {
      throw const UnauthorizedException();
    }
  }

  Future<Object?> get(String path) => _request('GET', path, expected: 200);

  Future<Object?> post(String path, Map<String, Object?> body) =>
      _request('POST', path, expected: 201, body: body);

  Future<Object?> _request(
    String method,
    String path, {
    required int expected,
    Map<String, Object?>? body,
  }) async {
    final uri = Uri.https(host, path);
    final headers = await _headers();
    final response = await _send((abort) async {
      final request = http.AbortableRequest(method, uri, abortTrigger: abort);
      request.headers.addAll(headers);
      if (body != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(body);
      }
      return http.Response.fromStream(await _client.send(request));
    });
    if (kDebugMode) {
      developer.log('$method $uri → ${response.statusCode}', name: 'api');
    }
    _check(response, expected);
    return _decode(response);
  }

  Future<http.Response> _send(
    Future<http.Response> Function(Future<void> abort) call,
  ) async {
    final abort = Completer<void>();
    const deadline = Duration(seconds: 10);
    try {
      return await call(abort.future).timeout(
        deadline,
        onTimeout: () {
          abort.complete();
          throw TimeoutException('HTTP request timed out', deadline);
        },
      );
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      // Browser clients report offline and transport failures this way.
      throw const NoConnectionException();
    }
  }

  void _check(http.Response response, int expected) {
    final status = response.statusCode;
    if (status == 401) throw const UnauthorizedException();
    if (status == 404) throw const NotFoundException();
    if (status >= 500) throw ServerException(status);
    if (status != expected) {
      throw BadResponseException('Expected HTTP $expected, got $status');
    }
  }

  Object? _decode(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException catch (error) {
      throw BadResponseException(error.message);
    }
  }

  void close() => _client.close();
}
