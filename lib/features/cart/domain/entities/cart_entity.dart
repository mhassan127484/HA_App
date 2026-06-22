import 'package:equatable/equatable.dart';
import '../../../products/domain/entities/product_entity.dart';

class CartItemEntity extends Equatable {
  final String id;
  final ProductEntity product;
  final int quantity;
  final ProductVariant? selectedVariant;
  final DateTime addedAt;

  const CartItemEntity({
    required this.id,
    required this.product,
    required this.quantity,
    this.selectedVariant,
    required this.addedAt,
  });

  double get itemTotal => product.displayPrice * quantity;
  double get savedAmount => product.isOnSale ? (product.price - product.displayPrice) * quantity : 0;

  CartItemEntity copyWith({int? quantity, ProductVariant? selectedVariant}) =>
      CartItemEntity(
        id: id,
        product: product,
        quantity: quantity ?? this.quantity,
        selectedVariant: selectedVariant ?? this.selectedVariant,
        addedAt: addedAt,
      );

  @override
  List<Object?> get props => [id, product.id, quantity, selectedVariant?.id];
}

class CartEntity extends Equatable {
  final List<CartItemEntity> items;

  const CartEntity({this.items = const []});

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  int get uniqueItemCount => items.length;

  double get subtotal => items.fold(0, (sum, item) => sum + item.itemTotal);
  double get totalSavings => items.fold(0, (sum, item) => sum + item.savedAmount);
  double get deliveryFee => subtotal >= 50 ? 0 : 4.99;
  double get total => subtotal + deliveryFee;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  bool get freeDelivery => subtotal >= 50;

  bool hasProduct(String productId) => items.any((i) => i.product.id == productId);

  CartItemEntity? getItem(String productId) =>
      items.where((i) => i.product.id == productId).firstOrNull;

  @override
  List<Object?> get props => [items];
}
