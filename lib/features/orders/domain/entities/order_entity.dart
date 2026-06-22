import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final List<OrderItemEntity> items;
  final AddressEntity deliveryAddress;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String paymentMethod;
  final String status;
  final List<OrderStatusHistoryEntity> statusHistory;
  final String? notes;
  final String? couponCode;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? estimatedDelivery;
  final String? trackingNumber;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.items,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryFee,
    this.discount = 0,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.statusHistory,
    this.notes,
    this.couponCode,
    required this.createdAt,
    this.updatedAt,
    this.estimatedDelivery,
    this.trackingNumber,
  });

  int get totalItems => items.fold(0, (s, i) => s + i.quantity);
  bool get isCancellable => ['pending', 'confirmed'].contains(status);
  bool get isCompleted => status == 'delivered';

  @override
  List<Object?> get props => [id, userId, status];
}

class OrderItemEntity extends Equatable {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String? variantName;

  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.variantName,
  });

  double get total => price * quantity;

  @override
  List<Object?> get props => [productId, quantity];
}

class AddressEntity extends Equatable {
  final String id;
  final String userId;
  final String fullName;
  final String phoneNumber;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = 'US',
    this.isDefault = false,
  });

  String get fullAddress =>
      '$addressLine1${addressLine2 != null ? ', $addressLine2' : ''}, $city, $state $zipCode';

  @override
  List<Object?> get props => [id, userId, addressLine1];
}

class OrderStatusHistoryEntity extends Equatable {
  final String status;
  final String? message;
  final DateTime timestamp;
  final String? updatedBy;

  const OrderStatusHistoryEntity({
    required this.status,
    this.message,
    required this.timestamp,
    this.updatedBy,
  });

  @override
  List<Object?> get props => [status, timestamp];
}
