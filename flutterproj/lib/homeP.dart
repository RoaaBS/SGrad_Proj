import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:flutterproj/cproductDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterproj/notification.dart';
import 'package:flutterproj/utils/geoLocatorUtils.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:flutterproj/constant.dart';
import 'package:flutterproj/SearchResultsPage.dart';
import 'package:flutterproj/storeprod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:badges/badges.dart' as badges;

class HomeP extends StatefulWidget {
  static String routeName = "/homeP";

  @override
  _HomePState createState() => _HomePState();
}

class _HomePState extends State<HomeP> {
  String userEmail = '';
  bool _isSearching = false;
  Map<String, bool> favoriteStates = {};
  int cartItemCount = 0;
  int unreadMessagesCount = 0; // متغير لتخزين عدد الرسائل غير المقروءة
  int unreadCount = 0;
  void initState() {
    super.initState();
    fetchCart();
    fetchDiscountedProducts();
    // setupUnreadMessagesListener();
    fetchUnreadNotificationCount();
  }

  Future<void> markAllNotificationsAsRead() async {
    final token = await AuthStorage.getToken(); // التأكد من الحصول على التوكن
    if (token == null) {
      print('Authentication token not found');
      return;
    }

    var url = Uri.parse(
        '${Constants.apiUrl}/users/markAllNotificationsAsRead'); // URL لنقطة النهاية

    try {
      var response = await http.put(url, headers: {
        'Authorization': token,
      });

      if (response.statusCode == 200) {
        print('Notifications marked as read successfully');
        setState(() {
          unreadCount = 0; // إعادة تعيين العداد إلى 0
        });
      } else {
        print('Failed to mark notifications as read: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking notifications as read: $e');
    }
  }

  void fetchUnreadNotificationCount() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      print('Authentication token not found');
      return;
    }
    var url = Uri.parse('${Constants.apiUrl}/users/getNotificationCount');

    try {
      var response = await http.get(url, headers: {
        'Authorization': token,
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          unreadCount = data['count'];
        });
      } else {
        print('Failed to load notification count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notification count: $e');
    }
  }

  void setupUnreadMessagesListener() {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      FirebaseFirestore.instance
          .collection('messages')
          .where('receiver', isEqualTo: user.email)
          .where('read', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
        if (mounted) {
          setState(() {
            unreadMessagesCount = snapshot.docs.length;
          });
        }
      });
    }
  }

  Future<List<dynamic>> fetchProducts() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/users/productList'),
      headers: {
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<dynamic> products = List<dynamic>.from(data['products']);
      for (var product in products) {
        product['isFavorite'] ??= false; // Initialize isFavorite if null
      }
      return products;
    } else {
      throw Exception(
          'Failed to load products, status code: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchDiscountedProducts() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/users/discountGet'),
      headers: {
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<dynamic> products = List<dynamic>.from(data['data']);
      for (var product in products) {
        product['isFavorite'] ??= false; // Initialize isFavorite if null
      }
      return products;
    } else {
      throw Exception(
          'Failed to load discounted products, status code: ${response.statusCode}');
    }
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
      final data = jsonDecode(response.body);
      setState(() {
        cartItemCount = data['count'];
      });
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

  Future<String?> fetchUserType() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/users/Type'),
      headers: {
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['userType'] as String?;
    } else {
      throw Exception(
          'Failed to load user type, status code: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchStores() async {
    final token = await AuthStorage.getToken();

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/stores/storerating'),
      headers: {
        'Authorization': token,
      },
    );
    // print(token);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return List<dynamic>.from(data['stores']);
    } else {
      throw Exception(
          'Failed to load stores, status code: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchBestSellingStores() async {
    // Ensure the token is loaded before making the call
    final token = await AuthStorage.getToken();
    if (token == null) {
      print('Token not found');
      return [];
    }

    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/users/BestSelling'),
      headers: {
        'Authorization': token,
      },
    );

    // print('Response Status Code: ${response.statusCode}');
    // print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return List<dynamic>.from(data.map((store) => store));
      } else {
        print('No stores found.');
        return [];
      }
    } else {
      print(
          'Failed to load best selling stores, status code: ${response.statusCode}');
      return [];
    }
  }

  Future<List<dynamic>> fetchStoresWithDiscountedProducts() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse(
          '${Constants.apiUrl}/users/discountedStores'), // Adjusted to the new endpoint
      headers: {
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<dynamic> storesWithDiscounts = List<dynamic>.from(data['data']);
      return storesWithDiscounts;
    } else {
      throw Exception(
          'Failed to fetch stores with discounted products, status code: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchRecommended() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse(
          '${Constants.apiUrl}/users/recommendStores'), // Adjusted to the new endpoint
      headers: {
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<dynamic> storesWithDiscounts = List<dynamic>.from(data['data']);
      return storesWithDiscounts;
    } else {
      throw Exception(
          'Failed to fetch stores with discounted products, status code: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchStoresNearMe() async {
    print("HELLO");
    String? cityName = await getCityNameFromCurrentPosition();
    if (cityName != null) {
      final token = await AuthStorage.getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final Map<String, String> queryParams = {
        'city': cityName,
      };

      Uri uri = Uri.parse('${Constants.apiUrl}/stores/getStoreNearMe')
          .replace(queryParameters: queryParams);
      print("URI: ${uri}");
      final response = await http.get(
        uri,
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // print("fetchStoresNearMe-data: ${data}");
        return List<dynamic>.from(data['stores']);
      } else {
        return [];
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 235, 232, 1),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث...',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
              )
            : Text(
                "هديتي",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, CombinedPage.routeName);
            },
          ),
          badges.Badge(
            badgeContent: Text(
              '$unreadCount',
              style: TextStyle(color: Colors.white),
            ),
            position: BadgePosition.topEnd(top: 3, end: 3),
            child: IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                markAllNotificationsAsRead();
                Navigator.pushNamed(
                    context,
                    NotificationsPage
                        .routeName); // تنقل المستخدم إلى صفحة الإشعارات
              },
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_bag),
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 40),
                      ListTile(
                        leading: Icon(Icons.shopping_cart),
                        title: Text('طلباتي'),
                        onTap: () {
                          Navigator.pop(context); // Close the drawer
                          Navigator.pushNamed(context, '/myOrder');
                        },
                      ),
                    ],
                  ),
                );
              },
              isScrollControlled: true,
            );
          },
        ),
        backgroundColor: Color(0xFFDFABBB),
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 60),
        children: <Widget>[
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              aspectRatio: 16 / 9,
              enlargeCenterPage: true,
              viewportFraction: 1,
            ),
            items: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Image.asset('assets/images/FL.jpeg', fit: BoxFit.cover),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Image.asset('assets/images/perfume.jpeg',
                    fit: BoxFit.cover),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Image.asset('assets/images/choclate5.jpeg',
                    fit: BoxFit.cover),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            ' المحلات لديها عروض',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          FutureBuilder<List<dynamic>>(
            future: fetchStoresWithDiscountedProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else {
                var stores = snapshot.data!;
                return Container(
                  height: 330,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: stores.length + 1,
                    itemBuilder: (context, index) {
                      if (index < stores.length) {
                        return buildStoreCard(stores[index]);
                      } else {
                        return Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/store');
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              elevation: 0,
                            ),
                            child: Text(
                              'أعرض أكثر',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              }
            },
          ),
          SizedBox(height: 20),
          Text(
            'المحلات الاكثر مبيعا',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          FutureBuilder<List<dynamic>>(
            future: fetchBestSellingStores(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No best-selling stores found."));
              } else {
                var stores = snapshot.data!;
                return Container(
                  height: 330,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: stores.length,
                    itemBuilder: (context, index) {
                      return buildStoreCard(stores[index]);
                    },
                  ),
                );
              }
            },
          ),
          FutureBuilder<List<dynamic>>(
            future: fetchRecommended(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Container(); // Handle error state by returning an empty container
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(); // Return an empty container if the list is empty
              } else {
                var stores = snapshot.data!;
                return Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'المحلات المقترحة لك',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 330,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: stores.length + 1,
                        itemBuilder: (context, index) {
                          if (index < stores.length) {
                            return buildStoreCard(stores[index]);
                          } else {
                            return Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/store');
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'أعرض أكثر',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          SizedBox(height: 20),
          Text(
            'المحلات قريب من موقعك',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          FutureBuilder<List<dynamic>>(
            future: fetchStoresNearMe(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Text("لا يوجد محلات من القرب من موقعك الحالي"));
              } else {
                var stores = snapshot.data!;
                return Container(
                  height: 330,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: stores.length,
                    itemBuilder: (context, index) {
                      return buildStoreCard(stores[index]);
                    },
                  ),
                );
              }
            },
          ),
          SizedBox(height: 20),
          Text(
            'المحلات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          FutureBuilder<List<dynamic>>(
            future: fetchStores(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else {
                var stores = snapshot.data!;
                return Container(
                  height: 330,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: stores.length + 1,
                    itemBuilder: (context, index) {
                      if (index < stores.length) {
                        return buildStoreCard(stores[index]);
                      } else {
                        return Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/store');
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              elevation: 0,
                            ),
                            child: Text(
                              'أعرض أكثر',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              }
            },
          ),
          SizedBox(height: 20),
          Text(
            'العروض',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          FutureBuilder<List<dynamic>>(
            future: fetchDiscountedProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else {
                var discountedProducts = snapshot.data!;
                return Container(
                  height: 300,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: discountedProducts.length + 1,
                    itemBuilder: (context, index) {
                      if (index < discountedProducts.length) {
                        return buildDiscountedProductCard(
                            discountedProducts[index]);
                      } else {
                        return Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/offer');
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              elevation: 0,
                            ),
                            child: Text(
                              'أعرض أكثر',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              }
            },
          ),
          SizedBox(height: 20),
          Text(
            'المنتجات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          FutureBuilder<List<dynamic>>(
            future: fetchProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else {
                var products = snapshot.data!;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: products.map<Widget>((product) {
                    return buildProductCard(product);
                  }).toList(),
                );
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/productAll');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  elevation: 0,
                ),
                child: Text(
                  'أعرض أكثر',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () async {
                String? userType = await fetchUserType();
                if (userType == "مستخدم") {
                  Navigator.pushNamed(context, '/profile');
                } else if (userType == "صاحب متجر") {
                  Navigator.pushNamed(context, '/profileO');
                }
              },
              icon: Icon(Icons.account_circle),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/homeP');
              },
              icon: Icon(Icons.home),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/favorite');
              },
              icon: Icon(Icons.favorite),
            ),
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.message),
                  onPressed: () => Navigator.pushNamed(context, '/chats'),
                ),
                if (unreadMessagesCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '$unreadMessagesCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            )
          ],
        ),
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
                  product['description'],
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow
                      .ellipsis, // هذا يضيف النقاط إذا كان النص أطول من السطر المتاح
                  maxLines: 1, // هذا يحدد أن النص يجب أن يكون في سطر واحد فقط
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

  Widget buildDiscountedProductCard(Map<String, dynamic> product) {
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
        ? originalPrice * (1 - product['discount'] / 100)
        : originalPrice;
    bool isFavorite = product['isFavorite'] ?? false;

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
        height: 300, // تحديد الارتفاع إلى 300
        width: 150,
        margin: EdgeInsets.symmetric(horizontal: 3, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  child: Image.network(
                    (product['image']),
                    fit: BoxFit.cover,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red),
                    onPressed: () {
                      setState(() {
                        product['isFavorite'] = !isFavorite;
                      });
                    },
                  ),
                ),
                if (hasDiscount)
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${product['discount']}%',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add_shopping_cart,
                          color: Colors.red[300],
                        ),
                        onPressed: () => addToCart(product['_id']),
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

  Widget buildStoreCard(Map<String, dynamic> store) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, storeprod.routeName,
            arguments: store['_id']);
      },
      child: Container(
        width: 180, // Matching the product card width
        height: 300, // Matching the product card height
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 5,
              offset: Offset(
                  5, 5), // Keeping shadow consistent with the product card
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1, // Adjusting aspect ratio for a square image area
              child: Container(
                margin: EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    store['profileImage'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      store['storeName'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      store['description'],
                      style: TextStyle(
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: Text(
                        'التقييم: ${store['rating'].toString()}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
