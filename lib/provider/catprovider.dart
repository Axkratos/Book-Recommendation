import 'package:flutter/material.dart';
import 'dart:html' as html; // Only available for Flutter Web

class CatProvider extends ChangeNotifier {
  String _catName = 'Whiskers';

  String get catName => _catName;
  CatProvider() {
    loadCatName();
  }

  void loadCatName() {
    final savedName = html.window.localStorage['catName'];
    _catName = savedName!;
    //notifyListeners();
  }

  set catName(String newName) {
    _catName = newName;
    html.window.localStorage['catName'] = _catName;
    notifyListeners();
  }
}