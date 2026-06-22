import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    super.salePrice,
    super.originalPrice,
    required super.categoryId,
    required super.categoryName,
    required super.imageUrls,
    super.rating,
    super.reviewCount,
    required super.stockQuantity,
    super.isAvailable,
    super.status,
    super.tags,
    super.specifications,
    super.variants,
    super.brand,
    super.sku,
    required super.createdAt,
    super.updatedAt,
    required super.createdBy,
    super.isFeatured,
    super.isFlashSale,
    super.flashSaleEnd,
    super.soldCount,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: d['name'] ?? '',
      description: d['description'] ?? '',
      price: (d['price'] ?? 0).toDouble(),
      salePrice: d['salePrice']?.toDouble(),
      originalPrice: d['originalPrice']?.toDouble(),
      categoryId: d['categoryId'] ?? '',
      categoryName: d['categoryName'] ?? '',
      imageUrls: List<String>.from(d['imageUrls'] ?? []),
      rating: (d['rating'] ?? 0).toDouble(),
      reviewCount: d['reviewCount'] ?? 0,
      stockQuantity: d['stockQuantity'] ?? 0,
      isAvailable: d['isAvailable'] ?? true,
      status: d['status'] ?? 'active',
      tags: List<String>.from(d['tags'] ?? []),
      specifications: d['specifications'],
      variants: ((d['variants'] as List<dynamic>?) ?? [])
          .map((v) => ProductVariant(
                id: v['id'] ?? '',
                name: v['name'] ?? '',
                type: v['type'] ?? '',
                value: v['value'],
                additionalPrice: v['additionalPrice']?.toDouble(),
                stock: v['stock'],
                colorHex: v['colorHex'],
              ))
          .toList(),
      brand: d['brand'],
      sku: d['sku'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
      createdBy: d['createdBy'] ?? '',
      isFeatured: d['isFeatured'] ?? false,
      isFlashSale: d['isFlashSale'] ?? false,
      flashSaleEnd: (d['flashSaleEnd'] as Timestamp?)?.toDate(),
      soldCount: d['soldCount'],
    );
  }

  Map<String, dynamic> toFirestore() => toMap();

  ProductEntity toEntity() => this;

  factory ProductModel.fromEntity(ProductEntity e) => ProductModel(
    id: e.id,
    name: e.name,
    description: e.description,
    price: e.price,
    salePrice: e.salePrice,
    originalPrice: e.originalPrice,
    categoryId: e.categoryId,
    categoryName: e.categoryName,
    imageUrls: e.imageUrls,
    rating: e.rating,
    reviewCount: e.reviewCount,
    stockQuantity: e.stockQuantity,
    isAvailable: e.isAvailable,
    status: e.status,
    tags: e.tags,
    specifications: e.specifications,
    variants: e.variants,
    brand: e.brand,
    sku: e.sku,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
    createdBy: e.createdBy,
    isFeatured: e.isFeatured,
    isFlashSale: e.isFlashSale,
    flashSaleEnd: e.flashSaleEnd,
    soldCount: e.soldCount,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'price': price,
    'salePrice': salePrice,
    'originalPrice': originalPrice,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'imageUrls': imageUrls,
    'rating': rating,
    'reviewCount': reviewCount,
    'stockQuantity': stockQuantity,
    'isAvailable': isAvailable,
    'status': status,
    'tags': tags,
    'specifications': specifications,
    'variants': variants.map((v) => {
      'id': v.id, 'name': v.name, 'type': v.type,
      'value': v.value, 'additionalPrice': v.additionalPrice,
      'stock': v.stock, 'colorHex': v.colorHex,
    }).toList(),
    'brand': brand,
    'sku': sku,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.now(),
    'createdBy': createdBy,
    'isFeatured': isFeatured,
    'isFlashSale': isFlashSale,
    'flashSaleEnd': flashSaleEnd != null ? Timestamp.fromDate(flashSaleEnd!) : null,
    'soldCount': soldCount,
  };
}

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    super.imageUrl,
    super.iconName,
    super.colorHex,
    super.productCount,
    super.sortOrder,
    super.isActive,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: d['name'] ?? '',
      imageUrl: d['imageUrl'],
      iconName: d['iconName'],
      colorHex: d['colorHex'],
      productCount: d['productCount'] ?? 0,
      sortOrder: d['sortOrder'] ?? 0,
      isActive: d['isActive'] ?? true,
    );
  }

  CategoryEntity toEntity() => this;

  factory CategoryModel.fromEntity(CategoryEntity e) => CategoryModel(
    id: e.id,
    name: e.name,
    imageUrl: e.imageUrl,
    iconName: e.iconName,
    colorHex: e.colorHex,
    productCount: e.productCount,
    sortOrder: e.sortOrder,
    isActive: e.isActive,
  );
}

class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.title,
    super.subtitle,
    required super.imageUrl,
    super.deepLink,
    super.sortOrder,
    super.isActive,
    super.expiresAt,
  });

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return BannerModel(
      id: doc.id,
      title: d['title'] ?? '',
      subtitle: d['subtitle'],
      imageUrl: d['imageUrl'] ?? '',
      deepLink: d['deepLink'],
      sortOrder: d['sortOrder'] ?? 0,
      isActive: d['isActive'] ?? true,
      expiresAt: (d['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'subtitle': subtitle,
    'imageUrl': imageUrl,
    'deepLink': deepLink,
    'sortOrder': sortOrder,
    'isActive': isActive,
    'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
  };

  BannerEntity toEntity() => this;
}

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.productId,
    required super.userId,
    required super.userName,
    super.userAvatar,
    required super.rating,
    required super.comment,
    super.imageUrls,
    required super.createdAt,
    super.helpfulCount,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      productId: d['productId'] ?? '',
      userId: d['userId'] ?? '',
      userName: d['userName'] ?? '',
      userAvatar: d['userAvatar'],
      rating: (d['rating'] ?? 0).toDouble(),
      comment: d['comment'] ?? '',
      imageUrls: List<String>.from(d['imageUrls'] ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      helpfulCount: d['helpfulCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'productId': productId,
    'userId': userId,
    'userName': userName,
    'userAvatar': userAvatar,
    'rating': rating,
    'comment': comment,
    'imageUrls': imageUrls,
    'createdAt': Timestamp.fromDate(createdAt),
    'helpfulCount': helpfulCount,
  };

  ReviewEntity toEntity() => this;
}
