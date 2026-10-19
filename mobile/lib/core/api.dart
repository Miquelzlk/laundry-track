import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, [this.status]);

  @override
  String toString() => message;
}

class ApiClient {
  static void Function()? onUnauthorized;

  static Uri _uri(String path, [Map<String, String>? query]) {
    final u = Uri.parse('${AppConfig.baseUrl}/api$path');
    return (query == null || query.isEmpty)
        ? u
        : u.replace(queryParameters: query);
  }

  static Map<String, String> _headers(bool auth) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (auth && AppConfig.token != null)
      'Authorization': 'Bearer ${AppConfig.token}',
  };

  static const _offline =
      'Tidak dapat terhubung ke server. Pastikan Laravel berjalan dan alamat server sudah benar.';

  static Future<dynamic> _run(
    Future<http.Response> Function() call,
    bool auth,
  ) async {
    http.Response res;
    try {
      res = await call().timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw ApiException(
        'Server tidak merespons. Periksa alamat server dan koneksi Anda.',
      );
    } catch (_) {
      throw ApiException(_offline);
    }

    dynamic body;
    if (res.body.isNotEmpty) {
      try {
        body = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {
        body = null;
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) return body;

    if (res.statusCode == 401 && auth) {
      onUnauthorized?.call();
      throw ApiException('Sesi berakhir, silakan masuk kembali.', 401);
    }

    var msg = 'Terjadi kesalahan (kode ${res.statusCode}).';
    if (body is Map) {
      final errors = body['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        msg = first is List && first.isNotEmpty ? '${first.first}' : '$first';
      } else if (body['message'] != null) {
        msg = '${body['message']}';
      }
    }
    throw ApiException(msg, res.statusCode);
  }

  static Future<dynamic> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
  }) => _run(() => http.get(_uri(path, query), headers: _headers(auth)), auth);

  static Future<dynamic> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) => _run(
    () =>
        http.post(_uri(path), headers: _headers(auth), body: jsonEncode(body)),
    auth,
  );

  static Future<dynamic> patch(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) => _run(
    () =>
        http.patch(_uri(path), headers: _headers(auth), body: jsonEncode(body)),
    auth,
  );
}
