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

  String? _authToken;
  String? _userId;

  void update(String token, String user) {
    _authToken = token;
    _userId = user;
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? "orderBy='creatorId'&equalTo='$_userId'" : "";
    var url = Uri.parse(
        "https://flutter-project-5d3e7-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$_authToken&$filterString");
    //?auth=$_authToken - auth; &orderBy='' - filter; &equalTo='' - filter by;
    /*
    FIREBASE setup--------------------
{
  "rules": {
    ".read": "auth != null",  // 2022-1-4
    ".write": "auth != null",  // 2022-1-4
  "products" : {
    ".indexOn" : ["creatorId"]
  }
  }
}
    ----------------------------------
    */
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url = Uri.parse(
          "https://flutter-project-5d3e7-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$_userId.json?auth=$_authToken");
      final favoriteResonse = await http.get(url);
      final favoriteData = json.decode(favoriteResonse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: favoriteData == null ? false : prodData[prodId] ?? false,
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
        "https://flutter-project-5d3e7-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$_authToken");
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          "creatorId": _userId,
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
          "https://flutter-project-5d3e7-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$_authToken");
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
        "https://flutter-project-5d3e7-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$_authToken");
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

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
