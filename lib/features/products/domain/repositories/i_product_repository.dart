import 'package:dartz/dartz.dart';
import 'package:ha_ecommerce/core/errors/app_failure.dart';
import 'package:ha_ecommerce/features/products/domain/entities/product_entity.dart';

abstract class IProductRepository {
  Future<Either<DatabaseFailure, List<ProductEntity>>> getProducts({
    String? categoryId,
    String? searchQuery,
    int? limit,
    String? lastDocumentId,
    bool? featuredOnly,
    bool? flashSaleOnly,
    String? sortBy,
    bool ascending = true,
  });

  Future<Either<DatabaseFailure, ProductEntity>> getProductById(String id);

  Future<Either<DatabaseFailure, List<ProductEntity>>> getRelatedProducts({
    required String productId,
    required String categoryId,
    int limit = 8,
  });

  Future<Either<DatabaseFailure, List<CategoryEntity>>> getCategories();

  Future<Either<DatabaseFailure, CategoryEntity>> getCategoryById(String id);

  Future<Either<DatabaseFailure, List<BannerEntity>>> getBanners();

  Future<Either<DatabaseFailure, List<ReviewEntity>>> getProductReviews(
    String productId, {
    int? limit,
    String? lastDocumentId,
  });

  Future<Either<DatabaseFailure, ReviewEntity>> addReview({
    required String productId,
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required double rating,
    required String comment,
    List<String> images = const [],
  });

  Future<Either<DatabaseFailure, List<ProductEntity>>> searchProducts({
    required String query,
    int limit = 20,
  });

  // Admin operations
  Future<Either<DatabaseFailure, ProductEntity>> createProduct(ProductEntity product);
  Future<Either<DatabaseFailure, ProductEntity>> updateProduct(ProductEntity product);
  Future<Either<DatabaseFailure, Unit>> deleteProduct(String productId);
  Future<Either<StorageFailure, String>> uploadProductImage({
    required String productId,
    required dynamic imageFile,
  });
}
