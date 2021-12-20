import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.description,
    required this.imageUrl,
    this.isFavorite = false,
    required this.price,
    required this.title,
  });

  void _setFavValue(bool NewValue) {
    isFavorite = NewValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.parse(
        "https://flutter-project-5d3e7-default-rtdb.europe-west1.firebasedatabase.app/$userId/.json?auth=$token");
    try {
      final respone = await http.put(
        url,
        body: json.encode(isFavorite),
      );
      if (respone.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
