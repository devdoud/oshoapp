import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/circular_container.dart';
import 'package:osho/common/widgets/loaders/skeleton.dart';
import 'package:osho/features/shop/models/product_model.dart';

class OProductDetailImageSlider extends StatefulWidget {
  const OProductDetailImageSlider({super.key, required this.product});

  final ProductModel product;

  @override
  State<OProductDetailImageSlider> createState() =>
      _OProductDetailImageSliderState();
}

class _OProductDetailImageSliderState
    extends State<OProductDetailImageSlider> {
  late final PageController _pageController;
  late final List<String> _images;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _images = _buildImageList();
    debugPrint('[ImageSlider] ${_images.length} image(s) → $_images');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> _buildImageList() {
    final extra = <String>[];
    final raw = widget.product.images;
    if (raw != null && raw.isNotEmpty) {
      for (final s in raw) {
        final clean = s.trim();
        if (clean.startsWith('[')) {
          try {
            extra.addAll((jsonDecode(clean) as List).map((e) => e.toString()));
            continue;
          } catch (_) {}
        }
        extra.add(clean);
      }
    }

    final seen = <String>{};
    final images = <String>[];
    for (final url in [widget.product.thumbnail, ...extra]) {
      final clean = url.trim();
      if (clean.isNotEmpty && seen.add(clean)) images.add(clean);
    }
    if (images.isEmpty && widget.product.thumbnail.isNotEmpty) {
      images.add(widget.product.thumbnail);
    }
    return images;
  }

  @override
  Widget build(BuildContext context) {
    // Ce widget est rendu dans un Positioned en dehors du CustomScrollView,
    // donc PageView peut gérer ses gestes horizontaux sans conflit.
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _images.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (_, index) {
            final url = _images[index];
            final provider = url.startsWith('http')
                ? NetworkImage(url)
                : AssetImage(url) as ImageProvider;
            return Stack(
              fit: StackFit.expand,
              children: [
                const OSkeleton(
                    height: double.infinity,
                    width: double.infinity,
                    radius: 0),
                Image(
                  image: provider,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child:
                        Icon(Iconsax.image, color: Colors.grey, size: 40),
                  ),
                ),
              ],
            );
          },
        ),

        // Compteur X / Y
        if (_images.length > 1)
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentIndex + 1} / ${_images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        // Dots
        if (_images.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < _images.length; i++)
                  OCircularContainer(
                    width: _currentIndex == i ? 32 : 8,
                    height: 4,
                    radius: 10,
                    padding: 0,
                    margin: const EdgeInsets.only(right: 6),
                    backgroundColor: _currentIndex == i
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.35),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
