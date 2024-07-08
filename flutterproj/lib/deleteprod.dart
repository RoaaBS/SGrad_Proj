import 'package:flutter/material.dart';

class deleteproduct extends StatefulWidget {
  static String routeName = "/homeP";

  @override
  _deleteproductState createState() => _deleteproductState();
}

class _deleteproductState extends State<deleteproduct> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "حذف منتج",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFDFABBB),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اسم المنتج:',
                style: TextStyle(fontSize: 20),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'ادخل اسم المنتج',
                ),
              ),
              SizedBox(height: 20),
              Text(
                'نوع المنتج:',
                style: TextStyle(fontSize: 20),
              ),
              DropdownButtonFormField<String>(
                items: [
                  DropdownMenuItem<String>(
                    child: Text('شوكولاته'),
                    value: 'شوكولاته',
                  ),
                  DropdownMenuItem<String>(
                    child: Text('عطور'),
                    value: 'عطور',
                  ),
                  DropdownMenuItem<String>(
                    child: Text('ورد'),
                    value: 'ورد',
                  ),
                ],
                onChanged: (String? value) {},
                decoration: InputDecoration(
                  hintText: 'اختر نوع المنتج',
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // إضافة المنتج
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDFABBB),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  child: Text(
                    'حذف المنتج',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
