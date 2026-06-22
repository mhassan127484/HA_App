import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ha_product_card.dart';
import '../../../../core/widgets/ha_shimmer.dart';
import '../../../products/presentation/providers/product_provider.dart';

class FlashSaleSection extends ConsumerStatefulWidget {
  const FlashSaleSection({super.key});

  @override
  ConsumerState<FlashSaleSection> createState() => _FlashSaleSectionState();
}

class _FlashSaleSectionState extends ConsumerState<FlashSaleSection> {
  late Timer _timer;
  Duration _remaining = const Duration(hours: 5, minutes: 42, seconds: 10);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds > 0) {
        setState(() => _remaining -= const Duration(seconds: 1));
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flash = ref.watch(flashSaleProductsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => HAColors.flashSaleGradient.createShader(bounds),
                child: Text(
                  '⚡ Flash Sale',
                  style: HATextStyles.h4.copyWith(color: Colors.white),
                ),
              ),
              const Spacer(),
              _CountdownTimer(remaining: _remaining),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: flash.when(
            loading: () => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, __) => const SizedBox(width: 180, child: HAProductCardSkeleton()),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (products) => products.isEmpty
                ? _buildEmptyFlashSale()
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (ctx, i) => SizedBox(
                      width: 180,
                      child: HAProductCard(
                        product: products[i],
                        onTap: () => context.push('/products/${products[i].id}'),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyFlashSale() => Center(
    child: Text(
      'No flash sales right now',
      style: HATextStyles.bodyMedium.copyWith(color: HAColors.slate400),
    ),
  );
}

class _CountdownTimer extends StatelessWidget {
  final Duration remaining;
  const _CountdownTimer({required this.remaining});

  @override
  Widget build(BuildContext context) {
    String pad(int n) => n.toString().padLeft(2, '0');
    final h = pad(remaining.inHours);
    final m = pad(remaining.inMinutes.remainder(60));
    final s = pad(remaining.inSeconds.remainder(60));

    return Row(
      children: [
        _TimeBox(value: h, label: 'h'),
        const _Colon(),
        _TimeBox(value: m, label: 'm'),
        const _Colon(),
        _TimeBox(value: s, label: 's'),
      ],
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String value;
  final String label;
  const _TimeBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      gradient: HAColors.flashSaleGradient,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      value,
      style: HATextStyles.labelLarge.copyWith(color: Colors.white, fontSize: 13),
    ),
  );
}

class _Colon extends StatelessWidget {
  const _Colon();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 3),
    child: Text(':', style: TextStyle(color: HAColors.error, fontWeight: FontWeight.w700, fontSize: 16)),
  );
}
