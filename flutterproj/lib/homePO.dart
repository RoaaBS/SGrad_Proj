import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterproj/YearlySalesAnalysisPage.dart';
import 'package:flutterproj/YearlySalesPerformance.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:flutterproj/constant.dart';
import 'package:flutterproj/notificationS.dart';

import 'package:flutterproj/pie_chart_screen.dart';
import 'package:flutterproj/sales_performance_screen.dart';
import 'package:badges/badges.dart';
import 'package:badges/badges.dart' as badges;
import 'package:http/http.dart' as http;

class homePO extends StatefulWidget {
  static String routeName = "/homePO";

  @override
  _homePOState createState() => _homePOState();
}

class _homePOState extends State<homePO> {
  int unreadMessagesCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUnreadNotificationCount();
  }

  Future<void> markAllNotificationsAsRead() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      print('Authentication token not found');
      return;
    }

    var url = Uri.parse('${Constants.apiUrl}/users/markAllNotificationsAsRead');

    try {
      var response = await http.put(url, headers: {
        'Authorization': token,
      });

      if (response.statusCode == 200) {
        print('Notifications marked as read successfully');
        setState(() {
          // unreadCount = 0;
          unreadCount = 1;
        });
      } else {
        print('Failed to mark notifications as read: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking notifications as read: $e');
    }
  }

  int unreadCount = 1;
  // int unreadCount = 0;
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
          // unreadCount = data['count'];
          unreadCount = data['count'] > 0 ? data['count'] : 1;
        });
      } else {
        print('Failed to load notification count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notification count: $e');
    }
  }

  Future<List<dynamic>> fetchMostSoldProducts() async {
    final token = await AuthStorage.getStoreToken();
    if (token == null) {
      throw Exception('Token not found');
    }
    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/stores/mostsoldproducts'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': token,
      },
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['mostSoldProducts'] as List<dynamic>;
    } else {
      throw Exception('Failed to load most sold products');
    }
  }

  void navigateToPieChartScreen(BuildContext context) async {
    final token = await AuthStorage.getStoreToken();
    if (token == null) {
      throw Exception('Token not found');
    }
    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/stores/soldproducts'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': token,
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final Map<String, double> salesData = Map.fromEntries(
          jsonResponse.entries.map((e) => MapEntry(e.key, e.value.toDouble())));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PieChartScreen(dataMap: salesData),
        ),
      );
    } else {
      throw Exception('لا يوجد منتجات لعرضها');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 235, 232, 1),
      appBar: AppBar(
        title: const Text(
          "المنتجات",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFDFABBB),
        actions: [
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
                Navigator.pushNamed(context, NotificationsPageS.routeName);
              },
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              SizedBox(height: 72),
              ListTile(
                title: Text('صفحتي'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/profileO");
                },
              ),
              ListTile(
                title: Text('الصفحة الرئيسية'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/homeP");
                },
              ),
              ListTile(
                title: Text('صفحة المتجر'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/profileS");
                },
              ),
              ListTile(
                title: Text('تحليل بياني للمبيعات'),
                onTap: () {
                  Navigator.pop(context);
                  navigateToPieChartScreen(context);
                },
              ),
              ListTile(
                title: Text('تحليل الارباح'),
                onTap: () async {
                  Navigator.pop(context);
                  final token = await AuthStorage.getStoreToken();
                  if (token != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SalesPerformanceScreen()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Authentication token not found. Please log in again.')));
                  }
                },
              ),
              ListTile(
                title: Text('افضل الاشهر مبيعا'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => YearlySalesAnalysisPage()));
                },
              ),
              ListTile(
                title: Text('تحليل المبيعات السنوية'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              YearlySalesPerformanceScreen()));
                },
              ),
              ListTile(
                title: Text('  مراسلة'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => YearlySalesAnalysisPage()));
                },
              ),
              ListTile(
                title: Text('تعليقات عن المتجر'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/comment_Store");
                },
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return buildWideLayout(context);
          } else {
            return buildNarrowLayout(context);
          }
        },
      ),
    );
  }

  Widget buildWideLayout(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.add),
          title: Text(
            'إضافة منتج',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.pushNamed(context, "/addproduct");
          },
        ),
        ListTile(
          leading: Icon(Icons.add),
          title: Text(
            'إضافة عرض',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.pushNamed(context, "/addOffer");
          },
        ),
        ListTile(
          leading: Icon(Icons.ads_click_rounded),
          title: Text(
            'طلبات',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.pushNamed(context, "/storeOrders");
          },
        ),
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up),
              SizedBox(width: 5),
              Text(
                'الأكثر مبيعًا',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          onTap: () {},
        ),
        SizedBox(height: 10),
        FutureBuilder<List<dynamic>>(
          future: fetchMostSoldProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Failed to load most sold products'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No products available'));
            } else {
              return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10, // تغيير عدد الأعمدة إلى
                  childAspectRatio: 0.6, // تعديل نسبة الارتفاع إلى
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var product = snapshot.data![index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Container(
                            margin: EdgeInsets.all(10),
                            height: 80, // ارتفاع الصورة
                            child: Image.network(
                              product['image'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              Text(
                                product['productName'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color.fromARGB(255, 22, 22, 22),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                product['description'],
                                maxLines: 1, // عدد السطور الأقصى للوصف
                                overflow:
                                    TextOverflow.ellipsis, // تجنب تجاوز النص
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[200],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${product['price']} NIS',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
        SizedBox(height: 10),
        ListTile(
          title: Center(
            child: Text(
              'المنتجات',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () {},
        ),
        SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 6,
          crossAxisSpacing: 30,
          mainAxisSpacing: 10,
          children: [
            buildProductCategory(
                context, 'flowerO', 'assets/images/flower3.jpeg'),
            buildProductCategory(
                context, 'perfumeO', 'assets/images/perfume1.jpeg'),
            buildProductCategory(
                context, 'choclateO', 'assets/images/choclate5.jpeg'),
          ].map((Widget widget) {
            return Container(
              height: 20, // ارتفاع العنصر
              child: widget,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildNarrowLayout(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.add),
          title: Text(
            'إضافة منتج',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.pushNamed(context, "/addproduct");
          },
        ),
        ListTile(
          leading: Icon(Icons.add),
          title: Text(
            'إضافة عرض',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.pushNamed(context, "/addOffer");
          },
        ),
        ListTile(
          leading: Icon(Icons.ads_click_rounded),
          title: Text(
            'طلبات',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.pushNamed(context, "/storeOrders");
          },
        ),
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up),
              SizedBox(width: 5),
              Text(
                'الأكثر مبيعًا',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          onTap: () {},
        ),
        SizedBox(height: 10),
        FutureBuilder<List<dynamic>>(
          future: fetchMostSoldProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Failed to load most sold products'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No products available'));
            } else {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: snapshot.data!.map((product) {
                    return Container(
                      width: MediaQuery.of(context).size.width - 220,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: Container(
                              margin: EdgeInsets.all(10),
                              child: Image.network(
                                product['image'],
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['productName'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        const Color.fromARGB(255, 19, 18, 18),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  product['description'],
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${product['price']} NIS',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }
          },
        ),
        SizedBox(height: 30),
        ListTile(
          title: Center(
            child: Text(
              'المنتجات',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () {},
        ),
        SizedBox(height: 20),
        Row(
          children: [
            buildProductCategory(
                context, 'flowerO', 'assets/images/flower3.jpeg'),
            buildProductCategory(
                context, 'perfumeO', 'assets/images/perfume1.jpeg'),
            buildProductCategory(
                context, 'choclateO', 'assets/images/choclate5.jpeg'),
          ],
        ),
      ],
    );
  }

  Widget buildProductCategory(
      BuildContext context, String routeName, String imagePath) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/$routeName');
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 3 -
            20, // Adjust width as needed
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.all(10),
              child: Image.asset(
                imagePath,
                height: 120,
                width: 120,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              // Additional content if needed
            ),
          ],
        ),
      ),
    );
  }
}
