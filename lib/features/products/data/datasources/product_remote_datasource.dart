import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? searchQuery,
    String? sortBy,
    int limit = 20,
    DocumentSnapshot? lastDoc,
  });
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getFlashSaleProducts();
  Future<List<ProductModel>> getTrendingProducts();
  Future<ProductModel> getProductById(String id);
  Future<List<CategoryModel>> getCategories();
  Future<List<ProductModel>> getRelatedProducts(
      String productId, String categoryId);
  Future<String> uploadProductImage(File image, String productId);
  Future<ProductModel> addProduct(Map<String, dynamic> data);
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data);
  Future<void> deleteProduct(String id);
  Future<void> updateStock(String id, int quantity);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProductRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  CollectionReference get _products =>
      _firestore.collection(AppConstants.productsCollection);
  CollectionReference get _categories =>
      _firestore.collection(AppConstants.categoriesCollection);

  @override
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? searchQuery,
    String? sortBy,
    int limit = 20,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      Query query = _products
          .where('status', isEqualTo: 'active')
          .where('isAvailable', isEqualTo: true);

      if (categoryId != null) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      switch (sortBy) {
        case 'price_asc':
          query = query.orderBy('price', descending: false);
          break;
        case 'price_desc':
          query = query.orderBy('price', descending: true);
          break;
        case 'rating':
          query = query.orderBy('rating', descending: true);
          break;
        case 'newest':
          query = query.orderBy('createdAt', descending: true);
          break;
        default:
          query = query.orderBy('soldCount', descending: true);
      }

      query = query.limit(limit);
      if (lastDoc != null) query = query.startAfterDocument(lastDoc);

      final snapshot = await query.get();
      return snapshot.docs.map((d) => ProductModel.fromFirestore(d)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    final snap = await _products
        .where('isFeatured', isEqualTo: true)
        .where('status', isEqualTo: 'active')
        .orderBy('soldCount', descending: true)
        .limit(10)
        .get();
    return snap.docs.map((d) => ProductModel.fromFirestore(d)).toList();
  }

  @override
  Future<List<ProductModel>> getFlashSaleProducts() async {
    final now = Timestamp.now();
    final snap = await _products
        .where('isFlashSale', isEqualTo: true)
        .where('flashSaleEnd', isGreaterThan: now)
        .where('status', isEqualTo: 'active')
        .limit(10)
        .get();
    return snap.docs.map((d) => ProductModel.fromFirestore(d)).toList();
  }

  @override
  Future<List<ProductModel>> getTrendingProducts() async {
    final snap = await _products
        .where('status', isEqualTo: 'active')
        .orderBy('soldCount', descending: true)
        .limit(10)
        .get();
    return snap.docs.map((d) => ProductModel.fromFirestore(d)).toList();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final doc = await _products.doc(id).get();
    if (!doc.exists) {
      throw const ServerException(
          message: 'Product not found', statusCode: 404);
    }
    return ProductModel.fromFirestore(doc);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final snap = await _categories
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    return snap.docs.map((d) => CategoryModel.fromFirestore(d)).toList();
  }

  @override
  Future<List<ProductModel>> getRelatedProducts(
      String productId, String categoryId) async {
    final snap = await _products
        .where('categoryId', isEqualTo: categoryId)
        .where('status', isEqualTo: 'active')
        .limit(8)
        .get();
    return snap.docs
        .where((d) => d.id != productId)
        .map((d) => ProductModel.fromFirestore(d))
        .toList();
  }

  @override
  Future<String> uploadProductImage(File image, String productId) async {
    final ref = _storage
        .ref()
        .child(AppConstants.productImagesPath)
        .child(productId)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    final task =
        await ref.putFile(image, SettableMetadata(contentType: 'image/jpeg'));
    return await task.ref.getDownloadURL();
  }

  @override
  Future<ProductModel> addProduct(Map<String, dynamic> data) async {
    final ref = await _products
        .add({...data, 'createdAt': FieldValue.serverTimestamp()});
    final doc = await ref.get();
    return ProductModel.fromFirestore(doc);
  }

  @override
  Future<ProductModel> updateProduct(
      String id, Map<String, dynamic> data) async {
    await _products
        .doc(id)
        .update({...data, 'updatedAt': FieldValue.serverTimestamp()});
    final doc = await _products.doc(id).get();
    return ProductModel.fromFirestore(doc);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _products
        .doc(id)
        .update({'status': 'inactive', 'isAvailable': false});
  }

  @override
  Future<void> updateStock(String id, int quantity) async {
    await _products.doc(id).update({
      'stockQuantity': FieldValue.increment(quantity),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
