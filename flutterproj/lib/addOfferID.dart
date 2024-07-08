import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterproj/constant.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutterproj/auth_storage.dart';

class addOfferID extends StatefulWidget {
  static const routeName = "/addOfferID";

  @override
  _AddOfferIDState createState() => _AddOfferIDState();
}

class _AddOfferIDState extends State<addOfferID> {
  final TextEditingController _discountController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String productId = ""; //

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null) {
      setState(() {
        productId = args;
      });
      print("Product ID set to: $productId"); // تحقق من تعيين الـ ID
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context) != null) {
        final args = ModalRoute.of(context)!.settings.arguments as String?;
        print("Received ID in addOfferID: $args");
        if (args != null) {
          setState(() {
            productId = args;
          });
        }
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _addOffer(String id) async {
    print("Attempting to add offer with ID: $productId");
    if (_discountController.text.isEmpty ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('يرجى ملء جميع الحقول')));
      return;
    }

    final double? discount = double.tryParse(_discountController.text);
    if (discount == null || discount < 0 || discount > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الرجاء إدخال نسبة خصم صحيحة بين 0 و 100')));
      return;
    }

    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('التوكن غير موجود')));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/stores/addOffer/$id'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token,
        },
        body: json.encode({
          'discount': discount,
          'discountStartDate': DateFormat('yyyy-MM-dd').format(_startDate!),
          'discountEndDate': DateFormat('yyyy-MM-dd').format(_endDate!),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("إضافة عرض"),
        centerTitle: true,
        backgroundColor: Color(0xFFDFABBB),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _discountController,
                decoration: InputDecoration(
                  labelText: 'نسبة الخصم (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ListTile(
                title: Text(
                    'تاريخ بداية الخصم: ${_startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : "غير محدد"}'),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: Text(
                    'تاريخ نهاية الخصم: ${_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : "غير محدد"}'),
                onTap: () => _selectDate(context, false),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => _addOffer(productId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDFABBB),
                    foregroundColor:
                        Colors.white, // هذا يحدد لون النص والأيقونات داخل الزر
                  ),
                  child: Text('إضافة العرض'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
