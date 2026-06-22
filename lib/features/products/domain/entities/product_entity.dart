import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? salePrice;
  final double? originalPrice;
  final String categoryId;
  final String categoryName;
  final List<String> imageUrls;
  final double rating;
  final int reviewCount;
  final int stockQuantity;
  final bool isAvailable;
  final String status;
  final List<String> tags;
  final Map<String, dynamic>? specifications;
  final List<ProductVariant> variants;
  final String? brand;
  final String? sku;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;
  final bool isFeatured;
  final bool isFlashSale;
  final DateTime? flashSaleEnd;
  final int? soldCount;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.salePrice,
    this.originalPrice,
    required this.categoryId,
    required this.categoryName,
    required this.imageUrls,
    this.rating = 0,
    this.reviewCount = 0,
    required this.stockQuantity,
    this.isAvailable = true,
    this.status = 'active',
    this.tags = const [],
    this.specifications,
    this.variants = const [],
    this.brand,
    this.sku,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
    this.isFeatured = false,
    this.isFlashSale = false,
    this.flashSaleEnd,
    this.soldCount,
  });

  double get displayPrice => salePrice ?? price;
  bool get isOnSale => salePrice != null && salePrice! < price;
  int get discountPercent => isOnSale
      ? (((price - salePrice!) / price) * 100).round()
      : 0;
  bool get isInStock => stockQuantity > 0 && isAvailable;
  String get primaryImage => imageUrls.isNotEmpty ? imageUrls.first : '';

  @override
  List<Object?> get props => [id, name, price, salePrice, rating, stockQuantity];
}

class ProductVariant extends Equatable {
  final String id;
  final String name;
  final String type; // 'color', 'size', 'storage'
  final String? value;
  final double? additionalPrice;
  final int? stock;
  final String? colorHex;

  const ProductVariant({
    required this.id,
    required this.name,
    required this.type,
    this.value,
    this.additionalPrice,
    this.stock,
    this.colorHex,
  });

  @override
  List<Object?> get props => [id, name, type];
}

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final String? iconName;
  final String? colorHex;
  final int productCount;
  final int sortOrder;
  final bool isActive;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    this.iconName,
    this.colorHex,
    this.productCount = 0,
    this.sortOrder = 0,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name];
}

class ReviewEntity extends Equatable {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String comment;
  final List<String> imageUrls;
  final DateTime createdAt;
  final int helpfulCount;

  const ReviewEntity({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    this.imageUrls = const [],
    required this.createdAt,
    this.helpfulCount = 0,
  });

  @override
  List<Object?> get props => [id, productId, userId];
}

class BannerEntity extends Equatable {
  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? deepLink;
  final int sortOrder;
  final bool isActive;
  final DateTime? expiresAt;

  const BannerEntity({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.deepLink,
    this.sortOrder = 0,
    this.isActive = true,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [id, title];
}
