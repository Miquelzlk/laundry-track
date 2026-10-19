import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const _kUrl = 'server_url';
  static const _kToken = 'token';
  static const _kUser = 'user_name';
  static late SharedPreferences _p;

  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
  }

  static String get defaultUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  static String get baseUrl => _p.getString(_kUrl) ?? defaultUrl;

  static Future<void> setBaseUrl(String v) async {
    var s = v.trim();
    if (s.isEmpty) {
      await _p.remove(_kUrl);
      return;
    }
    if (!s.startsWith('http://') && !s.startsWith('https://')) s = 'http://$s';
    while (s.endsWith('/')) {
      s = s.substring(0, s.length - 1);
    }
    await _p.setString(_kUrl, s);
  }

  static String? get token => _p.getString(_kToken);

  static Future<void> setToken(String? t) async {
    if (t == null) {
      await _p.remove(_kToken);
    } else {
      await _p.setString(_kToken, t);
    }
  }

  static String? get userName => _p.getString(_kUser);

  static Future<void> setUserName(String? n) async {
    if (n == null) {
      await _p.remove(_kUser);
    } else {
      await _p.setString(_kUser, n);
    }
  }
}