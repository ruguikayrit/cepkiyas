import 'dart:async';

import 'package:flutter/material.dart';

import '../shell.dart';
import '../state/app_store.dart';
import '../theme.dart';
import '../widgets/brand_lockup.dart';
import '../widgets/brand_tagline.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.store});
  final AppStore store;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _fade;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _opacity = CurvedAnimation(parent: _fade, curve: Curves.easeOut);
    _fade.forward();
    unawaited(_goNext());
  }

  Future<void> _goNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => Shell(store: widget.store),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ck.bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _opacity,
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
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Ck.mint.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
