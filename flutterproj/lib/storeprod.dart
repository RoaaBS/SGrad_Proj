import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterproj/cproductDetails.dart';
import 'package:http/http.dart' as http;
import 'package:flutterproj/constant.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:fuzzy/fuzzy.dart';

class storeprod extends StatefulWidget {
  static String routeName = '/storeprod';

  @override
  _storeprodState createState() => _storeprodState();
}

class _storeprodState extends State<storeprod> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  int cartItemCount = 0;
  TextEditingController searchController = TextEditingController();
  Map<String, dynamic> storeInfo = {};
  String? selectedFilter;
  bool isSearchActive = false;
  bool showDiscountedProducts = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final storeId = ModalRoute.of(context)!.settings.arguments as String;
        fetchStoreInfo(storeId); // Fetch store info based on store ID
        fetchProducts(storeId); // Load products based on store ID
      }
      fetchCartItemCount(); // Load number of items in the cart
      searchController.addListener(() {
        searchProducts(searchController.text); // Activate product search
      });
    });
  }

  Future<void> addToCart(String productId) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Authentication token not found. Please login again.')),
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
        SnackBar(content: Text('Product added to cart successfully')),
      );
      fetchCartItemCount(); // Optionally update cart count
    } else if (response.statusCode == 400) {
      var responseData = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                responseData['message'] ?? 'Error adding product to cart')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product to cart')),
      );
    }
  }

  Future<void> fetchStoreInfo(String storeId) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/users/storeInfo/$storeId'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      setState(() {
        storeInfo = responseData[
            'store']; // Assuming 'store' is the key in the response
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load store info')),
      );
    }
  }

  Future<void> fetchProducts(String storeId) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/users/storeproducts/$storeId'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      List<dynamic> productsList = responseData['products'];
      if (productsList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No products found')),
        );
      } else {
        setState(() {
          products = productsList;
          filteredProducts =
              products; // Initialize filteredProducts with all products
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to load products for store ID: $storeId')),
      );
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

  void searchProducts(String query) {
    setState(() {
      isSearchActive = query.isNotEmpty;
      if (!isSearchActive) {
        filteredProducts = showDiscountedProducts
            ? products.where((product) => isDiscountValid(product)).toList()
            : products;
        return;
      }
      var fuzzy = Fuzzy(
        products,
        options: FuzzyOptions(
          keys: [
            WeightedKey(
                name: 'productName',
                getter: (product) =>
                    (product as Map<String, dynamic>)['productName'] ?? '',
                weight: 1),
          ],
          threshold: 0.5, // Adjust threshold to control sensitivity
        ),
      );

      final results = fuzzy.search(query);
      filteredProducts = results.map((r) => r.item).toList();
      if (showDiscountedProducts) {
        filteredProducts = filteredProducts
            .where((product) => isDiscountValid(product))
            .toList();
      }
    });
  }

  bool isDiscountValid(dynamic product) {
    DateTime now = DateTime.now();
    DateTime? discountStart = product['discountStartDate'] != null
        ? DateTime.parse(product['discountStartDate'])
        : null;
    DateTime? discountEnd = product['discountEndDate'] != null
        ? DateTime.parse(product['discountEndDate'])
        : null;
    return discountStart != null &&
        discountEnd != null &&
        now.isAfter(discountStart) &&
        now.isBefore(discountEnd) &&
        product['discount'] > 0;
  }

  void applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      List<dynamic> baseList = isSearchActive ? filteredProducts : products;
      switch (filter) {
        case 'الاعلى سعرا':
          baseList.sort((a, b) => b['price'].compareTo(a['price']));
          break;
        case 'الاقل سعرا':
          baseList.sort((a, b) => a['price'].compareTo(b['price']));
          break;
        case 'الاعلى تقييما':
          baseList.sort((a, b) => b['rating'].compareTo(a['rating']));
          break;
        case 'الاقل تقييما':
          baseList.sort((a, b) => a['rating'].compareTo(b['rating']));
          break;
        case 'الاحدث':
          baseList.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
          break;
        case 'الاقدم':
          baseList.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));
          break;
        default:
          break;
      }
      filteredProducts = List.from(baseList);
      if (showDiscountedProducts) {
        filteredProducts = filteredProducts
            .where((product) => isDiscountValid(product))
            .toList();
      }
    });
  }

  void toggleDiscountFilter() {
    setState(() {
      showDiscountedProducts = !showDiscountedProducts;
      filteredProducts = showDiscountedProducts
          ? products.where((product) => isDiscountValid(product)).toList()
          : products;
      if (isSearchActive) {
        searchProducts(searchController.text);
      } else if (selectedFilter != null) {
        applyFilter(selectedFilter!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 235, 232, 1),
      appBar: AppBar(
        title: Text(
          storeInfo.isNotEmpty
              ? storeInfo['storeName']
              : "جاري تحميل...", // إظهار اسم المتجر إذا تم تحميل البيانات
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            buildStoreInfo(),
            SizedBox(height: 20),
            buildSearchBar(),
            SizedBox(height: 10),
            buildDiscountFilterButton(), // Add the discount filter button
            SizedBox(height: 20),
            if (showDiscountedProducts && filteredProducts.isEmpty)
              Text(
                'لا يوجد عروض',
                style: TextStyle(fontSize: 18, color: Colors.red),
              )
            else if (filteredProducts.isEmpty)
              Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: filteredProducts.map<Widget>((product) {
                  return buildProductCard(product);
                }).toList(),
              ),
          ],
        ),
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
        PopupMenuItem<String>(value: 'الاعلى سعرا', child: Text('الاعلى سعرا')),
        PopupMenuItem<String>(value: 'الاقل سعرا', child: Text('الاقل سعرا')),
        PopupMenuItem<String>(
            value: 'الاعلى تقييما', child: Text('الاعلى تقييما')),
        PopupMenuItem<String>(
            value: 'الاقل تقييما', child: Text('الاقل تقييما')),
        PopupMenuItem<String>(value: 'الاحدث', child: Text('الاحدث')),
        PopupMenuItem<String>(value: 'الاقدم', child: Text('الاقدم')),
      ],
    );
  }

  Widget buildSearchBar() {
    return Row(
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
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget buildDiscountFilterButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilterChip(
            label: Text('عروض'),
            selected: showDiscountedProducts,
            onSelected: (bool selected) {
              toggleDiscountFilter();
            },
            selectedColor: Colors.red[100],
            backgroundColor: Colors.white,
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
        height: 300,
        width: 190,
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
                  height: 120, // تعديل الارتفاع ليتناسب مع الارتفاع الإجمالي
                  width: double.infinity,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Image.network(
                      (product['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Text(
                  product['productName'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  product['description'],
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
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

  Widget buildStoreInfo() {
    return storeInfo.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (storeInfo['profileImage'] != null)
                  Image.network(
                    (storeInfo['profileImage']),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                else
                  SizedBox(height: 100, width: 100),
                Text(
                  storeInfo['storeName'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  storeInfo['description'],
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  storeInfo['phoneNumber'],
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "التقييم: ${storeInfo['rating']}", // عرض التقييم كنص
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.amber,
                  ),
                ),
                SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () {
                    // Implement your chat function here
                    Navigator.pushNamed(context,
                        '/chats'); // Adjust this if you have a chat route
                  },
                  child: Text('تواصل مع المتجر'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        Color.fromRGBO(69, 190, 0, 1), // text color
                    minimumSize: Size(10, 15), // button size
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                // Divider(),
              ],
            ),
          )
        : CircularProgressIndicator();
  }
}
