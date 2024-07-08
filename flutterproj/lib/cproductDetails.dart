import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutterproj/constant.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

class cProductDetails extends StatefulWidget {
  static const String routeName = "/CustomerProductDetails";
  final String productId;

  cProductDetails({required this.productId});

  @override
  _cProductDetailsState createState() => _cProductDetailsState();
}

class _cProductDetailsState extends State<cProductDetails> {
  Map<String, dynamic> product = {};
  bool isLoading = true;
  List<dynamic> reviews = [];
  // ignore: prefer_typing_uninitialized_variables
  var storeName;
  // ignore: prefer_typing_uninitialized_variables
  var storeImage;
  // ignore: prefer_typing_uninitialized_variables
  var isFavorite;
  @override
  void initState() {
    super.initState();
    getProductById(widget.productId);
    fetchReviews();
  }

  Future<void> fetchCart() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/users/cart/count'),
      headers: {
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      // final data = jsonDecode(response.body);
      // setState(() {
      //   cartItemCount = data['count'];
      // });
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
      fetchCart();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('المنتج موجود في السلة')),
      );
    }
  }

  Future<void> getProductById(String id) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    try {
      var response = await http
          .get(Uri.parse('${Constants.apiUrl}/users/ProductId/$id'), headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": token
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          product = responseData['product'];
          isLoading = false;
          storeName = product['storeDetails']['storeName'];
          storeImage = product['storeDetails']['storeImage'];
          isFavorite = product['isFavorite'];
          print('Store Details: ${product['storeDetails']}');
          print('Store Name: ${product['storeDetails']?['storeName']}');
          print(isFavorite);
        });
      } else {
        print('Failed to load product: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to load product: $error');
    }
  }

  Future<void> toggleFavorite() async {
    if (isFavorite) {
      setState(() {
        isFavorite = false;
      });
      print('تم حذف المنتج من المفضلة');
      return;
    }

    // Get the authentication token
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    // Send a request to add the product to favorites
    final response = await http.post(
      Uri.parse('${Constants.apiUrl}/users/addFave/${widget.productId}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    // Log the response for debugging
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    // Handle the response
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product successfully added to favorites')),
      );
      setState(() {
        isFavorite =
            true; // Ensure local state is updated to reflect favorite status
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to favorites: ${response.body}')),
      );
    }
  }

  // This function sends a POST request to the backend to add a product review.
  Future<void> addReview(
      String productId, double rating, String comment) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('${Constants.apiUrl}/users/products/$productId/reviews'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: jsonEncode({
        'rating': rating,
        'comment': comment,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review added successfully')),
      );
      fetchReviews();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add review: ${response.body}')),
      );
    }
  }

  Future<bool> checkIfProductDelivered() async {
    print("Product ID on checkIfProductDelivered: ${widget.productId}");
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return false;
    }

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/users/verifyOrder/${widget.productId}'),
        headers: {
          'Authorization': token,
        },
      );
      print(
          "Product ID after function checkIfProductDelivered: ${widget.productId}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['isDelivered'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error verifying delivery status')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to the service')),
      );
      return false;
    }
  }

  Future<void> fetchReviews() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/users/getProductReviews/${widget.productId}'),
        headers: {
          "Authorization": token,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          reviews = json.decode(response.body);
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

    // Pricing and discount calculation
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
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '${originalPrice.toStringAsFixed(2)} ₪',
                      style: TextStyle(
                        fontSize: 20,
                        color: isDiscounted ? Colors.grey : Colors.black,
                        decoration:
                            isDiscounted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    SizedBox(width: 10),
                    if (isDiscounted)
                      Text(
                        '${discountedPrice.toStringAsFixed(2)} ₪',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'الوصف: ${product['description']}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                if (product.containsKey('rating') && product['rating'] != null)
                  RatingBarIndicator(
                    rating: product['rating'].toDouble(),
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 24.0, // Size of each star
                    direction: Axis.horizontal,
                  ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red),
                      onPressed: toggleFavorite,
                    ),
                    IconButton(
                      icon: Icon(Icons.shopping_cart, color: Colors.black),
                      onPressed: () => addToCart(product['id'].toString()),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Store details box
          // Store details box
          Container(
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
            child: InkWell(
              onTap: () {
                // Check if the store ID is not null or empty before navigating
                if (product['storeDetails'] != null &&
                    product['storeDetails']['storeId'] != null &&
                    product['storeDetails']['storeId'].isNotEmpty) {
                  Navigator.pushNamed(context, '/storeprod2',
                      arguments: product['storeDetails']['storeId']);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Store information is not available')));
                }
              },
              child: Row(
                children: [
                  storeImage.isNotEmpty
                      ? Image.network(storeImage,
                          width: 100, height: 100, fit: BoxFit.cover)
                      : Container(
                          width: 100, height: 100, color: Colors.grey[300]),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      storeName,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),
          Container(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "التعليقات والمراجعات (${reviews.length}):",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_comment, color: Colors.black),
                      onPressed: () {
                        showReviewForm();
                      },
                    ),
                  ],
                ),
                buildReviews(),
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
            icon: const Icon(Icons.home), // Added const
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/homeP');
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: buildProductDetails(),
            ),
    );
  }

  void showReviewForm() async {
    bool isDelivered = await checkIfProductDelivered();
    if (!isDelivered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("You can only review products that have been delivered.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _formKey = GlobalKey<FormState>();
        double _currentRating = 0; // Default rating
        final _commentController = TextEditingController();

        return AlertDialog(
          title: Text('Write a Review'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Rating:'),
                RatingBar.builder(
                  initialRating: _currentRating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    _currentRating = rating;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Comment'),
                  controller: _commentController,
                  keyboardType: TextInputType.text,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  addReview(widget.productId, _currentRating,
                      _commentController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildReviews() {
    return ListView.builder(
      shrinkWrap: true,
      physics:
          NeverScrollableScrollPhysics(), // Prevents scrolling within the scroll view
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        var review = reviews[index];
        return Card(
          // Use Card for better visual distinction
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review['user'], // Display the user's name
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // Larger text for better visibility
                  ),
                ),
                SizedBox(height: 4), // Small space between name and rating
                RatingBarIndicator(
                  rating: review['rating'].toDouble(),
                  itemBuilder: (context, _) =>
                      Icon(Icons.star, color: Colors.amber),
                  itemCount: 5,
                  itemSize: 16.0, // Smaller stars to fit under the username
                  direction: Axis.horizontal,
                ),
                SizedBox(height: 8), // Space between rating and comment
                Text(
                  review['comment'],
                  style: TextStyle(
                    fontSize: 20, // Clear and readable font size for comments
                    color: Colors.black87, // Making text darker for readability
                  ),
                ),
                SizedBox(height: 8), // Space between comment and date
                Text(
                  DateFormat('dd/MM/yyyy').format(
                      DateTime.parse(review['createdAt'])), // Format the date
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
    );
  }
}
