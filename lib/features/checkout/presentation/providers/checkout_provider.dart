import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/entities/checkout_address.dart';

enum CheckoutStep { address, review, confirmation }

class CheckoutState {
  final CheckoutStep step;
  final CheckoutAddress? address;
  final bool isLoading;
  final String? error;
  final String? confirmedOrderId;

  const CheckoutState({
    this.step = CheckoutStep.address,
    this.address,
    this.isLoading = false,
    this.error,
    this.confirmedOrderId,
  });

  CheckoutState copyWith({
    CheckoutStep? step,
    CheckoutAddress? address,
    bool? isLoading,
    String? error,
    String? confirmedOrderId,
  }) =>
      CheckoutState(
        step: step ?? this.step,
        address: address ?? this.address,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        confirmedOrderId: confirmedOrderId ?? this.confirmedOrderId,
      );
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  CheckoutNotifier({required FirebaseFirestore firestore, required Ref ref})
      : _firestore = firestore,
        _ref = ref,
        super(const CheckoutState());

  void setAddress(CheckoutAddress address) {
    state = state.copyWith(address: address, step: CheckoutStep.review);
  }

  void goBack() {
    if (state.step == CheckoutStep.review) {
      state = state.copyWith(step: CheckoutStep.address);
    }
  }

  Future<void> placeOrder() async {
    if (state.address == null) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _ref.read(authStateProvider).value;
      if (user == null) throw Exception('User not authenticated');

      final cart = _ref.read(cartProvider);
      if (cart.isEmpty) throw Exception('Cart is empty');

      final orderId = const Uuid().v4();
      final address = state.address!;

      final orderData = {
        'id': orderId,
        'userId': user.uid,
        'status': 'pending',
        'items': cart.items
            .map((item) => {
                  'productId': item.product.id,
                  'productName': item.product.name,
                  'productImage': item.product.imageUrls.isNotEmpty ? item.product.imageUrls.first : '',
                  'quantity': item.quantity,
                  'price': item.product.displayPrice,
                  'total': item.itemTotal,
                  'variantId': item.selectedVariant?.id,
                  'variantName': item.selectedVariant?.name,
                })
            .toList(),
        'subtotal': cart.subtotal,
        'deliveryFee': cart.deliveryFee,
        'total': cart.total,
        'totalSavings': cart.totalSavings,
        'address': address.toMap(),
        'paymentMethod': 'cash_on_delivery',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'statusHistory': [
          {
            'status': 'pending',
            'timestamp': FieldValue.serverTimestamp(),
            'note': 'Order placed',
          }
        ],
      };

      await _firestore
          .collection('orders')
          .doc(orderId)
          .set(orderData);

      _ref.read(cartProvider.notifier).clearCart();

      state = state.copyWith(
        isLoading: false,
        step: CheckoutStep.confirmation,
        confirmedOrderId: orderId,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const CheckoutState();
  }
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(
    firestore: FirebaseFirestore.instance,
    ref: ref,
  );
});
