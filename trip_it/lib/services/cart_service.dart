import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartService extends ChangeNotifier {
  CartService._() {
    _restore();
  }
  static final CartService instance = CartService._();

  // each item: { title, description, image, price(double), quantity(int) }
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  Future<void> _restore() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final s = sp.getString('cart_items');
      if (s != null && s.isNotEmpty) {
        final raw = jsonDecode(s);
        if (raw is List) {
          _items
            ..clear()
            ..addAll(raw.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList());
          notifyListeners();
        }
      }
    } catch (_) {
      // ignore restore errors
    }
  }

  Future<void> _persist() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('cart_items', jsonEncode(_items));
    } catch (_) {
      // ignore persist errors
    }
  }

  void add(Map<String, dynamic> item) {
    // merge if same title -> increment quantity
    final idx = _items.indexWhere((i) => i['title'] == item['title']);
    if (idx >= 0) {
      _items[idx]['quantity'] = (_items[idx]['quantity'] ?? 1) + (item['quantity'] ?? 1);
    } else {
      _items.add({
        'title': item['title'],
        'description': item['description'] ?? '',
        'image': item['image'] ?? '',
        'price': (item['price'] ?? 0).toDouble(),
        'quantity': item['quantity'] ?? 1,
      });
    }
    notifyListeners();
    _persist();
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
    _persist();
  }

  void increment(int index) {
    _items[index]['quantity'] = (_items[index]['quantity'] ?? 1) + 1;
    notifyListeners();
    _persist();
  }

  void decrement(int index) {
    final q = (_items[index]['quantity'] ?? 1) as int;
    if (q > 1) {
      _items[index]['quantity'] = q - 1;
      notifyListeners();
      _persist();
    }
  }

  double get subtotal => _items.fold(0.0, (s, it) => s + (it['price'] as double) * (it['quantity'] as int));

  void clear() {
    _items.clear();
    notifyListeners();
    _persist();
  }
}
