import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:flutterproj/constant.dart';
import 'package:http/http.dart' as http;

class CreditCardPage extends StatefulWidget {
  static const String routeName = "/CreditCardPage";

  @override
  _CreditCardPageState createState() => _CreditCardPageState();
}

class _CreditCardPageState extends State<CreditCardPage> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  String location = ''; // New field for location
  String city = ''; // New field for city
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 235, 232, 1),
      appBar: AppBar(
        title: Text('اضافة بطاقة ائتمان'),
        centerTitle: true,
        backgroundColor: Color(0xFFDFABBB),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
              obscureCardNumber: true,
              obscureCardCvv: true,
            ),
            CreditCardForm(
              formKey: formKey,
              onCreditCardModelChange: onCreditCardModelChange,
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              themeColor: Colors.blue,
              cardNumberDecoration: InputDecoration(
                labelText: 'رقم البطاقة',
                hintText: 'XXXX XXXX XXXX XXXX',
              ),
              expiryDateDecoration: InputDecoration(
                labelText: 'تاريخ الانتهاء',
                hintText: 'XX/XX',
              ),
              cvvCodeDecoration: InputDecoration(
                labelText: 'CVV',
                hintText: 'XXX',
              ),
              cardHolderDecoration: InputDecoration(
                labelText: 'اسم صاحب البطاقة',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  hintText: 'العنوان',
                ),
                onChanged: (value) {
                  location = value;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'المدينة',
                  hintText: 'المدينة',
                ),
                onChanged: (value) {
                  city = value;
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  submitData();
                }
              },
              child: Text('اضف بطاقة'),
            ),
          ],
        ),
      ),
    );
  }

  void submitData() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    String billingAddress =
        "$location, $city"; // Combine location and city into one string

    final response = await http.post(
      Uri.parse(
          '${Constants.apiUrl}/users/cards/add'), // Update this URL based on your actual API endpoint
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: jsonEncode({
        'cardNumber': cardNumber,
        'cardHolderName': cardHolderName,
        'expirationDate': expiryDate,
        'cvv': cvvCode,
        'billingAddress': billingAddress,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context, 'refresh');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم اضافة البطاقة بنجاح')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر اضافة البطاقة: ${response.body}')),
      );
    }
  }
}
