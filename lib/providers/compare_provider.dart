import 'package:flutter/foundation.dart';
import '../services/local_storage_service.dart';

class CompareProvider with ChangeNotifier {
  final LocalStorageService _storage;
  List<String> _compareList = [];

  CompareProvider(this._storage) {
    _loadCompareList();
  }

  List<String> get compareList => _compareList;

  Future<void> _loadCompareList() async {
    _compareList = await _storage.getCompareList();
    notifyListeners();
  }

  Future<bool> addToCompare(String propertyId) async {
    if (_compareList.length >= 3) {
      return false;
    }
    if (!_compareList.contains(propertyId)) {
      await _storage.addToCompare(propertyId);
      _compareList.add(propertyId);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> removeFromCompare(String propertyId) async {
    if (_compareList.contains(propertyId)) {
      await _storage.removeFromCompare(propertyId);
      _compareList.remove(propertyId);
      notifyListeners();
    }
  }

  bool isInCompareList(String propertyId) {
    return _compareList.contains(propertyId);
  }

  Future<void> clearCompareList() async {
    await _storage.clearCompareList();
    _compareList.clear();
    notifyListeners();
  }

  bool canAddMore() {
    return _compareList.length < 3;
  }
} 