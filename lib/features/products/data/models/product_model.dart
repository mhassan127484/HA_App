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
}
