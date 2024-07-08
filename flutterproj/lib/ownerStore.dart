import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterproj/AddStore.dart';
import 'package:http/http.dart' as http;
import 'auth_storage.dart'; // Handles token storage
import 'constant.dart'; // Contains apiUrl and other constants
import 'package:flutterproj/homePadmain.dart';

class OwnerStore extends StatefulWidget {
  static const String routeName = "/home";

  @override
  _OwnerStoreState createState() => _OwnerStoreState();
}

class _OwnerStoreState extends State<OwnerStore> {
  List<dynamic> stores = [];

  @override
  void initState() {
    super.initState();
    fetchStores();
  }

  Future<void> fetchStores() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication token not found')));
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/users/stores'),
        headers: {"Content-Type": "application/json", "Authorization": token},
      );

      if (response.statusCode == 200) {
        setState(() {
          stores = json.decode(response.body)['data'];
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to fetch stores')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching stores: $e')));
    }
  }

  Future<void> authenticateAndNavigate(String storeId) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No user token found, please log in again.")));
      return;
    }

    final response = await http.post(
      Uri.parse('${Constants.apiUrl}/users/authStore'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": token,
      },
      body: jsonEncode({
        'storeId': storeId,
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      await AuthStorage.setStoreToken(data['token']);

      print(data['verified']);
      print(data['image']);

      if (data['verified']) {
        Navigator.pushNamed(context, "/homePO");
      } else {
        if (data['image'] != null) {
          Navigator.pushNamed(context, "/joinOrder");
        } else {
          Navigator.pushNamed(context, homePadmin.routeName,
              arguments: data['token']);
        }
      }
    } else {
      print(
          "Failed to login. Status code: ${response.statusCode}. Response: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to login: ${response.body}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 235, 232, 1),
      appBar: AppBar(
        title: const Text("متجري",
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, "/homeP"),
            icon: const Icon(Icons.home),
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
              title: Text('اضافة متجر',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              onTap: () async {
                // Navigate to AddStore page and wait for result
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddStore()),
                );

                // Check if store was added
                if (result == true) {
                  // Refresh the store list
                  fetchStores();
                }
              },
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 1),
              itemCount: stores.length,
              itemBuilder: (BuildContext context, int index) {
                var store = stores[index];
                return InkWell(
                  onTap: () => authenticateAndNavigate(store['_id']),
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
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
