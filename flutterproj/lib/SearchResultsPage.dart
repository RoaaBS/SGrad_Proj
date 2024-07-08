import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:flutterproj/constant.dart';
import 'package:http/http.dart' as http;
import 'package:fuzzy/fuzzy.dart';
import 'package:flutterproj/storeprod.dart';
import 'package:flutterproj/cproductDetails.dart';

class CombinedPage extends StatefulWidget {
  static const String routeName = "/combinedPage";

  @override
  _CombinedPageState createState() => _CombinedPageState();
}

class _CombinedPageState extends State<CombinedPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> stores = [];
  List<Map<String, dynamic>> filteredStores = [];
  bool isLoadingProducts = true;
  bool isLoadingStores = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchProducts();
    fetchStores();
    searchController.addListener(() {
      search(searchController.text);
    });
  }

  Future<void> fetchProducts() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token not found for products')));
      return;
    }
    try {
      var response = await http.get(
        Uri.parse('${Constants.apiUrl}/users/products'),
        headers: {'Authorization': token},
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body)['products'];
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonResponse) {
          tempList.add(item as Map<String, dynamic>);
        }
        setState(() {
          products = tempList;
          filteredProducts = products;
          isLoadingProducts = false;
        });
      } else {
        throw Exception('فشل تحميل المنتجات');
      }
    } catch (e) {
      setState(() {
        isLoadingProducts = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل المنتجات: ${e.toString()}')));
    }
  }

  Future<void> fetchStores() async {
    final token = await AuthStorage.getStoreToken();
    if (token == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Token not found for stores')));
      return;
    }
    try {
      var response = await http.get(
        Uri.parse('${Constants.apiUrl}/users/allStore'),
        headers: {'Authorization': token},
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body)['stores'];
        setState(() {
          stores = jsonResponse.cast<Map<String, dynamic>>();
          filteredStores = stores;
          isLoadingStores = false;
        });
      } else {
        throw Exception('Failed to load stores');
      }
    } catch (e) {
      setState(() {
        isLoadingStores = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stores: ${e.toString()}')));
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredProducts = products;
        filteredStores = stores;
      });
      return;
    }

    // Search in products
    var fuzzyProducts = Fuzzy<Map<String, dynamic>>(
      products,
      options: FuzzyOptions(
        keys: [
          WeightedKey(
              name: 'productName',
              getter: (product) => product['productName'] ?? '',
              weight: 1),
        ],
        threshold: 0.5,
      ),
    );

    // Search in stores
    var fuzzyStores = Fuzzy<Map<String, dynamic>>(
      stores,
      options: FuzzyOptions(
        keys: [
          WeightedKey(
              name: 'storeName',
              getter: (store) => store['storeName'] ?? '',
              weight: 1),
        ],
        threshold: 0.5,
      ),
    );

    setState(() {
      filteredProducts =
          fuzzyProducts.search(query).map((r) => r.item).toList();
      filteredStores = fuzzyStores.search(query).map((r) => r.item).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "المنتجات والمحلات",
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFDFABBB),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "المحلات"),
            Tab(text: "المنتجات"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildStoresTab(context),
          buildProductsTab(context),
        ],
      ),
    );
  }

  Widget buildProductsTab(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        buildSearchBar(),
        SizedBox(height: 20),
        if (isLoadingProducts)
          CircularProgressIndicator()
        else
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (BuildContext context, int index) {
                var product = filteredProducts[index];
                return buildProductCard(product);
              },
            ),
          ),
      ],
    );
  }

  Widget buildProductCard(Map<String, dynamic> product) {
    final imageUrl = product['image'];
    final isUrl = Uri.tryParse(imageUrl)?.hasAbsolutePath ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => cProductDetails(productId: product['_id']),
          ),
        );
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            imageUrl != null && imageUrl.isNotEmpty
                ? isUrl
                    ? Image.network(imageUrl, height: 100, fit: BoxFit.cover)
                    : Image.file(File(imageUrl), height: 100, fit: BoxFit.cover)
                : Icon(Icons.image, size: 100),
            Text(product['productName'],
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              product['description'],
              style: TextStyle(fontSize: 12),
              overflow: TextOverflow
                  .ellipsis, // هذا يضيف النقاط إذا كان النص أطول من السطر المتاح
              maxLines: 1, // هذا يحدد أن النص يجب أن يكون في سطر واحد فقط
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
            arguments: store['storeId']);
      },
      child: Container(
        width: 180, // عرض البطاقة
        height: 320, // ارتفاع البطاقة
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 5,
              offset: Offset(5, 5), // ظل البطاقة
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.6, // نسبة العرض إلى الارتفاع
              child: Container(
                margin: EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(
                    store['profileImage'],
                    fit: BoxFit.cover, // ملائمة الصورة
                    height: 200, // ارتفاع الصورة
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
                        fontSize: 13, // حجم الخط للعنوان
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      store['description'],
                      style: TextStyle(
                        fontSize: 14, // حجم الخط للوصف
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget buildStoresTab(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        buildSearchBar(),
        SizedBox(height: 20),
        if (isLoadingStores)
          CircularProgressIndicator()
        else
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              itemCount: filteredStores.length,
              itemBuilder: (BuildContext context, int index) {
                var store = filteredStores[index];
                return buildStoreCard(store);
              },
            ),
          ),
      ],
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          labelText: 'ابحث',
          suffixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(),
          ),
        ),
      ),
    );
  }
}
