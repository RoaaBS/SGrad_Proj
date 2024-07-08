import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutterproj/auth_storage.dart';
import 'package:flutterproj/constant.dart';

class PaypalPage extends StatefulWidget {
  static const String routeName = "/paypal";
  final double totalPrice;

  PaypalPage({required this.totalPrice});

  @override
  _PaypalPageState createState() => _PaypalPageState();
}

class _PaypalPageState extends State<PaypalPage> {
  final _formKey = GlobalKey<FormState>();
  String? firstName, lastName, cardNumber, cvn;
  String? selectedCardType;
  String? selectedMonth;
  String? selectedYear;
  late String totalAmount;
  TextEditingController otpController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  String? cardId; // Declare cardId at the class level

  List<String> months =
      List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  List<String> years =
      List.generate(50, (index) => (DateTime.now().year + index).toString());

  @override
  void initState() {
    super.initState();
    totalAmount = widget.totalPrice
        .toStringAsFixed(2); // Format the total price to 2 decimal places
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Billing Information', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => showStoredCardDialog(),
                child: Text('هل تريد استخدام بطاقة مخزنة؟'),
              ),
              Text('Card Holder Info:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              buildTextField('First Name *', (value) => firstName = value,
                  controller: firstNameController),
              buildTextField('Last Name *', (value) => lastName = value,
                  controller: lastNameController),
              SizedBox(height: 20),
              Text('Payment Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Card Type *', style: TextStyle(fontSize: 16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  cardTypeButton('Visa', 'assets/images/294654_visa_icon.png'),
                  cardTypeButton('Mastercard',
                      'assets/images/1156750_finance_mastercard_payment_icon.png'),
                ],
              ),
              buildCardNumberTextField(
                  'Card Number *', (value) => cardNumber = value,
                  controller: cardNumberController),
              expirationRow(),
              SizedBox(height: 20),
              buildCVVTextField('CVN *', (value) => cvn = value),
              SizedBox(height: 30),
              Text('Total Amount:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('\$$totalAmount', style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardTypeButton(String cardType, String imagePath) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedCardType = cardType;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
        decoration: BoxDecoration(
          color: selectedCardType == cardType
              ? Colors.blue[100]
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selectedCardType == cardType ? Colors.blue : Colors.grey,
            width: 1.5,
          ),
        ),
        child: Image.asset(imagePath, width: 40, height: 40),
      ),
    );
  }

  Widget buildTextField(String label, void Function(String?) onSaved,
      {String? icon, TextEditingController? controller}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: icon != null ? Image.asset(icon, width: 24) : null,
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'This field is required' : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget buildCardNumberTextField(String label, void Function(String?) onSaved,
      {TextEditingController? controller}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(16),
          CardNumberInputFormatter(),
        ],
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          } else if (value.length < 16) {
            return 'Please enter a valid 16-digit card number';
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }

  Widget buildCVVTextField(String label, void Function(String?) onSaved) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) =>
            value == null || value.isEmpty ? 'This field is required' : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget expirationRow() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Expiration Month *'),
            value: selectedMonth,
            items: months.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedMonth = newValue;
              });
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Expiration Year *'),
            value: selectedYear,
            items: years.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedYear = newValue;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget submitButton() {
    return ElevatedButton(
      onPressed: () => showLoadingAndSuccessDialog(),
      child: Text('Submit Order'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColorLight,
        padding: EdgeInsets.symmetric(vertical: 19),
        textStyle: TextStyle(fontSize: 16),
      ),
    );
  }

  void showStoredCardDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('استخدام بطاقة مخزنة؟'),
          content: Text('هل تريد استخدام بطاقة مخزنة؟'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                final result = await Navigator.pushNamed(context, '/cardsPage');
                if (result != null && result is String) {
                  setState(() {
                    cardId = result;
                  });
                  fetchCardById(cardId!);
                }
              },
              child: Text('نعم'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('لا'),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchCardById(String cardId) async {
    String? token = await AuthStorage.getToken();
    if (token == null) {
      print("Authentication token not found");
      return;
    }

    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/users/cards/$cardId'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      var cardData = jsonDecode(response.body);
      setState(() {
        String cardHolderName = cardData['cardHolderName'];
        List<String> nameParts = cardHolderName.split(' ');
        String firstName = nameParts.isNotEmpty ? nameParts.first : '';
        String lastName =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        cardNumberController.text = cardData['cardNumber'];
        firstNameController.text = firstName;
        lastNameController.text = lastName;

        String expiryDate = cardData['expirationDate'];
        List<String> expiryParts = expiryDate.split('/');
        if (expiryParts.length == 2) {
          selectedMonth = expiryParts[0];
          selectedYear =
              '20' + expiryParts[1]; // Assuming the year is given in YY format
        }
      });
    } else {
      print('Failed to fetch card information: ${response.body}');
    }
  }

  void showLoadingAndSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Dismiss the loading dialog

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 50),
                SizedBox(height: 20),
                Text('تم تنفيذ العملية بنجاح', style: TextStyle(fontSize: 18)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                  Navigator.of(context).pop(cardId); // Send back the cardId
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }
}

// Utility class to format the input of card number
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    text = text.replaceAll(RegExp(r'\s+\b|\b\s'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      int nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' '); // Add space after every 4th digit
      }
    }
    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
