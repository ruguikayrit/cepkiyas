import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/detail_screen.dart';
import 'screens/search_screen.dart';
import 'screens/splash_screen.dart';
import 'state/app_store.dart';
import 'theme.dart';

class CepKiyasApp extends StatelessWidget {
  const CepKiyasApp({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeknoKıyas',
      debugShowCheckedModeBanner: false,
      theme: Ck.theme(),
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: SplashScreen(store: store),
      onGenerateRoute: (settings) {
        if (settings.name == '/telefon') {
          return MaterialPageRoute(
            builder: (_) => DetailScreen(store: store, phoneId: settings.arguments as String),
          );
        }
        if (settings.name == '/ara') {
          return MaterialPageRoute(builder: (_) => SearchScreen(store: store));
        }
        return null;
      },
    );
  }
}
