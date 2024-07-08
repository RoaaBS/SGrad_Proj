import 'package:flutter/material.dart';

class perfume extends StatelessWidget {
  static String routeName = "/home";

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = 80.0;
    final spacing = 10.0;

    final imagesCount = 8;
    final visibleImagesCount = (screenWidth / (itemWidth + spacing)).floor();

    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 235, 232, 1),
      appBar: AppBar(
        title: const Text(
          "عطور",
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
              Navigator.pushReplacementNamed(context, '/homeP');
            },
            icon: Icon(Icons.home),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
            icon: Icon(Icons.shopping_bag),
          ),
        ],
        backgroundColor: Color(0xFFDFABBB),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 5),
                  height: 50,
                  width: 300,
                  child: TextFormField(
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
                      color: Color.fromRGBO(240, 235, 232, 1),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              children: List.generate(
                7,
                (index) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2 - 20,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Container(
                              //   padding: EdgeInsets.all(5),
                              //   decoration: BoxDecoration(
                              //     color: Color(0xFFDFABBB),
                              //     borderRadius: BorderRadius.circular(20),
                              //   ),
                              //   child: Text(
                              //     "",
                              //     style: TextStyle(
                              //       fontSize: 14,
                              //       color: Colors.white,
                              //       fontWeight: FontWeight.bold,
                              //     ),
                              //   ),
                              // ),
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.favorite_border,
                                  color: Colors.red[300],
                                ),
                                label: Text(''),
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              margin: EdgeInsets.all(10),
                              child: Image.asset(
                                "assets/images/perfume${index + 1}.jpeg", // تعديل هنا
                                height: 120,
                                width: 120,
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
                                  "اسم المنتج",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red[100],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "وصف المنتج",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red[200],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "السعر :",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {},
                                      child: Icon(
                                        Icons.shopping_cart_checkout,
                                        color: Colors.red[300],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2 - 20,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.favorite_border,
                                  color: Colors.red[300],
                                ),
                                label: Text(''),
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              margin: EdgeInsets.all(10),
                              child: Image.asset(
                                "assets/images/perfume${index + 8}.jpeg",
                                height: 120,
                                width: 120,
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
                                  "اسم المنتج",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red[100],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "وصف المنتج",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red[200],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "السعر:",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {},
                                      child: Icon(
                                        Icons.shopping_cart_checkout,
                                        color: Colors.red[300],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
}
