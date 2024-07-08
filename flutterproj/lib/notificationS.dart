import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_storage.dart'; // تأكد من وجود AuthStorage للتعامل مع التخزين
import 'package:flutterproj/constant.dart';
import 'dart:io';

class NotificationsPageS extends StatefulWidget {
  static String routeName = "/notificationsPageS";

  @override
  _NotificationsPageSState createState() => _NotificationsPageSState();
}

class _NotificationsPageSState extends State<NotificationsPageS> {
  List<dynamic> notifications = [];
  late String storeId;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    var url = Uri.parse(
        '${Constants.apiUrl}/users/Notification_S/66649c885e264e3cc2297173');

    try {
      var response = await http.get(url, headers: {
        'Authorization': token,
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['notifications'] != null && data['notifications'] is List) {
          setState(() {
            notifications = data['notifications'].map((notification) {
              return {
                'senderName': notification['senderName'] ?? 'No sender name',
                'content': notification['content'] ?? 'No content',
                'senderPicture': notification['senderPicture'],
              };
            }).toList();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No notifications data found')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to load notifications: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching notifications')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 235, 232, 1),
      appBar: AppBar(
        title: Text(
          "الاشعارات",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFDFABBB),
      ),
      body: RefreshIndicator(
        onRefresh: () => fetchNotifications(),
        child: notifications.isEmpty
            ? Center(child: Text("لا يوجد اشعارات"))
            : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  var notification = notifications[index];

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          notification['senderPicture'],
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      title: Text(
                        notification['senderName'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      subtitle: Text(
                        notification['content'],
                        textAlign: TextAlign.right,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      onTap: () {
                        // Handle tap
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
