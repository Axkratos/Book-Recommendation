import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'dart:html' as html;

class UserProvider extends ChangeNotifier {
  late final encrypt.Key key;
  late final encrypt.IV iv;
  late final encrypt.Encrypter encrypter;
  String token = '';
  String email = '';

  UserProvider() {
    key = encrypt.Key.fromUtf8(
      'L32charlongsecretkey!!202985yutw',
    ); // Ensure this is 32 characters long
    iv = encrypt.IV.fromUtf8(
      '6charlongfixedIV',
    ); // Must be exactly 16 characters
    encrypter = encrypt.Encrypter(encrypt.AES(key));
    loadUser();
  }

  void loadUser() {
    final savedToken = html.window.localStorage['token'];

    if (savedToken != null) {
      token = encrypter.decrypt(
        encrypt.Encrypted.fromBase64(savedToken),
        iv: iv,
      );
    } else {
      token = '';
    }
  }

  String get getToken => token;
  set setToken(String newToken) {
    token = newToken;
    html.window.localStorage['token'] =
        encrypter.encrypt(newToken, iv: iv).base64;
    notifyListeners();
  }

  void logout() {
    token = '';
    //email = '';
    html.window.localStorage.clear(); // or remove specific keys
    notifyListeners();
  }
}
