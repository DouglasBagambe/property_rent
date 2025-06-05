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

  Future<void> addFavorite(String propertyId) async {
    await _storage.addToFavorites(propertyId);
    await _loadFavorites();
  }

  Future<void> removeFavorite(String propertyId) async {
    await _storage.removeFromFavorites(propertyId);
    await _loadFavorites();
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