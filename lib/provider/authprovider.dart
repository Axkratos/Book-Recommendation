import 'package:flutter/material.dart';
import 'dart:html' as html;

class UserProvider extends ChangeNotifier {
  String token = '';
  String email = '';

  UserProvider() {
    loadUser();
  }

  void loadUser() {
    final savedToken = html.window.localStorage['token'];
    token = savedToken ?? '';
  }

  String get getToken => token;
  set setToken(String newToken) {
    token = newToken;
    html.window.localStorage['token'] = newToken;

    notifyListeners();
  }

  void logout() {
    token = '';
    //email = '';
    html.window.localStorage.clear(); // or remove specific keys
    notifyListeners();
  }
}
