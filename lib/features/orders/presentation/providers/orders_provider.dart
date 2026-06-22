import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Raw map-based order for display (avoids model complexity)
typedef OrderMap = Map<String, dynamic>;

final userOrdersProvider = StreamProvider<List<OrderMap>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('orders')
      .where('userId', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList());
});

final orderDetailProvider = StreamProvider.family<OrderMap?, String>((ref, orderId) {
  return FirebaseFirestore.instance
      .collection('orders')
      .doc(orderId)
      .snapshots()
      .map((doc) => doc.exists ? {'id': doc.id, ...doc.data()!} : null);
});

// Status helpers
String orderStatusLabel(String status) {
  return switch (status) {
    'pending' => 'Pending',
    'confirmed' => 'Confirmed',
    'processing' => 'Processing',
    'shipped' => 'Shipped',
    'delivered' => 'Delivered',
    'cancelled' => 'Cancelled',
    _ => status,
  };
}
