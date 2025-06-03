import 'package:flutter/foundation.dart';
import '../services/local_storage_service.dart';

class FavoritesProvider with ChangeNotifier {
  final LocalStorageService _storage;
  List<String> _favorites = [];

  FavoritesProvider(this._storage) {
    _loadFavorites();
  }

  List<String> get favorites => _favorites;

  Future<void> _loadFavorites() async {
    _favorites = await _storage.getFavorites();
    notifyListeners();
  }

  Future<void> toggleFavorite(String propertyId) async {
    if (_favorites.contains(propertyId)) {
      await _storage.removeFromFavorites(propertyId);
      _favorites.remove(propertyId);
    } else {
      await _storage.addToFavorites(propertyId);
      _favorites.add(propertyId);
    }
    notifyListeners();
  }

  bool isFavorite(String propertyId) {
    return _favorites.contains(propertyId);
  }

  Future<void> clearFavorites() async {
    _favorites.clear();
    await _storage.clearAllData();
    notifyListeners();
  }
} 