import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/api.dart';
import 'core/config.dart';
import 'core/theme.dart';
import 'screens/login_screen.dart';
import 'screens/shell_screen.dart';
import 'state/session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.init();
  await initializeDateFormatting('id_ID');
  ApiClient.onUnauthorized = Session.instance.expire;
  runApp(const BilasApp());
}

class BilasApp extends StatelessWidget {
  const BilasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bilas',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: ListenableBuilder(
        listenable: Session.instance,
        builder: (context, _) =>
            Session.instance.loggedIn ? const ShellScreen() : const LoginScreen(),
      ),
    );
  }
}