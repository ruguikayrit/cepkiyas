import 'package:flutter/material.dart';

import '../logic/product_media.dart';
import '../models/phone.dart';
import '../theme.dart';

class ProductPromoGallery extends StatefulWidget {
  const ProductPromoGallery({super.key, required this.phone, this.height = 280});

  final Phone phone;
  final double height;

  @override
  State<ProductPromoGallery> createState() => _ProductPromoGalleryState();
}

class _ProductPromoGalleryState extends State<ProductPromoGallery> {
  late final PageController _page;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _page = PageController();
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = promoImagesFor(widget.phone);
    if (images.isEmpty) {
      return _Placeholder(height: widget.height, label: widget.phone.fullName);
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _page,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => _PromoImage(url: images[i], label: widget.phone.name),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < images.length; i++)
                Container(
                  width: i == _index ? 18 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _index ? Ck.mint : Ck.line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _PromoImage extends StatelessWidget {
  const _PromoImage({required this.url, required this.label});

  final String url;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Ck.panel2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Ck.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.startsWith('http')
          ? Image.network(
              url,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, _, _) => _Placeholder(height: double.infinity, label: label),
            )
          : Image.asset(
              'assets$url',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, _, _) => _Placeholder(height: double.infinity, label: label),
            ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.height, required this.label});

  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height == double.infinity ? null : height,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Ck.mute),
      ),
    );
  }
}
