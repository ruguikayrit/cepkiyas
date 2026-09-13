import 'package:flutter/material.dart';

import '../theme.dart';
import '../typography.dart';

/// Wordmark altındaki üç ifade — açılış ve tanıtım alanlarında.
class BrandTagline extends StatelessWidget {
  const BrandTagline({super.key, this.align = TextAlign.center, this.color, this.compact = false});

  final TextAlign align;
  final Color? color;
  final bool compact;

  static const lines = [
    'Modelleri yan yana getir.',
    'Topluluk puanıyla değerlendir.',
    'Kararını veriye dayandır.',
  ];

  @override
  Widget build(BuildContext context) {
    final style = CkType.textTheme().bodyMedium?.copyWith(
          color: color ?? Ck.mute,
          height: 1.55,
          fontWeight: FontWeight.w500,
        );
    final compactStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color ?? Ck.mute,
          height: 1.35,
          fontSize: 10.5,
        );
    final lineStyle = compact ? compactStyle : style;
    return Column(
      crossAxisAlignment: align == TextAlign.center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Text(line, textAlign: align, style: lineStyle),
      ],
    );
  }
}
