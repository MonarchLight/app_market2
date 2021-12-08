import '../providers/products_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  /*final String title;
  final double price;

  ProductDetailScreen(this.price, this.title);*/

  static const routeName = "/product-detail";

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final loadedProduct = Provider.of<ProductsProvider>(context, listen: false)
        .findById(productId);
    Widget description(String name) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        child: Card(
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
            softWrap: true,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              child: Image.network(
                loadedProduct.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            description("\$${loadedProduct.price}"),
            SizedBox(
              height: 10,
            ),
            description(loadedProduct.description),
          ],
        ),
      ),
    );
  }
}
