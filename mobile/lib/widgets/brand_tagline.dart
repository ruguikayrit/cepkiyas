import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';

/// Referans wordmark altı: Kıyasla. Puanla. Karar ver.
class BrandTagline extends StatelessWidget {
  const BrandTagline({super.key, this.align = TextAlign.center, this.color, this.compact = false});

  final TextAlign align;
  final Color? color;
  final bool compact;

  static const phrases = ['Kıyasla.', 'Puanla.', 'Karar ver.'];

  @override
  Widget build(BuildContext context) {
    final ink = color ?? Ck.mute;
    if (compact) {
      return Text(
        phrases.join(' '),
        textAlign: align,
        style: GoogleFonts.manrope(
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 1.2,
          color: ink.withValues(alpha: 0.92),
        ),
      );
    }

    return Text.rich(
      TextSpan(
        style: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          height: 1.35,
          color: ink,
        ),
        children: [
          for (var i = 0; i < phrases.length; i++) ...[
            if (i > 0) const TextSpan(text: ' '),
            TextSpan(
              text: phrases[i],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
      textAlign: align,
    );
  }
}
