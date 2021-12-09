import 'package:flutter/widgets.dart';

class HttpException implements Exception {
  final String massage;

  HttpException(this.massage);

  @override
  String toString() {
    return massage;
  }
}
