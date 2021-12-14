import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';

import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart' as o;

class OrderScreen extends StatelessWidget {
  static const routeName = "/orders";

  /*@override
  void initState() {
    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Orders>(context, listen: false).fetchAndSetProducts();
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
        appBar: AppBar(title: Text("Your orders")),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetProducts(),
          builder: (ctx, snapDate) {
            if (snapDate.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return Consumer<Orders>(
                  builder: (ctx, orderData, child) => ListView.builder(
                        itemBuilder: (ctx, i) =>
                            o.OrderItem(orderData.orders[i]),
                        itemCount: orderData.orders.length,
                      ));
            }
          },
        ));
  }
}
