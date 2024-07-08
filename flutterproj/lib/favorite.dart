import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterproj/constant.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:http/http.dart' as http;
import 'cProductDetails.dart'; // Make sure to import the cProductDetails page

class Favorite extends StatefulWidget {
  static String routeName = "/favorite";

  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  List<dynamic> favoriteItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/users/getFavorites'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      setState(() {
        favoriteItems = jsonDecode(response.body)['favorites'];
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch favorites: ${response.body}')),
      );
    }
  }

  Future<void> addToCart(String productId) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('${Constants.apiUrl}/users/addCart'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token,
      },
      body: jsonEncode({'productId': productId}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تمت اضافة المنتج الى السلة بنجاح')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('المنتج موجود في السلة')),
      );
    }
  }

  void deleteFavorite(String productId) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    final response = await http.delete(
      Uri.parse('${Constants.apiUrl}/users/deleteFave'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'productId': productId}),
    );

    if (response.statusCode == 200) {
      fetchFavorites();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete favorite item')),
      );
    }
  }

  Widget buildProductCard(Map<String, dynamic> product) {
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

    bool hasDiscount = product['discount'] > 0 && isDiscountValid;
    double originalPrice = (product['price'] as num).toDouble();
    double discountedPrice = hasDiscount
        ? originalPrice * (1 - product['discount'] / 100.0)
        : originalPrice;
    double rating = (product['rating'] as num).toDouble();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => cProductDetails(productId: product['_id']),
          ),
        );
      },
      child: Container(
        height: 450, // Increased height
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 5,
              offset: Offset(5, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      deleteFavorite(product['_id']);
                    },
                  ),
                ),
                if (hasDiscount)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${product['discount']}%',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100, // Increased height for the image
                    width: double.infinity,
                    child: Image.network(
                      (product['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    product['productName'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    product['description'],
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow
                        .ellipsis, // هذا يضيف النقاط إذا كان النص أطول من السطر المتاح
                    maxLines: 1, // هذا يحدد أن النص يجب أن يكون في سطر واحد فقط
                  ),
                  SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NIS ${discountedPrice.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 14, color: Colors.red),
                          ),
                          if (hasDiscount)
                            Text(
                              'NIS ${originalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 12),
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '$rating',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          IconButton(
                            icon: Icon(Icons.add_shopping_cart,
                                color: Colors.green),
                            onPressed: () => addToCart(product['_id']),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "المفضلات",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFDFABBB),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(10),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two items per row
                  childAspectRatio: 0.75, // Adjust aspect ratio as needed
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: favoriteItems.length,
                itemBuilder: (context, index) {
                  return buildProductCard(favoriteItems[index]);
                },
              ),
            ),
    );
  }
}
