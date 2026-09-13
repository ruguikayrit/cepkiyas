import 'package:flutter/material.dart';

import 'app_bootstrap.dart';

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
  runApp(const AppBootstrap());
}
