import 'package:flutter/foundation.dart';

class FavoritesService extends ChangeNotifier {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  final Set<String> _fav = {};

  bool isFavorite(String id) => _fav.contains(id);

  void toggle(String id) {
    if (_fav.contains(id)) {
      _fav.remove(id);
    } else {
      _fav.add(id);
    }
    notifyListeners();
  }

  List<String> get items => _fav.toList(growable: false);
}