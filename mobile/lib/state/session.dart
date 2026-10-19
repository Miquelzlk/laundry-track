import 'package:flutter/foundation.dart';

import '../core/api.dart';
import '../core/config.dart';

class DataBus extends ChangeNotifier {
  DataBus._();
  static final DataBus i = DataBus._();

  void bump() => notifyListeners();
}

class Session extends ChangeNotifier {
  Session._();
  static final Session instance = Session._();

  bool get loggedIn => AppConfig.token != null;

  Future<void> login(String email, String password) async {
    final r = await ApiClient.post('/login', {
      'email': email,
      'password': password,
    }, auth: false);
    await AppConfig.setToken('${r['token']}');
    await AppConfig.setUserName('${r['user']['name']}');
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await ApiClient.post('/logout', {});
    } catch (_) {}
    await AppConfig.setToken(null);
    await AppConfig.setUserName(null);
    notifyListeners();
  }

  void expire() {
    AppConfig.setToken(null);
    AppConfig.setUserName(null);
    notifyListeners();
  }
}
