import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ha_ecommerce/core/constants/app_constants.dart';
import 'package:ha_ecommerce/features/products/data/models/product_model.dart';
import 'package:uuid/uuid.dart';

class FirestoreProductDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirestoreProductDataSource({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  CollectionReference get _products =>
      _firestore.collection(AppConstants.productsCollection);
  CollectionReference get _categories =>
      _firestore.collection(AppConstants.categoriesCollection);
  CollectionReference get _banners =>
      _firestore.collection(AppConstants.bannersCollection);
  CollectionReference get _reviews =>
      _firestore.collection(AppConstants.reviewsCollection);

  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? searchQuery,
    int limit = 20,
    DocumentSnapshot? lastDocument,
    bool? featuredOnly,
    bool? flashSaleOnly,
    String sortBy = 'createdAt',
    bool ascending = false,
  }) async {
    Query query = _products.where('isActive', isEqualTo: true);

    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    if (featuredOnly == true) {
      query = query.where('isFeatured', isEqualTo: true);
    }
    if (flashSaleOnly == true) {
      query = query.where('isFlashSale', isEqualTo: true);
    }

    query = query.orderBy(sortBy, descending: !ascending).limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();
  }

  Future<ProductModel> getProductById(String id) async {
    final doc = await _products.doc(id).get();
    if (!doc.exists) throw Exception('Product not found');
    return ProductModel.fromFirestore(doc);
  }

  Future<List<ProductModel>> getRelatedProducts({
    required String productId,
    required String categoryId,
    int limit = 8,
  }) async {
    final snapshot = await _products
        .where('categoryId', isEqualTo: categoryId)
        .where('isActive', isEqualTo: true)
        .limit(limit + 1)
        .get();
    return snapshot.docs
        .where((doc) => doc.id != productId)
        .take(limit)
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();
  }

  Future<List<ProductModel>> searchProducts(String query, {int limit = 20}) async {
    // Basic Firestore search — for production use Algolia/Typesense
    final queryLower = query.toLowerCase();
    final snapshot = await _products
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .startAt([queryLower])
        .endAt(['$queryLower\uf8ff'])
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
  }

  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _categories
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    return snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
  }

  Future<CategoryModel> getCategoryById(String id) async {
    final doc = await _categories.doc(id).get();
    if (!doc.exists) throw Exception('Category not found');
    return CategoryModel.fromFirestore(doc);
  }

  Future<List<BannerModel>> getBanners() async {
    final snapshot = await _banners
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    return snapshot.docs.map((doc) => BannerModel.fromFirestore(doc)).toList();
  }

  Future<List<ReviewModel>> getProductReviews(
    String productId, {
    int limit = 10,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = _reviews
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (lastDocument != null) query = query.startAfterDocument(lastDocument);
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
  }

  Future<ReviewModel> addReview(ReviewModel review) async {
    final docRef = _reviews.doc();
    await docRef.set(review.toFirestore());
    // Update product rating
    await _updateProductRating(review.productId);
    return ReviewModel.fromFirestore(await docRef.get());
  }

  Future<void> _updateProductRating(String productId) async {
    final reviews = await _reviews
        .where('productId', isEqualTo: productId)
        .get();
    if (reviews.docs.isEmpty) return;
    final total = reviews.docs.fold<double>(
      0.0,
      (sum, doc) => sum + ((doc.data() as Map)['rating'] as num).toDouble(),
    );
    final avg = total / reviews.docs.length;
    await _products.doc(productId).update({
      'rating': double.parse(avg.toStringAsFixed(1)),
      'reviewCount': reviews.docs.length,
    });
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    final docRef = _products.doc();
    await docRef.set({...product.toFirestore(), 'createdAt': FieldValue.serverTimestamp()});
    return ProductModel.fromFirestore(await docRef.get());
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    await _products.doc(product.id).update({
      ...product.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ProductModel.fromFirestore(await _products.doc(product.id).get());
  }

  Future<void> deleteProduct(String productId) async {
    await _products.doc(productId).update({'isActive': false});
  }

  Future<String> uploadProductImage({
    required String productId,
    required File imageFile,
  }) async {
    final filename = '${const Uuid().v4()}.jpg';
    final ref = _storage.ref('${AppConstants.productImagesPath}/$productId/$filename');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }
}
