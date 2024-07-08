import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:flutterproj/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class StoreOrderDetails extends StatefulWidget {
  static String routeName = "/storeOrderDetails";
  final String orderId;

  StoreOrderDetails({Key? key, required this.orderId}) : super(key: key);

  @override
  _StoreOrderDetailsState createState() => _StoreOrderDetailsState();
}

class _StoreOrderDetailsState extends State<StoreOrderDetails> {
  Map<String, dynamic> orderDetails = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    final token = await AuthStorage.getStoreToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }
    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/stores/storeorders/${widget.orderId}'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      setState(() {
        orderDetails = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to fetch order details: ${response.body}')),
      );
    }
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    final token = await AuthStorage.getStoreToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/stores/updateStatus'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode({
          'orderId': widget.orderId,
          'status': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated successfully')),
        );
        fetchOrderDetails(); // Refresh the details
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update order status: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("تفاصيل طلبات المتجر"),
        backgroundColor: Color(0xFFDFABBB),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : buildOrderDetails(),
    );
  }

  Widget buildOrderDetails() {
    var formatter = NumberFormat('#,##0.00', 'en_US');

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ID: ${orderDetails['orderId']}',
                      style: TextStyle(fontSize: 18)),
                  Text('User: ${orderDetails['user']['username']}',
                      style: TextStyle(fontSize: 16)),
                  Text('Email: ${orderDetails['user']['email']}',
                      style: TextStyle(fontSize: 16)),
                  Text('Total: ${orderDetails['total']} NIS',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Status: ${orderDetails['status']}',
                      style: TextStyle(fontSize: 16)),
                  Text('Address: ${orderDetails['address']}',
                      style: TextStyle(fontSize: 16)),
                  Text('Payment Type: ${orderDetails['paymentType']}',
                      style: TextStyle(fontSize: 16)),
                  Text('Delivery Type: ${orderDetails['deliveryType']}',
                      style: TextStyle(fontSize: 16)),
                  DropdownButton<String>(
                    value: orderDetails['status'],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _updateOrderStatus(newValue);
                      }
                    },
                    items: <String>[
                      'pending',
                      'confirmed',
                      'shipped',
                      'delivered',
                      'cancelled'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                  Text('Items:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: orderDetails['items'].length,
                    itemBuilder: (BuildContext context, int index) {
                      var item = orderDetails['items'][index];

                      return ListTile(
                        leading: Image.network(
                          (item['image']),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image),
                        ),
                        title: Text(item['productName'],
                            style: TextStyle(fontSize: 16)),
                        subtitle: Text(
                            'Quantity: ${item['quantity']} - Price: ${formatter.format(item['price'])} NIS'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
