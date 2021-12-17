import 'dart:convert';

import 'package:app_market2/models/http_exception.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  late String _token;
  DateTime? _expiryDate;
  String? _userId;

  bool get isAuth {
    return token != "";
  }

  String get userId {
    return _userId!;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return "";
  }

  Future<void> signup(String email, String password) async {
    return _auth(email, password, "signUp");
  }

  Future<void> login(String email, String password) async {
    return _auth(email, password, "signInWithPassword");
  }

  Future<void> _auth(String email, String password, String urlSegment) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBj5hG5DVdF1jxBM7AttpC1ISJxnxfvdFI");
    try {
      final response = await http.post(url,
          body: json.encode({
            "email": email,
            "password": password,
            "returnSecureToken": true,
          }));
      final responseData = json.decode(response.body);
      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]["message"]);
      }
      _token = responseData["idToken"];
      _userId = responseData["localId"];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData["expiresIn"]),
        ),
      );
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
