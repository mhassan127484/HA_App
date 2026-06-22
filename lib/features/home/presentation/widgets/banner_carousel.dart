import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ha_shimmer.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../products/domain/entities/product_entity.dart';

class BannerCarousel extends ConsumerStatefulWidget {
  const BannerCarousel({super.key});

  @override
  ConsumerState<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends ConsumerState<BannerCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Using featured products as banner placeholders
    // In production, use bannersProvider
    return Column(
      children: [
        _buildCarousel(),
        const SizedBox(height: 12),
        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: 3,
          effect: ExpandingDotsEffect(
            activeDotColor: HAColors.secondary,
            dotColor: HAColors.slate600,
            dotHeight: 6,
            dotWidth: 6,
            expansionFactor: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildCarousel() => CarouselSlider(
    options: CarouselOptions(
      height: 190,
      viewportFraction: 0.88,
      enlargeCenterPage: true,
      enlargeFactor: 0.15,
      autoPlay: true,
      autoPlayInterval: const Duration(seconds: 4),
      autoPlayCurve: Curves.easeInOutCubic,
      onPageChanged: (i, _) => setState(() => _currentIndex = i),
    ),
    items: List.generate(3, (i) => _BannerItem(index: i)),
  );
}

class _BannerItem extends StatelessWidget {
  final int index;
  const _BannerItem({required this.index});

  static const _banners = [
    _BannerData(
      gradient: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
      title: 'Summer Sale',
      subtitle: 'Up to 50% off on selected items',
      badge: 'Limited Time',
    ),
    _BannerData(
      gradient: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
      title: 'New Arrivals',
      subtitle: 'Fresh drops every week',
      badge: 'Just In',
    ),
    _BannerData(
      gradient: [Color(0xFF06B6D4), Color(0xFF0891B2)],
      title: 'Free Delivery',
      subtitle: 'On orders above \$50',
      badge: 'Always',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final banner = _banners[index % _banners.length];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: banner.gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: banner.gradient.first.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                banner.badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              banner.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              banner.subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Shop Now',
                style: TextStyle(
                  color: banner.gradient.first,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerData {
  final List<Color> gradient;
  final String title;
  final String subtitle;
  final String badge;
  const _BannerData({
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.badge,
  });
}
