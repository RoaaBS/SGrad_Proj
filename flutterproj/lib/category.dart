import 'package:flutter/material.dart';

class CategoryPage extends StatelessWidget {
  static String routeName = "/home";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
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
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
            icon: Icon(Icons.shopping_cart),
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {},
        ),
        backgroundColor: Color(0xFFDFABBB),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.search),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CategoryPage()),
                    );
                  },
                  icon: Icon(Icons.grid_view),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, routeName);
                  },
                  icon: Icon(Icons.home),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/favorite');
                  },
                  icon: Icon(Icons.favorite),
                ),
              ],
            ),
            SizedBox(height: 80),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/flower');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFDFABBB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.black),
                ),
                minimumSize: Size(double.infinity, 60), // Set the minimum size
              ),
              child: Column(
                children: [
                  Text(
                    ' ورد ',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/choclate');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFDFABBB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.black),
                ),
                minimumSize: Size(double.infinity, 60), // Set the minimum size
              ),
              child: Column(
                children: [
                  Text(
                    ' شوكولاته ',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/cake');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFDFABBB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.black),
                ),
                minimumSize: Size(double.infinity, 60), // Set the minimum size
              ),
              child: Column(
                children: [
                  Text(
                    ' كيك ',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/card');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFDFABBB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.black),
                ),
                minimumSize: Size(double.infinity, 60), // تحديد الحجم الأدنى
              ),
              child: Column(
                children: [
                  Text(
                    ' بطاقات ',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 190),
          ],
        ),
      ),
    );
  }
}
