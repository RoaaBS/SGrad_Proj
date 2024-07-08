import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:flutterproj/constant.dart';
import 'package:http/http.dart' as http;

class perfumeO extends StatefulWidget {
  @override
  _perfumeOState createState() => _perfumeOState();
}

class _perfumeOState extends State<perfumeO> {
  List<Map<String, dynamic>> products = [];

  Future<void> getProductsByCategory(String category) async {
    final token = await AuthStorage.getStoreToken(); // Retrieve the store token
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Store authentication token not found')));
      return;
    }

    final url = Uri.parse('${Constants.apiUrl}/stores/Product/$category');
    try {
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": token, // Include the store token in the header
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          products = List<Map<String, dynamic>>.from(responseData['products']);
        });
      } else {
        print('Failed to load products: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Failed to load products: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    getProductsByCategory('عطور');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 235, 232, 1),
      appBar: AppBar(
        title: const Text("عطور",
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/homePO'),
            icon: Icon(Icons.home),
          ),
        ],
        backgroundColor: Color(0xFFDFABBB),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('إضافة منتج',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pushNamed(context, "/addproduct"),
            ),
            SizedBox(height: 20),
            products.isEmpty
                ? Center(
                    child: Text("لا توجد منتجات لعرضها",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)))
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(
                      products.length,
                      (index) => buildProductCard(products[index],
                          MediaQuery.of(context).size.width / 2 - 15),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildProductCard(Map<String, dynamic> product, double width) {
    DateTime now = DateTime.now();
    DateTime? discountStart = product['discountStartDate'] != null
        ? DateTime.parse(product['discountStartDate'])
        : null;
    DateTime? discountEnd = product['discountEndDate'] != null
        ? DateTime.parse(product['discountEndDate'])
        : null;
    bool isDiscountValid = discountStart != null &&
        discountEnd != null &&
        now.isAfter(discountStart) &&
        now.isBefore(discountEnd);
    bool hasDiscount = product['discount'] != null &&
        product['discount'] > 0 &&
        isDiscountValid;
    double originalPrice = (product['price'] as num).toDouble();
    double discountedPrice = hasDiscount
        ? (originalPrice * (1 - (product['discount'] as num) / 100))
        : originalPrice;

    return Container(
      width: width,
      height: 400,
      child: Card(
        child: Stack(
          clipBehavior: Clip.none, // Allow overflow for the discount badge
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 150,
                  child: product['image'] != null
                      ? Image.network(product['image'], fit: BoxFit.cover)
                      : Icon(Icons.image, size: 150),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0), // Reduced padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الاسم: ${product['productName']}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 2), // Reduced height
                      if (hasDiscount)
                        Text('السعر: $originalPrice',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.red)),
                      Text(
                          'السعر: ${hasDiscount ? discountedPrice.toStringAsFixed(2) : originalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4), // Reduced height
                      Text('الكمية: ${product['quantity']}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          print(
                              'Product ID: ${product['_id']}'); // Print the product ID
                          Navigator.pushNamed(context, "/ProductDetails",
                              arguments: product['_id']);
                        },
                        child: Text(
                          'عرض المنتج',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

// Removed the SizedBox here to decrease the gap
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/addOfferID",
                              arguments: product['_id']);
                        },
                        child: Text('اضافة عرض',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasDiscount)
              Positioned(
                top: -10,
                left: 5,
                child: CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 15,
                  child: Text(
                    '${product['discount']}%',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
