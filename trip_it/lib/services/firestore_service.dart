import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Example write for quick sanity checks
  Future<DocumentReference<Map<String, dynamic>>> addTestMessage() {
    return _db.collection('test').add({
      'msg': 'hello',
      'at': FieldValue.serverTimestamp(),
    });
  }

  // Fetch a user's profile document from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  // Create or update a user's profile document in Firestore (merge updates)
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> addBooking(String uid, Map<String, dynamic> booking) async {
    final payload = {
      ...booking,
      'userId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _db.collection('users').doc(uid).collection('bookings').add(payload);
    await _db.collection('bookings').add(payload);
  }

  Future<List<Map<String, dynamic>>> listBookings(String uid) async {
    final snap = await _db
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => {'id': d.id, ...d.data()})
        .where((m) => (m['userId'] == null) || (m['userId'] == uid))
        .toList();
  }

  // Real-time stream of a user's bookings (keeps UI in sync when bookings added)
  Stream<List<Map<String, dynamic>>> streamBookings(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Stream<Map<String, dynamic>?> streamUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((d) => d.data());
  }

  // Favorites APIs
  Stream<Set<String>> streamFavoriteIds(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  Future<void> setFavorite(String uid, String id, Map<String, dynamic> data) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(id)
        .set({
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> removeFavorite(String uid, String id) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(id)
        .delete();
  }

  Stream<List<Map<String, dynamic>>> streamFavorites(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {
              'id': d.id,
              ...d.data(),
            }).toList());
  }

  // Cart APIs
  Stream<List<Map<String, dynamic>>> streamCart(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('cart')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {
              'id': d.id,
              ...d.data(),
            }).toList());
  }

  Future<void> addOrIncrementCartItem(String uid, String id, Map<String, dynamic> data) async {
    final ref = _db.collection('users').doc(uid).collection('cart').doc(id);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists) {
        final q = (snap.data()?['quantity'] ?? 1) as int;
        tx.update(ref, {
          'quantity': q + ((data['quantity'] ?? 1) as int),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        tx.set(ref, {
          ...data,
          'quantity': data['quantity'] ?? 1,
          'updatedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> updateCartQuantity(String uid, String id, int delta) async {
    final ref = _db.collection('users').doc(uid).collection('cart').doc(id);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final q = (snap.data()?['quantity'] ?? 1) as int;
      final newQ = q + delta;
      if (newQ <= 0) {
        tx.delete(ref);
      } else {
        tx.update(ref, {
          'quantity': newQ,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> removeCartItem(String uid, String id) async {
    await _db.collection('users').doc(uid).collection('cart').doc(id).delete();
  }
  Stream<List<Map<String, dynamic>>> streamPackages({bool onlyActive = true, int limit = 50}) {
    Query<Map<String, dynamic>> q = _db.collection('packages');
    if (onlyActive) {
      q = q.where('isActive', isEqualTo: true);
    }
    q = q.orderBy('createdAt', descending: true).limit(limit);
    return q.snapshots().map((snap) => snap.docs.map((d) => {
          'id': d.id,
          ...d.data(),
        }).toList());
  }

  Future<Map<String, dynamic>?> getPackageById(String id) async {
    final doc = await _db.collection('packages').doc(id).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data()!};
  }
}
