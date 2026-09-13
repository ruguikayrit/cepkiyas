import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app.dart';
import 'state/app_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (details) {
    return ColoredBox(
      color: const Color(0xFFFFFFFF),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            details.exceptionAsString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF0B1220), fontSize: 13),
          ),
        ),
      ),
    );
  };
  Intl.defaultLocale = 'tr_TR';
  await initializeDateFormatting('tr_TR');
  final store = AppStore();
  await store.load();
  runApp(CepKiyasApp(store: store));
}
