import 'package:flutter/material.dart';
import 'package:flutterproj/OrderDetails.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:flutterproj/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Adjust this import to your Constants location
import 'package:intl/intl.dart';

class myOrder extends StatefulWidget {
  static String routeName = "/joinOrder";

  @override
  _JoinOrderState createState() => _JoinOrderState();
}

class _JoinOrderState extends State<myOrder> {
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      print('Authentication token not found');
      return;
    }

    try {
      var url = '${Constants.apiUrl}/users/getUserOrder';
      var response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": token,
        },
      );

      if (response.statusCode == 200) {
        var fetchedOrders = jsonDecode(response.body) as List;
        // Sorting the orders by createdAt field in descending order
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
      length: 2, // We have two tabs
      child: Scaffold(
        backgroundColor: Color.fromRGBO(240, 235, 232, 1),
        appBar: AppBar(
          title: const Text("طلباتي",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          centerTitle: true,
          backgroundColor: Color(0xFFDFABBB),
          bottom: TabBar(
            tabs: [
              Tab(text: 'الطلبات الحالية'),
              Tab(text: 'الطلبات السابقة'),
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
    // Filter and display only current orders
    List<dynamic> currentOrders = orders
        .where((order) =>
            order['status'] == 'pending' ||
            order['status'] == 'confirmed' ||
            order['status'] == 'shipped')
        .toList();

    return _buildOrderList(currentOrders);
  }

  Widget _buildDeliveredOrCancelledOrders() {
    // Filter and display only delivered or cancelled orders
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
    DateTime now = DateTime.now();
    bool canCancel =
        order['status'] == 'pending' && now.difference(orderDate).inHours < 24;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetails(
                orderId:
                    order['orderId']), // Assuming HomeP is the details page
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
              Text('تكلفة: ${order['total']} شيقل',
                  style: TextStyle(fontSize: 18.0)),
              SizedBox(height: 8.0),
              Text('حالة الطلب: ${order['status']}',
                  style: TextStyle(fontSize: 18.0)),
              SizedBox(height: 8.0),
              Text('طريقة الدفع: ${order['PaymentType']}',
                  style: TextStyle(fontSize: 18.0)),
              Divider(color: Color(0xFFDFABBB), thickness: 2),
              if (canCancel)
                ElevatedButton(
                  onPressed: () => {cancelOrder(order['orderId'])},
                  // Ensure correct identifier field
                  child:
                      Text('إلغاء الطلب', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> cancelOrder(String orderId) async {
    final token = await AuthStorage.getToken(); // التأكد من الحصول على التوكن
    if (token == null) {
      print('Authentication token not found');
      return;
    }

    final response =
        await http.post(Uri.parse('${Constants.apiUrl}/users/cancelOrder'),
            headers: {
              "Authorization": token,
              "Content-Type": "application/json",
            },
            body: jsonEncode({"orderId": orderId}));

    if (response.statusCode == 200) {
      print('Order cancelled');
      fetchOrders(); // Refresh orders list
    } else {
      print('Failed to cancel order: ${response.body}');
      throw Exception('Failed to cancel order');
    }
  }
}
