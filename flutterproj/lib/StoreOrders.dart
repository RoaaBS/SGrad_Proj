import 'package:flutter/material.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:flutterproj/constant.dart';
import 'package:flutterproj/storeOrderDetails.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class StoreOrders extends StatefulWidget {
  static String routeName = "/storeOrders";

  @override
  _StoreOrdersState createState() => _StoreOrdersState();
}

class _StoreOrdersState extends State<StoreOrders> {
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    fetchStoreOrders();
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    final token = await AuthStorage.getStoreToken();
    if (token == null) {
      print('Authentication token not found');
      return;
    }

    try {
      var url = '${Constants.apiUrl}/stores/updateStatus';
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token,
        },
        body: jsonEncode({
          'orderId': orderId,
          'status': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        print('Order status updated successfully');
        await fetchStoreOrders(); // Re-fetch orders to refresh the UI
      } else {
        print('Failed to update order status: ${response.body}');
        throw Exception('Failed to update order status');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  Future<void> fetchStoreOrders() async {
    final token = await AuthStorage.getStoreToken();
    if (token == null) {
      print('Authentication token not found');
      return;
    }

    try {
      var url =
          '${Constants.apiUrl}/stores/storeorders'; // Adjust the API endpoint as needed
      var response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": token,
        },
      );

      if (response.statusCode == 200) {
        var fetchedOrders = jsonDecode(response.body) as List;
        fetchedOrders.sort((a, b) => DateTime.parse(b['createdAt'])
            .compareTo(DateTime.parse(a['createdAt'])));

        setState(() {
          orders = fetchedOrders;
        });
      } else {
        print('Failed to load orders: ${response.body}');
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Assuming we have two tabs as in `myOrder`
      child: Scaffold(
        backgroundColor: Color.fromRGBO(240, 235, 232, 1),
        appBar: AppBar(
          title: const Text("طلبات المتجر",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          centerTitle: true,
          backgroundColor: Color(0xFFDFABBB),
          bottom: TabBar(
            tabs: [
              Tab(text: 'الطلبات الحالية '),
              Tab(text: 'طلبات سابقة '),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCurrentOrders(),
            _buildDeliveredOrCancelledOrders(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentOrders() {
    List<dynamic> currentOrders = orders
        .where((order) =>
            order['status'] == 'pending' ||
            order['status'] == 'confirmed' ||
            order['status'] == 'shipped')
        .toList();

    return _buildOrderList(currentOrders);
  }

  Widget _buildDeliveredOrCancelledOrders() {
    List<dynamic> completedOrders = orders
        .where((order) =>
            order['status'] == 'delivered' || order['status'] == 'cancelled')
        .toList();

    return _buildOrderList(completedOrders);
  }

  Widget _buildOrderList(List<dynamic> filteredOrders) {
    return filteredOrders.isEmpty
        ? Center(child: Text('No orders found in this category.'))
        : ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) =>
                _buildOrderItem(filteredOrders[index]),
          );
  }

  Widget _buildOrderItem(dynamic order) {
    DateTime orderDate =
        DateTime.parse(order['createdAt']).add(Duration(hours: 3));
    String formattedDate = DateFormat('dd/MM/yyyy hh:mm a').format(orderDate);
    String? newStatus = order['status'];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoreOrderDetails(
                orderId: order[
                    'orderId']), // Updated to navigate to the detailed view
          ),
        );
      },
      child: Card(
        elevation: 4.0,
        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formattedDate, style: TextStyle(fontSize: 18.0)),
              SizedBox(height: 8.0),
              Divider(color: Color(0xFFDFABBB), thickness: 2),
              Text('User: ${order['user'] ?? 'No user info'}',
                  style: TextStyle(fontSize: 18.0)),
              Text('Total: ${order['total']} NIS',
                  style: TextStyle(fontSize: 18.0)),
              Text('Order Status:', style: TextStyle(fontSize: 18.0)),
              DropdownButton<String>(
                value: newStatus,
                onChanged: (String? newValue) {
                  setState(() {
                    newStatus = newValue!;
                    _updateOrderStatus(order['orderId'], newStatus!);
                  });
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
              SizedBox(height: 8.0),
              Text('Payment Method: ${order['paymentType']}',
                  style: TextStyle(fontSize: 18.0)),
              Text('Delivery Type: ${order['deliveryType']}',
                  style: TextStyle(fontSize: 18.0)),
            ],
          ),
        ),
      ),
    );
  }
}
