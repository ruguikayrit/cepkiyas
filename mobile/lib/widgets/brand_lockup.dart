import 'package:flutter/material.dart';

class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.height = 36});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Image.asset(
        'assets/brand/teknokiyas-lockup.png',
        height: height,
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
