import 'package:flutter/material.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:flutterproj/constant.dart';
import 'package:fuzzy/fuzzy.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutterproj/storeprod.dart';

class store extends StatefulWidget {
  static String routeName = "/store";

  @override
  _storeState createState() => _storeState();
}

class _storeState extends State<store> {
  List<Map<String, dynamic>> stores = [];
  List<Map<String, dynamic>> filteredStores = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStores();
    searchController.addListener(() {
      searchStore(searchController.text);
    });
  }

  Future<void> fetchStores() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('التوكن غير موجود')));
      return;
    }
    try {
      var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/users/allStore'), // Adjust to your actual URL
        headers: {
          'Authorization': token, // Use token for authorization
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          stores = List<Map<String, dynamic>>.from(data['stores']);
          filteredStores = stores; // Initialize filteredStores with all stores
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load stores');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading stores')));
    }
  }

  void searchStore(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredStores = stores;
      });
      return;
    }

    var fuzzy = Fuzzy(
      stores,
      options: FuzzyOptions(
        keys: [
          WeightedKey(
              name: 'storeName',
              // Cast each product to a Map explicitly before accessing it as a Map
              getter: (product) =>
                  (product as Map<String, dynamic>)['storeName'] ?? '',
              weight: 1),
        ],
        threshold: 0.5, // Adjust threshold to control sensitivity
      ),
    );

    final results = fuzzy.search(query);
    setState(() {
      filteredStores =
          results.map((r) => r.item as Map<String, dynamic>).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // بقية التعليمات البرمجية للواجهة تبقى كما هي، بتحديث الجزء الذي يعرض البيانات
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 235, 232, 1),
      appBar: AppBar(
        title: Text(
          "المحلات",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFDFABBB),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : buildStoreList(context),
    );
  }

  Widget buildStoreList(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          buildSearchBar(),
          SizedBox(height: 20),
          buildGridView(),
        ],
      ),
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
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
      ),
      itemCount: filteredStores.length,
      itemBuilder: (BuildContext context, int index) {
        var store = filteredStores[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              storeprod.routeName,
              arguments: store['storeId'], // تأكد من أن هذه هي قيمة ID الصحيحة
            );
          },
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                store['profileImage'] != null &&
                        store['profileImage'].isNotEmpty
                    ? Image.network((store['profileImage']),
                        height: 100, fit: BoxFit.cover)
                    : Icon(Icons.store, size: 100),
                Text(store['storeName'],
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(store['description']),
                Text(store['city']),
              ],
            ),
          ),
        );
      },
    );
  }
}
