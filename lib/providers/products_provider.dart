import 'dart:convert';

import '../models/http_exception.dart';

import './product.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [];
  /*void showFavoritesOnly() {
    _showFavoritesOnly = true;
    notifyListeners();
  }

  void showAll() {
    _showFavoritesOnly = false;
    notifyListeners();
  }
*/
  //var _showFavoritesOnly = false;

  List<Product> get items {
    /* if (_showFavoritesOnly) {
      return _items.where((prodItem) => prodItem.isFavorite).toList();
    }*/
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  String? authToken;
  String? userId;

  set auth(token) {
    this.authToken = token;
    notifyListeners();
  }

  set userIdd(id) {
    this.userId = id;
    notifyListeners();
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.parse(
        "https://flutter-project-5d3e7-default-rtdb.europe-west1.firebasedatabase.app/products.json"); //?auth=$authToken
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        return;
      }
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: prodData['isFavorite'],
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        "https://flutter-project-5d3e7-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken");
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          "https://flutter-project-5d3e7-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken");
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
            'isFavorite': newProduct.isFavorite,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        "https://flutter-project-5d3e7-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken");
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete product! ");
    }

    existingProduct = null;

    _items.removeAt(existingProductIndex);
    notifyListeners();
  }
}
