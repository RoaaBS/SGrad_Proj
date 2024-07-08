import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutterproj/constant.dart';

class CardsPage extends StatefulWidget {
  static String routeName = "/cardsPage";

  @override
  _CardsPageState createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  List<dynamic> cards = [];

  @override
  void initState() {
    super.initState();
    fetchCreditCards();
  }

  Future<void> fetchCreditCards() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/users/cards'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        cards = data['cards'];
      });
    } else {
      print('Failed to fetch credit cards: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 235, 232, 1),
      appBar: AppBar(
        title: Text("الدفع",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFFDFABBB),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.credit_card, color: Color(0xFFDFABBB)),
                    title: Text(
                        '**** **** **** ${cards[index]['lastFourDigits']}'),
                    subtitle: Text(
                        '${cards[index]['cardHolderName']} - Expires ${cards[index]['expirationDate']}'),
                    onTap: () {
                      Navigator.pop(context, cards[index]['_id']);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () async {
                var result =
                    await Navigator.pushNamed(context, '/CreditCardPage');
                if (result == 'refresh') {
                  fetchCreditCards(); // Refresh the cards list
                }
              },
              child: Text('إضافة بطاقة جديدة',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Color(0xFFDFABBB)),
            ),
          ),
        ],
      ),
    );
  }
}
