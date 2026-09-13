import 'package:flutter/material.dart';

import '../typography.dart';

/// Metin tabanlı TeknoKıyas — web’de net, ölçeklenebilir.
class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.height = 32});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'TeknoKıyas',
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'Tekno', style: CkType.brandTekno(height)),
            TextSpan(text: 'Kıyas', style: CkType.brandKiyas(height)),
          ],
        ),
      ),
    );
  }
}
