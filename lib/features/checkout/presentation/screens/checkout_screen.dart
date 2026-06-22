import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/buttons/ha_button.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/entities/checkout_address.dart';
import '../providers/checkout_provider.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkout = ref.watch(checkoutProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            if (checkout.step == CheckoutStep.review) {
              ref.read(checkoutProvider.notifier).goBack();
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          checkout.step == CheckoutStep.address
              ? 'Delivery Address'
              : checkout.step == CheckoutStep.review
                  ? 'Review Order'
                  : 'Order Confirmed',
          style: HATextStyles.h3.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: switch (checkout.step) {
        CheckoutStep.address => _AddressForm(),
        CheckoutStep.review => _OrderReview(),
        CheckoutStep.confirmation =>
          _OrderConfirmation(orderId: checkout.confirmedOrderId ?? ''),
      },
    );
  }
}

// ─── Step Indicator ──────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current; // 0 or 1

  const _StepIndicator({required this.current});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          _StepDot(
              label: 'Address', isActive: current >= 0, isDone: current > 0),
          Expanded(
              child: Container(
                  height: 2,
                  color: current > 0
                      ? HAColors.secondary
                      : HAColors.secondary.withValues(alpha: 0.2))),
          _StepDot(label: 'Review', isActive: current >= 1, isDone: false),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDone;

  const _StepDot(
      {required this.label, required this.isActive, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? HAColors.secondary
                : HAColors.secondary.withValues(alpha: 0.2),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                : Text(
                    label[0],
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: HATextStyles.labelSmall
                .copyWith(color: isActive ? HAColors.secondary : null)),
      ],
    );
  }
}

// ─── Address Form ─────────────────────────────────────────────────────────────

class _AddressForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<_AddressForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _line1Ctrl = TextEditingController();
  final _line2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final address = CheckoutAddress(
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      addressLine1: _line1Ctrl.text.trim(),
      addressLine2: _line2Ctrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      postalCode: _postalCtrl.text.trim(),
    );
    ref.read(checkoutProvider.notifier).setAddress(address);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _StepIndicator(current: 0),
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _FormField(
                    label: 'Full Name',
                    controller: _nameCtrl,
                    hint: 'John Smith',
                    validator: (v) => v!.isEmpty ? 'Required' : null),
                _FormField(
                    label: 'Phone Number',
                    controller: _phoneCtrl,
                    hint: '+1 234 567 8900',
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Required' : null),
                _FormField(
                    label: 'Address Line 1',
                    controller: _line1Ctrl,
                    hint: '123 Main Street',
                    validator: (v) => v!.isEmpty ? 'Required' : null),
                _FormField(
                    label: 'Address Line 2 (Optional)',
                    controller: _line2Ctrl,
                    hint: 'Apt 4B'),
                Row(
                  children: [
                    Expanded(
                      child: _FormField(
                          label: 'City',
                          controller: _cityCtrl,
                          hint: 'New York',
                          validator: (v) => v!.isEmpty ? 'Required' : null),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FormField(
                          label: 'State',
                          controller: _stateCtrl,
                          hint: 'NY',
                          validator: (v) => v!.isEmpty ? 'Required' : null),
                    ),
                  ],
                ),
                _FormField(
                    label: 'Postal Code',
                    controller: _postalCtrl,
                    hint: '10001',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 8),
                // COD Notice
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: HAColors.secondary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: HAColors.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_outlined,
                          color: HAColors.secondary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Payment: Cash on Delivery',
                          style: HATextStyles.bodyMedium.copyWith(
                            color: HAColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: HAButton(
            label: 'Continue to Review',
            onPressed: _submit,
            leadingIcon: Icons.arrow_forward_rounded,
          ),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: HATextStyles.labelMedium),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: HATextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: HATextStyles.bodyMedium.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
              ),
              filled: true,
              fillColor:
                  isDark ? HAColors.darkBackground : HAColors.lightBackground,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDark ? HAColors.darkBorder : HAColors.lightBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDark ? HAColors.darkBorder : HAColors.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: HAColors.secondary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: HAColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Order Review ─────────────────────────────────────────────────────────────

class _OrderReview extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final checkout = ref.watch(checkoutProvider);
    final address = checkout.address!;

    return Column(
      children: [
        const _StepIndicator(current: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Delivery Address
              _ReviewSection(
                title: 'Delivery Address',
                icon: Icons.location_on_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address.fullName,
                        style: HATextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text(address.phone,
                        style: HATextStyles.bodySmall.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7))),
                    const SizedBox(height: 4),
                    Text(address.displayAddress, style: HATextStyles.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Items
              _ReviewSection(
                title: '${cart.itemCount} Items',
                icon: Icons.shopping_bag_outlined,
                child: Column(
                  children: cart.items
                      .map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.product.name}${item.selectedVariant != null ? ' (${item.selectedVariant!.name})' : ''} × ${item.quantity}',
                                    style: HATextStyles.bodySmall,
                                  ),
                                ),
                                Text('\$${item.itemTotal.toStringAsFixed(2)}',
                                    style: HATextStyles.bodySmall
                                        .copyWith(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Payment
              _ReviewSection(
                title: 'Payment Method',
                icon: Icons.payments_outlined,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: HAColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('COD',
                          style: HATextStyles.labelSmall
                              .copyWith(color: HAColors.secondary)),
                    ),
                    const SizedBox(width: 8),
                    const Text('Cash on Delivery',
                        style: HATextStyles.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Totals
              _ReviewSection(
                title: 'Order Total',
                icon: Icons.receipt_outlined,
                child: Column(
                  children: [
                    _TotalRow(
                        'Subtotal', '\$${cart.subtotal.toStringAsFixed(2)}'),
                    if (cart.totalSavings > 0)
                      _TotalRow('Savings',
                          '-\$${cart.totalSavings.toStringAsFixed(2)}',
                          color: HAColors.success),
                    _TotalRow(
                        'Delivery',
                        cart.freeDelivery
                            ? 'FREE'
                            : '\$${cart.deliveryFee.toStringAsFixed(2)}',
                        color: cart.freeDelivery ? HAColors.success : null),
                    const Divider(height: 16),
                    _TotalRow('Total', '\$${cart.total.toStringAsFixed(2)}',
                        isBold: true),
                  ],
                ),
              ),

              if (checkout.error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: HAColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(checkout.error!,
                      style: const TextStyle(color: HAColors.error)),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: HAButton(
            label: checkout.isLoading ? 'Placing Order...' : 'Place Order',
            onPressed: checkout.isLoading
                ? null
                : () => ref.read(checkoutProvider.notifier).placeOrder(),
            isLoading: checkout.isLoading,
            leadingIcon: Icons.check_circle_outline_rounded,
          ),
        ),
      ],
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _ReviewSection(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? HAColors.darkSurface : HAColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? HAColors.darkBorder : HAColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: HAColors.secondary),
              const SizedBox(width: 8),
              Text(title,
                  style: HATextStyles.labelLarge
                      .copyWith(color: HAColors.secondary)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const _TotalRow(this.label, this.value, {this.isBold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isBold
                  ? HATextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)
                  : HATextStyles.bodyMedium),
          Text(value,
              style: (isBold
                      ? HATextStyles.priceMain
                      : HATextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600))
                  .copyWith(color: color)),
        ],
      ),
    );
  }
}

// ─── Order Confirmation ───────────────────────────────────────────────────────

class _OrderConfirmation extends ConsumerWidget {
  final String orderId;

  const _OrderConfirmation({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: HAColors.success.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  size: 56, color: HAColors.success),
            ),
            const SizedBox(height: 24),
            Text('Order Placed!',
                style: HATextStyles.h2
                    .copyWith(color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text(
              'Your order has been confirmed. We\'ll notify you when it\'s on its way.',
              textAlign: TextAlign.center,
              style: HATextStyles.bodyMedium.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: HAColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Order #${orderId.substring(0, 8).toUpperCase()}',
                style: HATextStyles.labelMedium.copyWith(
                    color: HAColors.secondary, fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 32),
            HAButton(
              label: 'Track Order',
              onPressed: () {
                ref.read(checkoutProvider.notifier).reset();
                context.go('/orders');
              },
              leadingIcon: Icons.local_shipping_outlined,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                ref.read(checkoutProvider.notifier).reset();
                context.go('/home');
              },
              child: const Text('Continue Shopping',
                  style: TextStyle(color: HAColors.secondary)),
            ),
          ],
        ),
      ),
    );
  }
}
