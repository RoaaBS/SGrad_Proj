import 'package:flutter/material.dart';

class JoinOrder extends StatefulWidget {
  static String routeName = "/joinOrder";

  @override
  _JoinOrderState createState() => _JoinOrderState();
}

class _JoinOrderState extends State<JoinOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 235, 232, 1),
      appBar: AppBar(
        title: const Text(
          " طلب الانضمام",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFDFABBB),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '   الادمن سوف ينظر بطلب الانضمام',
              style: TextStyle(fontSize: 25),
            ),
            SizedBox(height: 20),
            // Add your image upload widget here
          ],
        ),
      ),
    );
  }
}
