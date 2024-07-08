import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutterproj/constant.dart';

class addOffer extends StatefulWidget {
  static String routeName = "/addOffer";

  @override
  _AddOfferState createState() => _AddOfferState();
}

class _AddOfferState extends State<addOffer> {
  String discount = "";
  DateTime? discountStartDate;
  DateTime? discountEndDate;
  String? category;

  Future<DateTime?> _showDatePickerDialog(BuildContext context) async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
  }

  Future<void> _addOffer(BuildContext context) async {
    if (discount.trim().isEmpty ||
        category == null ||
        discountStartDate == null ||
        discountEndDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('يرجى ملء جميع الحقول')));
      return;
    }

    if (double.tryParse(discount) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الرجاء إدخال قيمة صحيحة لنسبة الخصم')));
      return;
    }

    final token = await AuthStorage.getStoreToken();
    if (token == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('التوكن غير موجود')));
      return;
    }

    try {
      var response = await http.post(
        Uri.parse('${Constants.apiUrl}/stores/addOfferCat'),
        headers: {"Content-Type": "application/json", "Authorization": token},
        body: json.encode({
          'discount': double.parse(discount),
          'discountStartDate':
              discountStartDate!.toIso8601String(), // تعديل التنسيق
          'discountEndDate':
              discountEndDate!.toIso8601String(), // تعديل التنسيق
          'category': category,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('تم إضافة العرض بنجاح')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل في إضافة العرض: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }

  Future<void> _showDiscountDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('نسبة الخصم'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                discount = value;
              });
            },
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'ادخل نسبة الخصم',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "إضافة عرض",
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
              SizedBox(height: 10),
              Text(
                "نوع المنتج",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButtonFormField<String>(
                value: category,
                items: ['شوكولاته', 'عطور', 'ورد'].map((String category) {
                  return DropdownMenuItem(
                      value: category,
                      child: Text(category, textDirection: TextDirection.rtl));
                }).toList(),
                onChanged: (value) => setState(() => category = value),
                decoration: InputDecoration(hintText: 'اختر نوع المنتج'),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'نسبة الخصم:',
                    style: TextStyle(fontSize: 20),
                  ),
                  TextButton(
                    onPressed: () => _showDiscountDialog(context),
                    child: Text(
                      'تحديد',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              Text(
                discount.isEmpty
                    ? 'لا يوجد خصم محدد'
                    : 'نسبة الخصم: $discount%',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تاريخ بداية الخصم:',
                    style: TextStyle(fontSize: 20),
                  ),
                  TextButton(
                    onPressed: () async {
                      final startDate = await _showDatePickerDialog(context);
                      if (startDate != null) {
                        setState(() {
                          discountStartDate = startDate;
                        });
                      }
                    },
                    child: Text(
                      'تحديد',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              Text(
                discountStartDate == null
                    ? 'تاريخ بداية الخصم: غير محدد'
                    : 'تاريخ بداية الخصم: ${discountStartDate.toString().split(" ")[0]}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تاريخ نهاية الخصم:',
                    style: TextStyle(fontSize: 20),
                  ),
                  TextButton(
                    onPressed: () async {
                      final endDate = await _showDatePickerDialog(context);
                      if (endDate != null) {
                        setState(() {
                          discountEndDate = endDate;
                        });
                      }
                    },
                    child: Text(
                      'تحديد',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              Text(
                discountEndDate == null
                    ? 'تاريخ نهاية الخصم: غير محدد'
                    : 'تاريخ نهاية الخصم: ${discountEndDate.toString().split(" ")[0]}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _addOffer(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDFABBB),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  child: Text(
                    'اضافة العرض ',
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
