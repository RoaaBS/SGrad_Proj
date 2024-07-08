import 'package:flutter/material.dart';

class LocationPage extends StatefulWidget {
  static String routeName = "/LocationPage";

  @override
  _LocationPage createState() => _LocationPage();
}

class _LocationPage extends State<LocationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 235, 232, 1),
      appBar: AppBar(
        title: const Text(
          "  موقعي",
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Image.asset(
              'assets/images/location.jpeg',
              width: 200,
              height: 150,
            ),
            SizedBox(height: 20),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/AddLocationPage");
                  },
                  child: Text(
                    'إضافة موقع جديدة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color(0xFFDFABBB),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
