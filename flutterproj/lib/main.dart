import 'package:flutter/material.dart';
import 'package:flutterproj/Add_Location.dart';
import 'package:flutterproj/CheckoutPage.dart';
import 'package:flutterproj/Credit_Card.dart';

import 'package:flutterproj/MapPage.dart';
import 'package:flutterproj/MyChatPage.dart';
import 'package:flutterproj/OrderDetails.dart';
import 'package:flutterproj/ProductDetails.dart';
import 'package:flutterproj/ProfileStore.dart';
import 'package:flutterproj/SearchResultsPage.dart';
import 'package:flutterproj/addOffer.dart';
import 'package:flutterproj/addOfferID.dart';
import 'package:flutterproj/AddStore.dart';
import 'package:flutterproj/addprod.dart';
import 'package:flutterproj/CardsPage.dart';
import 'package:flutterproj/cart.dart';
import 'package:flutterproj/chats.dart';
import 'package:flutterproj/choclateO.dart';
import 'package:flutterproj/commentS.dart';
import 'package:flutterproj/cproductDetails.dart';

import 'package:flutterproj/deleteprod.dart';
import 'package:flutterproj/emailver.dart';
import 'package:flutterproj/favorite.dart';
import 'package:flutterproj/flowerO.dart';
import 'package:flutterproj/notificationS.dart';
import 'package:flutterproj/forgetPassword.dart';
import 'package:flutterproj/homePadmain.dart';
import 'package:flutterproj/joinOrder.dart';
import 'package:flutterproj/locationPage.dart';
import 'package:flutterproj/myOrder.dart';
import 'package:flutterproj/notification.dart';
import 'package:flutterproj/offer.dart';
import 'package:flutterproj/ownerStore.dart';
import 'package:flutterproj/perfume.dart';
import 'package:flutterproj/perfumeO.dart';
import 'package:flutterproj/productAll.dart';

import 'package:flutterproj/profile.dart';
import 'package:flutterproj/profileO.dart';
import 'package:flutterproj/signin.dart';

import 'package:flutterproj/homeP.dart';

import 'package:flutterproj/flower.dart';
import 'package:flutterproj/choclate.dart';
import 'package:flutterproj/homePO.dart';
import 'package:flutterproj/category.dart';
import 'package:flutterproj/signup.dart';
import 'package:flutterproj/storeOrderDetails.dart';
import 'package:flutterproj/storeOrders.dart';
import 'package:flutterproj/storeprod.dart';
import 'package:flutterproj/storeprod2.dart';
import 'package:flutterproj/stores.dart';
import 'package:flutterproj/updateprod.dart';
import 'package:flutterproj/welcomePage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    runApp(MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: welcomePage.routeName,
      routes: {
        welcomePage.routeName: (context) => welcomePage(),
        SignIn.routeName: (context) => SignIn(),
        HomeP.routeName: (context) => HomeP(),
        homePO.routeName: (context) => homePO(),
        homePadmin.routeName: (context) => homePadmin(
            token: ModalRoute.of(context)!.settings.arguments as String),

        CombinedPage.routeName: (context) => CombinedPage(),
        storeprod.routeName: (context) => storeprod(),
        NotificationsPage.routeName: (context) => NotificationsPage(),

        NotificationsPageS.routeName: (context) => NotificationsPageS(),
        '/NotificationsPageS': (context) => NotificationsPageS(),
        '/homePO': (context) => homePO(),
        '/flower': (context) => Flower(),
        '/flowerO': (context) => FlowerO(),
        '/choclate': (context) => Choclate(),
        '/comment_Store': (context) => commentS(),
        '/choclateO': (context) => ChoclateO(),
        '/category': (context) => CategoryPage(),
        '/cart': (context) => Cart(),
        '/favorite': (context) => Favorite(),
        '/emailver': (context) => EmailVerification(),
        '/forgetPassword': (context) => ForgetPassword(),
        '/SignUp': (context) => SignUp(),
        '/SignIn': (context) => SignIn(),
        '/profile': (context) => Profile(),
        '/profileS': (context) => ProfileStore(),
        '/profileO': (context) => ProfileO(),
        '/offer': (context) => offer(),
        '/store': (context) => store(),
        '/perfume': (context) => perfume(),
        '/perfumeO': (context) => perfumeO(),
        '/addproduct': (context) => AddProduct(),
        '/updateproduct': (context) => updateproduct(),
        '/deleteproduct': (context) => deleteproduct(),
        '/addOfferID': (context) => addOfferID(),
        '/addOffer': (context) => addOffer(),
        '/joinOrder': (context) => JoinOrder(),
        '/myOrder': (context) => myOrder(),
        '/cardsPage': (context) => CardsPage(),
        '/CreditCardPage': (context) => CreditCardPage(),
        '/LocationPage': (context) => LocationPage(),
        // '/AddLocationPage': (context) => AddLocationPage(),
        // '/MapPage': (context) => MapPage(),
        '/ProductDetails': (context) => ProductDetails(),
        '/MyChatApp': (context) => MyChatApp(
              email: '',
            ),
        '/addStore': (context) => AddStore(),
        '/chats': (context) => chats(),
        '/ownerStore': (context) => OwnerStore(),
        '/productAll': (context) => productAll(),
        '/checkout': (context) => CheckoutPage(),
        '/CustomerProductDetails': (context) => cProductDetails(
              productId: '',
            ),
        '/orderDetails': (context) => OrderDetails(orderId: ''),
        '/storeOrders': (context) => StoreOrders(),
        '/storeOrderDetails': (context) => StoreOrderDetails(orderId: ''),
        '/storeprod': (context) => storeprod(),
        '/storeprod2': (context) => storeprod2(),
      },
    );
  }
}
