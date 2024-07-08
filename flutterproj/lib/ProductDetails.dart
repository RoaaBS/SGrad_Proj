import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutterproj/constant.dart';
import 'package:intl/intl.dart';

class ProductDetails extends StatefulWidget {
  static const String routeName = "/ProductDetails";

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  Map<String, dynamic> product = {};
  List<dynamic> reviews = [];

  @override
  void didChangeDependencies() {
    print('Product ID: ${product['id']}');
    super.didChangeDependencies();
    final productId = ModalRoute.of(context)?.settings.arguments as String?;
    if (productId != null && productId.isNotEmpty && product.isEmpty) {
      getProductById(productId);
      print('Product ID: ${product['id']}');
      fetchReviews(productId);
    }
  }

  Future<void> getProductById(String id) async {
    final token = await AuthStorage.getStoreToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    } // استرجاع التوكين من SharedPreferences

    try {
      var response = await http
          .get(Uri.parse('${Constants.apiUrl}/stores/ProductId/$id'), headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": token
      });
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          product = responseData['product'];
        });
      } else {
        print('Failed to load product: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to load product: $error');
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("تأكيد الحذف"),
          content: Text("هل أنت متأكد من أنك تريد حذف هذا المنتج؟"),
          actions: <Widget>[
            TextButton(
              child: Text("إلغاء"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("حذف"),
              onPressed: () {
                deleteProduct(product['id']);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteProduct(String id) async {
    final token = await AuthStorage.getStoreToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }
    try {
      var response = await http.delete(
        Uri.parse('${Constants.apiUrl}/stores/deleteprod/$id'),
        headers: {
          "Authorization": token,
        },
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف المنتج بنجاح')),
        );
        Navigator.pop(context); // Pop if delete is successful
      } else {
        print('Failed to delete product: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل حذف المنتج : ${response.body}")),
        );
      }
    } catch (e) {
      print('حدث خطأ أثناء حذف المنتجt: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting product: $e")),
      );
    }
  }

  Future<void> fetchReviews(String id) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/users/getProductReviews/$id'),
        headers: {"Authorization": token},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          reviews = data; // Assuming the data is a list of reviews
        });
      } else {
        print("لا يوجد تعليقات حتى الان");
      }
    } catch (error) {
      print('Failed to load reviews: $error');
    }
  }

  Widget buildProductDetails() {
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

    double originalPrice = double.tryParse(product['price'].toString()) ?? 0.0;
    double discountPercentage =
        double.tryParse(product['discount'].toString()) ?? 0.0;
    double discountedPrice = originalPrice;

    if (isDiscountValid && discountPercentage > 0) {
      discountedPrice = originalPrice * (1 - discountPercentage / 100);
    }

    bool isDiscounted = isDiscountValid && discountPercentage > 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Center(
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                product['image'] != null
                    ? Image.network(product['image'],
                        height: 250, fit: BoxFit.cover)
                    : Container(
                        height: 250,
                        color: Colors.grey[200],
                        width: MediaQuery.of(context).size.width),
                if (isDiscounted)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Text(
                        '${discountPercentage.toStringAsFixed(0)}%',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${product['productName']}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  '${originalPrice.toStringAsFixed(2)} شيكل',
                  style: TextStyle(
                    fontSize: 20,
                    color: isDiscounted ? Colors.grey : Colors.black,
                    decoration:
                        isDiscounted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (isDiscounted)
                  Text(
                    '${discountedPrice.toStringAsFixed(2)} شيكل',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                SizedBox(height: 10),
                Text(
                  'الكمية: ${product['quantity']}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'الوصف: ${product['description']}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Rating:',
                  style: TextStyle(fontSize: 18),
                ),
                RatingBarIndicator(
                  rating: product['rating']?.toDouble() ?? 0.0,
                  itemBuilder: (context, _) =>
                      Icon(Icons.star, color: Colors.amber),
                  itemCount: 5,
                  itemSize: 20.0,
                  direction: Axis.horizontal,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "التعليقات والمراجعات (${reviews.length}):",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                reviews.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          var review = reviews[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review['user'], // Display the user's name
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          16, // Larger text for better visibility
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          4), // Small space between name and rating
                                  RatingBarIndicator(
                                    rating: review['rating'].toDouble(),
                                    itemBuilder: (context, _) =>
                                        Icon(Icons.star, color: Colors.amber),
                                    itemCount: 5,
                                    itemSize:
                                        16.0, // Smaller stars to fit under the username
                                    direction: Axis.horizontal,
                                  ),
                                  SizedBox(
                                      height:
                                          8), // Space between rating and comment
                                  Text(
                                    review['comment'],
                                    style: TextStyle(
                                      fontSize:
                                          20, // Clear and readable font size for comments
                                      color: Colors
                                          .black87, // Making text darker for readability
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          8), // Space between comment and date
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(
                                        DateTime.parse(review[
                                            'createdAt'])), // Format the date
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Text(
                        "لا توجد تعليقات حتى الآن",
                        style: TextStyle(fontSize: 18),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 235, 232, 1),
      appBar: AppBar(
        title: Text("تفاصيل المنتج",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFFDFABBB),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              await Navigator.pushNamed(context, '/updateproduct',
                  arguments: product['id']);
              getProductById(
                  product['id']); // Re-fetch the product details if needed
            },
          ),
          IconButton(
            icon: const Icon(Icons.home), // Added const
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/homePO');
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: product.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: buildProductDetails(),
            ),
    );
  }
}
