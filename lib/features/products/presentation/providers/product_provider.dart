import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../domain/entities/product_entity.dart';

final productDataSourceProvider = Provider<ProductRemoteDataSource>((ref) =>
    ProductRemoteDataSourceImpl(
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
    ));

// ── Simple async providers ─────────────────────────────────────────
final featuredProductsProvider = FutureProvider<List<ProductEntity>>((ref) =>
    ref.read(productDataSourceProvider).getFeaturedProducts());

final flashSaleProductsProvider = FutureProvider<List<ProductEntity>>((ref) =>
    ref.read(productDataSourceProvider).getFlashSaleProducts());

final trendingProductsProvider = FutureProvider<List<ProductEntity>>((ref) =>
    ref.read(productDataSourceProvider).getTrendingProducts());

final categoriesProvider = FutureProvider<List<CategoryEntity>>((ref) =>
    ref.read(productDataSourceProvider).getCategories());

final productDetailProvider = FutureProvider.family<ProductEntity, String>((ref, id) =>
    ref.read(productDataSourceProvider).getProductById(id));

final relatedProductsProvider = FutureProvider.family<List<ProductEntity>, RelatedProductsParams>(
  (ref, params) => ref.read(productDataSourceProvider)
      .getRelatedProducts(params.productId, params.categoryId),
);

class RelatedProductsParams {
  final String productId;
  final String categoryId;
  const RelatedProductsParams({required this.productId, required this.categoryId});
}

// ── Product List State ─────────────────────────────────────────────
class ProductListState {
  final List<ProductEntity> products;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final String? categoryFilter;
  final String sortBy;

  const ProductListState({
    this.products = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.categoryFilter,
    this.sortBy = 'newest',
  });

  ProductListState copyWith({
    List<ProductEntity>? products,
    bool? isLoading,
    bool? hasMore,
    String? error,
    String? categoryFilter,
    String? sortBy,
  }) => ProductListState(
    products: products ?? this.products,
    isLoading: isLoading ?? this.isLoading,
    hasMore: hasMore ?? this.hasMore,
    error: error,
    categoryFilter: categoryFilter ?? this.categoryFilter,
    sortBy: sortBy ?? this.sortBy,
  );
}

class ProductListNotifier extends StateNotifier<ProductListState> {
  final ProductRemoteDataSource _dataSource;

  ProductListNotifier(this._dataSource) : super(const ProductListState()) {
    loadProducts();
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final products = await _dataSource.getProducts(
        categoryId: state.categoryFilter,
        sortBy: state.sortBy,
        limit: 20,
      );

      state = state.copyWith(
        products: refresh ? products : [...state.products, ...products],
        isLoading: false,
        hasMore: products.length == 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setCategory(String? categoryId) {
    state = state.copyWith(
      categoryFilter: categoryId,
      products: [],
      hasMore: true,
    );
    loadProducts(refresh: true);
  }

  void setSortBy(String sort) {
    state = state.copyWith(sortBy: sort, products: [], hasMore: true);
    loadProducts(refresh: true);
  }
}

final productListProvider = StateNotifierProvider<ProductListNotifier, ProductListState>((ref) =>
    ProductListNotifier(ref.read(productDataSourceProvider)));
