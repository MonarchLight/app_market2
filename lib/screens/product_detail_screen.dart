import '../providers/products_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = "/product-detail";
  /*final String title;
  final double price;

  ProductDetailScreen(this.price, this.title);*/

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
      /*appBar: AppBar(
        title: Text(loadedProduct.title),
      ),*/
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  //fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(
              height: 10,
            ),
            description("\$${loadedProduct.price}"),
            SizedBox(
              height: 10,
            ),
            description(loadedProduct.description),
          ])),
        ],
      ),
    );
  }
}
