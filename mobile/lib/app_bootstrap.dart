import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app.dart';
import 'state/app_store.dart';
import 'theme.dart';
import 'widgets/brand_lockup.dart';
import 'widgets/brand_tagline.dart';

/// Önce arayüzü gösterir, katalog yüklemesini arka planda yapar.
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  AppStore? _store;
  Object? _error;
  StackTrace? _stack;
  var _splashDone = false;
  var _loadStarted = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    if (_loadStarted) return;
    _loadStarted = true;
    try {
      Intl.defaultLocale = 'tr_TR';
      await initializeDateFormatting('tr_TR');
      final store = AppStore();
      await store.load();
      if (!mounted) return;
      setState(() => _store = store);
      await Future<void>.delayed(const Duration(milliseconds: 1600));
      if (!mounted) return;
      setState(() => _splashDone = true);
    } catch (error, stack) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _stack = stack;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Ck.bg,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Text(
                  'Uygulama yüklenemedi:\n$_error\n\n$_stack',
                  style: const TextStyle(color: Ck.ink, fontSize: 13, height: 1.4),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_store == null || !_splashDone) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Ck.theme(),
        home: Scaffold(
          backgroundColor: Ck.bg,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const BrandLockup(height: 44),
                    const SizedBox(height: 20),
                    const BrandTagline(),
                    const SizedBox(height: 48),
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Ck.mint),
                    ),
                    if (_store == null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Katalog hazırlanıyor…',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return CepKiyasApp(store: _store!);
  }
}
