import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:ha_ecommerce/core/errors/app_failure.dart';
import 'package:ha_ecommerce/features/products/data/datasources/firestore_product_datasource.dart';
import 'package:ha_ecommerce/features/products/data/models/product_model.dart';
import 'package:ha_ecommerce/features/products/domain/entities/product_entity.dart';
import 'package:ha_ecommerce/features/products/domain/repositories/i_product_repository.dart';

class ProductRepositoryImpl implements IProductRepository {
  final FirestoreProductDataSource _dataSource;
  const ProductRepositoryImpl(this._dataSource);

  @override
  Future<Either<DatabaseFailure, List<ProductEntity>>> getProducts({
    String? categoryId,
    String? searchQuery,
    int? limit,
    String? lastDocumentId,
    bool? featuredOnly,
    bool? flashSaleOnly,
    String? sortBy,
    bool ascending = true,
  }) async {
    try {
      final models = await _dataSource.getProducts(
        categoryId: categoryId,
        limit: limit ?? 20,
        featuredOnly: featuredOnly,
        flashSaleOnly: flashSaleOnly,
        sortBy: sortBy ?? 'createdAt',
        ascending: ascending,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<DatabaseFailure, ProductEntity>> getProductById(String id) async {
    try {
      final model = await _dataSource.getProductById(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(DatabaseFailure.notFound('Product'));
    }
  }

  @override
  Future<Either<DatabaseFailure, List<ProductEntity>>> getRelatedProducts({
    required String productId,
    required String categoryId,
    int limit = 8,
  }) async {
    try {
      final models = await _dataSource.getRelatedProducts(
        productId: productId,
        categoryId: categoryId,
        limit: limit,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<DatabaseFailure, List<CategoryEntity>>> getCategories() async {
    try {
      final models = await _dataSource.getCategories();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<DatabaseFailure, CategoryEntity>> getCategoryById(String id) async {
    try {
      final model = await _dataSource.getCategoryById(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(DatabaseFailure.notFound('Category'));
    }
  }

  @override
  Future<Either<DatabaseFailure, List<BannerEntity>>> getBanners() async {
    try {
      final models = await _dataSource.getBanners();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<DatabaseFailure, List<ReviewEntity>>> getProductReviews(
    String productId, {
    int? limit,
    String? lastDocumentId,
  }) async {
    try {
      final models = await _dataSource.getProductReviews(
        productId,
        limit: limit ?? 10,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<DatabaseFailure, ReviewEntity>> addReview({
    required String productId,
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required double rating,
    required String comment,
    List<String> images = const [],
  }) async {
    try {
      final model = ReviewModel(
        id: '',
        productId: productId,
        userId: userId,
        userName: userName,
        userAvatarUrl: userAvatarUrl,
        rating: rating,
        comment: comment,
        images: images,
        createdAt: DateTime.now(),
      );
      final result = await _dataSource.addReview(model);
      return Right(result.toEntity());
    } catch (e) {
      return Left(DatabaseFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<DatabaseFailure, List<ProductEntity>>> searchProducts({
    required String query,
    int limit = 20,
  }) async {
    try {
      final models = await _dataSource.searchProducts(query, limit: limit);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<DatabaseFailure, ProductEntity>> createProduct(
      ProductEntity product) async {
    try {
      final model = await _dataSource
          .createProduct(ProductModel.fromEntity(product));
      return Right(model.toEntity());
    } catch (e) {
      return Left(DatabaseFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<DatabaseFailure, ProductEntity>> updateProduct(
      ProductEntity product) async {
    try {
      final model = await _dataSource
          .updateProduct(ProductModel.fromEntity(product));
      return Right(model.toEntity());
    } catch (e) {
      return Left(DatabaseFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<DatabaseFailure, Unit>> deleteProduct(String productId) async {
    try {
      await _dataSource.deleteProduct(productId);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<StorageFailure, String>> uploadProductImage({
    required String productId,
    required dynamic imageFile,
  }) async {
    try {
      final url = await _dataSource.uploadProductImage(
        productId: productId,
        imageFile: imageFile as File,
      );
      return Right(url);
    } catch (e) {
      return Left(StorageFailure.uploadFailed());
    }
  }
}
