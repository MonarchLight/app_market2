import 'dart:convert';

import '../providers/cart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> product;
  final DateTime dateTime;
  OrderItem({
    required this.amount,
    required this.dateTime,
    required this.id,
    required this.product,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  String? _authToken;
  String? _userId;

  void update(String token, String user) {
    _authToken = token;
    _userId = user;
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.parse(
        "https://flutter-project-5d3e7-default-rtdb.europe-west1.firebasedatabase.app/orders/$_userId.json?auth=$_authToken");
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    final List<OrderItem> loadedProducts = [];
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedProducts.add(OrderItem(
        id: orderId,
        amount: orderData["amount"],
        dateTime: DateTime.parse(orderData["dateTime"]),
        product: (orderData["product"] as List<dynamic>)
            .map((item) => CartItem(
                  id: item["id"],
                  price: item["price"],
                  quantity: item["quantity"],
                  title: item["title"],
                ))
            .toList(),
      ));
    });
    _orders = loadedProducts.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProduct, double total) async {
    final url = Uri.parse(
        "https://flutter-project-5d3e7-default-rtdb.europe-west1.firebasedatabase.app/orders/$_userId.json?auth=$_authToken");
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          "amount": total,
          "dateTime": timestamp.toIso8601String(),
          "product": cartProduct
              .map((e) => {
                    "id": e.id,
                    "title": e.title,
                    "price": e.price,
                    "quantity": e.quantity,
                  })
              .toList(),
        }));
    _orders.insert(
        0,
        OrderItem(
          amount: total,
          dateTime: timestamp,
          id: json.decode(response.body)["name"],
          product: cartProduct,
        ));
    notifyListeners();
  }
}
