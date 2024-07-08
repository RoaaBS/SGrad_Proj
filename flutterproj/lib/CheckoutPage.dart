import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterproj/CardsPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutterproj/auth_storage.dart';
import 'package:flutterproj/constant.dart';
import 'package:flutterproj/paypal.dart';

class CheckoutPage extends StatefulWidget {
  static const String routeName = "/checkout";

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool? delivery;
  bool showPaymentOptions = false;
  bool giftWrap = false;
  bool? payByCard;
  late double baseTotalPrice;
  TextEditingController addressController = TextEditingController();
  String?
      savedAddress; // Used to store the user's saved address from the database
  String? selectedCardId; // Used to store the selected cardId
  Map<String, dynamic>?
      selectedCardInfo; // Used to store the selected card information

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments as String?;
    if (arguments != null) {
      baseTotalPrice = double.parse(arguments);
    }
    fetchSavedAddress(); // Fetch the saved address from the backend on load
  }

  Future<void> fetchSavedAddress() async {
    String? token = await AuthStorage.getToken();
    if (token == null) {
      print("Authentication token not found");
      return;
    }

    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/users/address'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        savedAddress = data['address'];
      });
    } else {
      print('Failed to fetch saved address: ${response.body}');
    }
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
        selectedCardInfo = {
          'cardNumber': cardData['cardNumber'],
          'expiryDate': cardData[
              'expirationDate'], // Adjust this according to your schema
          'cardHolder': cardData[
              'cardHolderName'], // Adjust this according to your schema
          'lastFourDigits':
              cardData['lastFourDigits'], // Assuming you store this
        };
      });
    } else {
      print('Failed to fetch card information: ${response.body}');
    }
  }

  Future<bool> createOrder(String paymentType, String address, double total,
      String deliveryType, bool packaging) async {
    String? token = await AuthStorage.getToken();
    if (token == null) {
      print("Authentication token not found");
      return false;
    }

    final response = await http.post(
      Uri.parse('${Constants.apiUrl}/users/createOrder'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: jsonEncode({
        'PaymentType': paymentType,
        'address': address,
        'total': total,
        'DeliveryType': deliveryType,
        'packaging': packaging
      }),
    );

    return response.statusCode == 200;
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice =
        baseTotalPrice + (delivery == true ? 15 : 0) + (giftWrap ? 15 : 0);

    return Scaffold(
      appBar: AppBar(
        title: Text("تأكيد الطلب"),
        backgroundColor: Color(0xFFDFABBB),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            buildDeliveryOptions(),
            if (delivery != null && delivery == true) buildAddressInput(),
            buildGiftWrapOption(),
            if (showPaymentOptions) buildPaymentOptions(totalPrice),
            if (selectedCardInfo != null) buildSelectedCardInfo(),
            buildTotalAndConfirmButton(totalPrice),
          ],
        ),
      ),
    );
  }

  Widget buildDeliveryOptions() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  delivery = false;
                  showPaymentOptions = true;
                  payByCard = null; // Reset payment method selection
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.store, size: 40),
                  Text('استلام من المحل', style: TextStyle(fontSize: 18))
                ],
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor:
                    delivery == false ? Color(0xFFDFABBB) : Colors.grey[300],
                padding: EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  delivery = true;
                  showPaymentOptions = true;
                  payByCard = null; // Reset payment method selection
                  addressController.text =
                      ''; // Clear any previously entered address
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.motorcycle, size: 40),
                  Text('توصيل', style: TextStyle(fontSize: 18))
                ],
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor:
                    delivery == true ? Color(0xFFDFABBB) : Colors.grey[300],
                padding: EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAddressInput() {
    return Column(
      children: [
        ListTile(
          title: Text('استخدم العنوان المخزن؟'),
          subtitle: Text(savedAddress ?? 'لا يوجد عنوان مخزن.'),
          trailing: Checkbox(
            value: delivery == false || addressController.text.isNotEmpty,
            onChanged: (bool? value) {
              if (value == true) {
                addressController.text = savedAddress ?? '';
              }
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: addressController,
            decoration: InputDecoration(
              labelText: 'عنوان التوصيل',
              enabled: delivery == true,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildGiftWrapOption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ListTile(
        title: Text('هل تريد تغليف المنتج؟', style: TextStyle(fontSize: 18)),
        trailing: Checkbox(
          value: giftWrap,
          onChanged: (bool? value) {
            setState(() {
              giftWrap = value!;
            });
          },
        ),
      ),
    );
  }

  Widget buildPaymentOptions(double totalPrice) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaypalPage(
                        totalPrice: totalPrice), // Pass updated total price
                  ),
                );
                if (result != null && result is String) {
                  setState(() {
                    selectedCardId = result;
                    payByCard = true;
                    fetchCardById(selectedCardId!); // Fetch card info
                  });
                }
              },
              icon: Icon(Icons.credit_card),
              label: Text('بطاقة', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor:
                    payByCard == true ? Color(0xFFDFABBB) : Colors.grey[300],
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  payByCard = false;
                  selectedCardInfo = null; // Clear selected card info
                });
              },
              icon: Icon(Icons.attach_money),
              label: Text('نقدًا', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor:
                    payByCard == false ? Color(0xFFDFABBB) : Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSelectedCardInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4.0, // Adds a shadow
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Selected Card:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              if (selectedCardInfo != null) ...[
                Text(
                  'Card Number: XXXX-XXXX-XXXX-${selectedCardInfo!['lastFourDigits']}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Expiry Date: ${selectedCardInfo!['expiryDate']}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Card Holder: ${selectedCardInfo!['cardHolder']}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTotalAndConfirmButton(double totalPrice) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text('الإجمالي: \$${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (delivery == null || payByCard == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('الرجاء اختيار خيارات التوصيل والدفع.'),
                  ),
                );
                return;
              }

              String paymentType = payByCard == true ? 'Card' : 'Cash';
              String address =
                  delivery == true ? addressController.text : 'Store Pickup';
              String deliveryType = delivery == true ? 'Delivery' : 'Pickup';

              bool orderCreated = await createOrder(
                  paymentType, address, totalPrice, deliveryType, giftWrap);

              if (orderCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تأكيد الطلب بنجاح!'),
                  ),
                );
                Navigator.pushNamed(context, '/homeP');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('فشل في تأكيد الطلب. حاول مرة اخرى.'),
                  ),
                );
              }
            },
            child: Text('تأكيد الطلب', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFDFABBB),
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
