import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutterproj/constant.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:flutterproj/cproductDetails.dart'; // تأكد من استيراد صفحة تفاصيل المنتج

class offer extends StatefulWidget {
  static String routeName = "/offer";

  @override
  _offerState createState() => _offerState();
}

class _offerState extends State<offer> {
  List<dynamic> discountedProducts = [];
  List<dynamic> filteredProducts = [];
  int cartItemCount = 0;
  TextEditingController searchController = TextEditingController();
  String? selectedFilter;
  bool isSearchActive = false;

  @override
  void initState() {
    super.initState();
    fetchDiscountedProducts();
    fetchCartItemCount();
    searchController.addListener(() {
      searchProduct(searchController.text);
    });
  }

  Future<void> addToCart(String productId) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('Token not found');
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
      fetchCartItemCount(); // Update cart count after adding item
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('المنتج موجود في السلة')),
      );
    }
  }

  Future<void> fetchDiscountedProducts() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }
    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/users/allDiscount'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      setState(() {
        discountedProducts = data;
        filteredProducts = data; // Initialize filtered list with all products
      });
    } else {
      // Handle error or show message
    }
  }

  Future<void> fetchCartItemCount() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }
    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/users/cart/count'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        cartItemCount = data['count'];
      });
    }
  }

  void searchProduct(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredProducts = discountedProducts;
        isSearchActive = false;
      });
    } else {
      var fuzzy = Fuzzy(
        discountedProducts,
        options: FuzzyOptions(
          keys: [
            WeightedKey(
                name: 'productName',
                getter: (product) =>
                    (product as Map<String, dynamic>)['productName'] ?? '',
                weight: 1),
          ],
          threshold: 0.5,
        ),
      );

      final results = fuzzy.search(query);
      setState(() {
        filteredProducts = results.map((r) => r.item).toList();
        isSearchActive = true;
      });
    }
  }

  void applyFilter(String filter) {
    List<dynamic> baseProducts =
        isSearchActive ? filteredProducts : discountedProducts;
    setState(() {
      selectedFilter = filter;
      filteredProducts = List.from(baseProducts);
      switch (filter) {
        case 'الاعلى سعرا':
          filteredProducts.sort((a, b) => b['price'].compareTo(a['price']));
          break;
        case 'الاقل سعرا':
          filteredProducts.sort((a, b) => a['price'].compareTo(b['price']));
          break;
        case 'الاعلى تقييما':
          filteredProducts.sort((a, b) => b['rating'].compareTo(a['rating']));
          break;
        case 'الاقل تقييما':
          filteredProducts.sort((a, b) => a['rating'].compareTo(b['rating']));
          break;
        case 'الاحدث':
          filteredProducts
              .sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
          break;
        case 'الاقدم':
          filteredProducts
              .sort((a, b) => a['createdAt'].compareTo(b['createdAt']));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 235, 232, 1),
      appBar: AppBar(
        title: const Text("العروض",
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.home),
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/homeP')),
          buildFilterMenu(),
          Stack(children: [
            IconButton(
                icon: Icon(Icons.shopping_bag),
                onPressed: () => Navigator.pushNamed(context, '/cart')),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(6)),
                constraints: BoxConstraints(minWidth: 14, minHeight: 14),
                child: Text('$cartItemCount',
                    style: TextStyle(color: Colors.white, fontSize: 8),
                    textAlign: TextAlign.center),
              ),
            ),
          ]),
        ],
        backgroundColor: Color(0xFFDFABBB),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 5),
                height: 50,
                width: 300,
                child: TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "ابحث",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: filteredProducts.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: filteredProducts.map<Widget>((product) {
                        return buildProductCard(product);
                      }).toList(),
                    ),
            ),
          ),
        ],
      ),
    );
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

    // تعديل لعرض الوصف المختصر
    String description = product['description'];
    List<String> descriptionWords = description.split(' ');
    bool isDescriptionLong = descriptionWords.length > 10;
    String shortDescription = isDescriptionLong
        ? descriptionWords.sublist(0, 10).join(' ') + '...'
        : description;

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
        width: 190,
        height: 400,
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.favorite_border, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      // Update favorites state
                    });
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
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  child: Image.network(
                    (product['image']),
                    fit: BoxFit.cover,
                  ),
                ),
                Text(
                  product['productName'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  shortDescription,
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 4),
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
        ]),
      ),
    );
  }

  Widget buildFilterMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.filter_list),
      onSelected: (String result) {
        applyFilter(result);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'الاعلى سعرا',
          child: Text('الاعلى سعرا'),
        ),
        const PopupMenuItem<String>(
          value: 'الاقل سعرا',
          child: Text('الاقل سعرا'),
        ),
        const PopupMenuItem<String>(
          value: 'الاعلى تقييما',
          child: Text('الاعلى تقييما'),
        ),
        const PopupMenuItem<String>(
          value: 'الاقل تقييما',
          child: Text('الاقل تقييما'),
        ),
        const PopupMenuItem<String>(
          value: 'الاحدث',
          child: Text('الاحدث'),
        ),
        const PopupMenuItem<String>(
          value: 'الاقدم',
          child: Text('الاقدم'),
        ),
      ],
    );
  }
}
