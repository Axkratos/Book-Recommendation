import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider extends ChangeNotifier {
  String token = '';
  final _secureStorage = const FlutterSecureStorage();

  UserProvider() {
    loadUser();
  }

  Future<void> loadUser() async {
    final savedToken = await _secureStorage.read(key: 'token');
    token = savedToken ?? '';
    notifyListeners();
  }

  String get getToken => token;

  set setToken(String newToken) {
    token = newToken;
    _secureStorage.write(key: 'token', value: newToken);
    notifyListeners();
  }

  void logout() {
    token = '';
    _secureStorage.delete(key: 'token');
    notifyListeners();
  }
}
