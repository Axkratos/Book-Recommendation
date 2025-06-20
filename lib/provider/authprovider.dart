import 'package:bookrec/provider/tokenencrypter.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:provider/provider.dart';

class UserProvider extends ChangeNotifier {
  String token = '';
  String email = '';

  UserProvider() {
    loadUser();
  }

  void loadUser() {
    final encryptedToken = html.window.localStorage['token'];
    token =
        encryptedToken != null
            ? TokenEncryptor.decryptToken(encryptedToken)
            : '';
  }

  String get getToken => token;

  set setToken(String newToken) {
    token = newToken;
    final encrypted = TokenEncryptor.encryptToken(newToken);
    html.window.localStorage['token'] = encrypted;

    notifyListeners();
  }

  void logout() {
    token = '';
    html.window.localStorage.remove('token');
    notifyListeners();
  }
}
