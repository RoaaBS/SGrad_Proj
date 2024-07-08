import 'package:flutter/material.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:flutterproj/constant.dart';
import 'package:flutterproj/cproductDetails.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class OrderDetails extends StatefulWidget {
  static String routeName = "/orderDetails";
  final String
      orderId; // Now this must be provided when creating an OrderDetails instance.

  // Using required keyword to ensure orderId is not null
  OrderDetails({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  Map<String, dynamic> orderDetails = new Map<String, dynamic>();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    print('${widget.orderId}');

    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/users/getOrderDetails/${widget.orderId}'),
      headers: {
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        orderDetails = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      print(
          'Failed to fetch order details: Status code ${response.statusCode}');
      print('Response body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to fetch order details: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("تفاصيل الطلب"),
        centerTitle: true,
        backgroundColor: Color(0xFFDFABBB),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : buildOrderDetails(),
    );
  }

  Widget buildOrderDetails() {
    var formatter = NumberFormat('#,##0.00', 'en_US'); // For formatting numbers

    return Column(
      children: [
        Card(
          margin: EdgeInsets.all(8.0),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Store: ${orderDetails['store']['storeName']}',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Address: ${orderDetails['address']}',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text(
                    'Total: ${formatter.format(orderDetails['total'].toDouble())} NIS',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
                SizedBox(height: 8),
                Text(
                    'Order Date: ${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.parse(orderDetails['createdAt']))}',
                    style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: orderDetails['items'].length,
            itemBuilder: (context, index) {
              var item = orderDetails['items'][index];
              double price = item['price'].toDouble();
              double discount = item['discount'].toDouble();
              double finalPrice =
                  discount > 0 ? (price - (price * discount / 100)) : price;

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: Container(
                    width: 100,
                    height: 100,
                    child: Image.network(item['image'], fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons
                          .broken_image); // Fallback if image fails to load
                    }),
                  ),
                  title: Text(item['productName']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (discount > 0)
                        Text("السعر الاصلي: ${formatter.format(price)} NIS",
                            style: TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough)),
                      Text("العرض: ${formatter.format(finalPrice)} NIS",
                          style: TextStyle(color: Colors.red, fontSize: 18)),
                    ],
                  ),
                  onTap: () {
                    // Navigate to product details when product is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => cProductDetails(
                            productId: item['productId'].toString()),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
