import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterproj/constant.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Cart extends StatefulWidget {
  static String routeName = "/cart";

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<dynamic> cartItems = [];
  bool isLoading = true;
  double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  Future<void> fetchCart() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/users/getCart'),
      headers: {
        'Authorization':
            token, // Correct formatting of the Authorization header
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        cartItems = jsonDecode(response.body)['items'];
        calculateTotal();
        isLoading = false;
      });
    } else {
      print('Failed to fetch cart: Status code ${response.statusCode}');
      print('Response body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch cart: ${response.body}')),
      );
    }
  }

  void calculateTotal() {
    totalPrice = 0;
    for (var item in cartItems) {
      totalPrice += (item['price'] * item['quantity']);
    }
  }

  void incrementQuantity(String productId) async {
    print("Attempting to increment quantity for product ID: $productId");

    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('${Constants.apiUrl}/users/cart/inc'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'productId': productId}),
    );

    if (response.statusCode == 200) {
      fetchCart();
    } else {
      print('Failed to increment quantity: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to increment product quantity')),
      );
    }
  }

  void decrementQuantity(String productId) async {
    print("Attempting to decrement quantity for product ID: $productId");

    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('${Constants.apiUrl}/users/cart/dec'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'productId': productId}),
    );

    if (response.statusCode == 200) {
      fetchCart();
    } else {
      print('Failed to decrement quantity: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to decrement product quantity')),
      );
    }
  }

  void deleteProduct(String productId) async {
    print("Attempting to delete product ID: $productId");

    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('${Constants.apiUrl}/users/cart/delete'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'productId': productId}),
    );

    if (response.statusCode == 200) {
      print("Delete successful: ${response.body}");
      fetchCart(); // Refresh the cart to reflect the removed item
    } else {
      print('Failed to delete product: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product from cart')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("سلة الشراء"),
        centerTitle: true,
        backgroundColor: Color(0xFFDFABBB),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      var item = cartItems[index];
                      var originalPrice = item['originalPrice'] != null
                          ? "NIS ${item['originalPrice'].toStringAsFixed(2)}"
                          : null;
                      var priceText = originalPrice != null
                          ? Text(
                              originalPrice,
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            )
                          : Container();

                      return Card(
                        margin: EdgeInsets.all(10),
                        child: ListTile(
                          leading: Container(
                            width: 100,
                            height: 100,
                            child: Image.network((item['image']),
                                fit: BoxFit.cover),
                          ),
                          title: Text(item['productName']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (priceText != null) priceText,
                              Text(
                                'NIS ${item['price'].toStringAsFixed(2)}',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 18),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle),
                                onPressed: () => decrementQuantity(
                                    item['productId'].toString()),
                              ),
                              Text(item['quantity'].toString(),
                                  style: TextStyle(fontSize: 18)),
                              IconButton(
                                icon: Icon(Icons.add_circle),
                                onPressed: () => incrementQuantity(
                                    item['productId'].toString()),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  deleteProduct(
                                      cartItems[index]['productId'].toString());
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: NIS ${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/checkout',
                            arguments: totalPrice.toString(),
                            // Pass the total price as a string argument
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color(0xFFDFABBB),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                        ),
                        child: Text("طلب المنتجات"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
