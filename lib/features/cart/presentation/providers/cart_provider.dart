import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/cart_entity.dart';

class CartNotifier extends StateNotifier<CartEntity> {
  final FirebaseFirestore _firestore;
  final String? _userId;

  CartNotifier({required FirebaseFirestore firestore, required String? userId})
      : _firestore = firestore,
        _userId = userId,
        super(const CartEntity()) {
    if (userId != null) _loadCart();
  }

  Future<void> _loadCart() async {
    // Load from Firestore in a real app
    // For now, local state management
  }

  Future<void> _syncCart() async {
    if (_userId == null) return;
    // Sync to Firestore
  }

  void addItem(ProductEntity product, {int quantity = 1, ProductVariant? variant}) {
    final existing = state.getItem(product.id);
    if (existing != null) {
      final newQty = (existing.quantity + quantity).clamp(1, AppConstants.cartMaxQuantity);
      final updated = state.items.map((i) =>
          i.product.id == product.id ? i.copyWith(quantity: newQty) : i).toList();
      state = CartEntity(items: updated);
    } else {
      final item = CartItemEntity(
        id: const Uuid().v4(),
        product: product,
        quantity: quantity,
        selectedVariant: variant,
        addedAt: DateTime.now(),
      );
      state = CartEntity(items: [...state.items, item]);
    }
    _syncCart();
  }

  void removeItem(String productId) {
    state = CartEntity(items: state.items.where((i) => i.product.id != productId).toList());
    _syncCart();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    final updated = state.items.map((i) =>
        i.product.id == productId
            ? i.copyWith(quantity: quantity.clamp(1, AppConstants.cartMaxQuantity))
            : i).toList();
    state = CartEntity(items: updated);
    _syncCart();
  }

  void clearCart() {
    state = const CartEntity();
    _syncCart();
  }

  bool isInCart(String productId) => state.hasProduct(productId);
}

final cartProvider = StateNotifierProvider<CartNotifier, CartEntity>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.uid;
  return CartNotifier(
    firestore: FirebaseFirestore.instance,
    userId: userId,
  );
});

// Convenience providers
final cartItemCountProvider = Provider<int>((ref) => ref.watch(cartProvider).itemCount);
final cartTotalProvider = Provider<double>((ref) => ref.watch(cartProvider).total);
