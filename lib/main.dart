import './screens/products_overview_screen.dart';
import './screens/auth_screen.dart';
import './screens/order_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/user_products_screen.dart';
import './screens/cart_screen.dart';
import './screens/product_detail_screen.dart';

import './providers/auth.dart';
import './providers/orders.dart';
import './providers/products_provider.dart';
import './providers/cart.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),

          ChangeNotifierProvider(
            create: (ctx) => Cart(),
          ),

          //-----------------------------------------------------
          ChangeNotifierProxyProvider<Auth, ProductsProvider>(
            create: (ctx) => ProductsProvider(),
            update: (ctx, auth, prevProducts) =>
                prevProducts!..update(auth.token, auth.userId),
          ),

          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (ctx) => Orders(),
            update: (ctx, auth, prevProducts) =>
                prevProducts!..update(auth.token, auth.userId),
          ),
          //--------------------------------------------------------

          //------------------------------------------------------
          // provider: ^6.0.1
          //------------------------------------------------------
/*
         
          ChangeNotifierProxyProvider<Auth, ProductsProvider>(
              create: (ctx) => ProductsProvider(),
              update: (ctx, auth, previousProductsProvider) {
                previousProductsProvider!.auth = auth.token;
                // previousProductsProvider.userIdd = auth.userId;
                //previousProductsProvider.items;
                return previousProductsProvider;
              }),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (ctx) => Orders(),
            update: (ctx, auth, previousProductsProvider) {
              previousProductsProvider!.auth = auth.token;
              // previousProductsProvider.userIdd = auth.userId;
              //previousProductsProvider.orders;
              return previousProductsProvider;
            },
          ),
*/
          //------------------------------------------------------
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.blueGrey,
              ),
              canvasColor: Colors.blue[50],
              fontFamily: "Anton",
            ),
            home: auth.isAuth ? ProductsOverviewScreen() : AuthScreen(),
            routes: {
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrderScreen.routeName: (ctx) => OrderScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
            },
          ),
        ));
  }
}
