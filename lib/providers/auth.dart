import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  /* String _token;
  DateTime _expiryDate;
  String _userId;*/
  Future<void> signup(String email, String pass) async {
    return _auth(email, pass, "signUp");
  }

  Future<void> login(String email, String pass) async {
    return _auth(email, pass, "signInWithPassword");
  }

  Future<void> _auth(String email, String pass, String urlSegment) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBj5hG5DVdF1jxBM7AttpC1ISJxnxfvdFI");
    try {
      final response = await http.post(url,
          body: json.encode({
            "email": email,
            "password": pass,
            "returnSecureToken": true,
          }));
    } catch (error) {
      rethrow;
    }
  }
}
