import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterproj/MyChatPage.dart';

class chats extends StatefulWidget {
  @override
  _chatsState createState() => _chatsState();
}

class _chatsState extends State<chats> {
  TextEditingController searchController = TextEditingController();
  List<String> filteredNames = []; // قائمة بأسماء النتائج المفلترة
  List<String> chatPartnersEmails =
      []; // قائمة بالبريد الإلكتروني للنتائج المفلترة
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      filterSearchResults(searchController.text);
    });
    fetchChatPartners();
  }

  void fetchChatPartners() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    var messagesSnapshot = await _firestore
        .collection('messages')
        .where('sender', isEqualTo: currentUser.email)
        .get();

    Set<String> uniqueEmails = {};

    for (var doc in messagesSnapshot.docs) {
      uniqueEmails.add(doc.data()['receiver'] as String);
    }

    var receiversSnapshot = await _firestore
        .collection('messages')
        .where('receiver', isEqualTo: currentUser.email)
        .get();

    for (var doc in receiversSnapshot.docs) {
      uniqueEmails.add(doc.data()['sender'] as String);
    }

    // Get user/store details for these emails
    List<String> names = [];
    List<String> emails = [];

    for (var email in uniqueEmails) {
      var userDocs = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      var storeDocs = await _firestore
          .collection('stores')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userDocs.docs.isNotEmpty) {
        names.add(userDocs.docs.first.data()['username'] as String);
        emails.add(email);
      } else if (storeDocs.docs.isNotEmpty) {
        names.add(storeDocs.docs.first.data()['storeName'] as String);
        emails.add(email);
      }
    }

    setState(() {
      filteredNames = names;
      chatPartnersEmails = emails;
    });
  }

  void filterSearchResults(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredNames = [];
        chatPartnersEmails = [];
      });
      return;
    }

    var usersResults = await _firestore
        .collection('users')
        .where('username',
            isGreaterThanOrEqualTo: query, isLessThan: query + 'z')
        .get();

    var storesResults = await _firestore
        .collection('stores')
        .where('storeName',
            isGreaterThanOrEqualTo: query, isLessThan: query + 'z')
        .get();

    List<String> newFilteredNames = [];
    List<String> newChatPartnersEmails = []; // تحديث هذه القائمة

    for (var user in usersResults.docs) {
      newFilteredNames.add(user.data()['username'] as String);
      newChatPartnersEmails
          .add(user.data()['email'] as String); // افترض وجود حقل البريد
    }

    for (var store in storesResults.docs) {
      newFilteredNames.add(store.data()['storeName'] as String);
      newChatPartnersEmails.add(
          store.data()['email'] as String); // افترض وجود حقل البريد للمتاجر
    }

    setState(() {
      filteredNames = newFilteredNames;
      chatPartnersEmails = newChatPartnersEmails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFDFABBB),
        title: Text('Chats'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'ابحث...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredNames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredNames[index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyChatApp(
                          email: chatPartnersEmails[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
