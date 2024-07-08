import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterproj/utils/cloudinaryUtils.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_storage.dart';
import 'constant.dart'; // Contains apiUrl and other constants

class AddStore extends StatefulWidget {
  @override
  _AddStoreState createState() => _AddStoreState();
}

class _AddStoreState extends State<AddStore> {
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _passwordVisible = false;
  String imagePath = "";
  String? _selectedCategory;
  String? _selectedCity;
  final picker = ImagePicker();
  File? _image;

  List<String> categories = ["ورد", "عطور", "شوكولاته"];
  Map<String, String> supportedCities = {
    "طولكرم": "Tulkarm",
    "رام الله": "Ramallah",
    "نابلس": "Nablus",
    "جنين": "Jenin",
    "الخليل": "Hebron",
    "القدس": "Jerusalem",
    "بيت لحم": "Bethlehem"
  };

  Future<void> _openImagePicker(BuildContext context) async {
    final PickedFile? pickedImage =
        await picker.getImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }

    if (_image != null) {
      var uploadImageResponse = await uploadImage(_image!);

      if (uploadImageResponse.success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('تم اختيار الصورة بنجاح'),
        ));
        setState(() {
          imagePath = uploadImageResponse.url!;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('فشل رفع الصورة'),
        ));
      }
    }
  }

  Future<void> addStore() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication token not found')));
      return;
    }

    print("SELECTED CITY: ${_selectedCity}");

    var payload = {
      'storeName': _storeNameController.text,
      'phoneNumber': _phoneNumberController.text,
      'email': _emailController.text,
      'description': _descriptionController.text,
      'image': imagePath,
      'city': _selectedCity,
    };

    print("store_payload: ${payload}");
    try {
      var response = await http.post(
        Uri.parse('${Constants.apiUrl}/users/addStore'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token,
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('تم اضافة المتجر بنجاح')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تعذر اضافة متجر: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("اضافة متجر",
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFFDFABBB),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _storeNameController,
              decoration: InputDecoration(hintText: 'ادخل اسم المتجر'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(hintText: 'ادخل رقم الهاتف للمتجر'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(hintText: 'عرف قليلا عن المتجر'),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCity,
              hint: Text('اختر مدينة المتجر'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCity = newValue;
                });
              },
              items: supportedCities.entries.map<DropdownMenuItem<String>>(
                  (MapEntry<String, String> city) {
                return DropdownMenuItem<String>(
                  value: city.value,
                  child: Text(city.key),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration:
                  InputDecoration(hintText: 'ادخل البريد الإلكتروني للمتجر'),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('الصور:', style: TextStyle(fontSize: 20)),
                SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      imagePath.isEmpty
                          ? Icon(Icons.image)
                          : Image.network(imagePath, width: 100, height: 100),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _openImagePicker(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: addStore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDFABBB),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                child: Text('اضافة المتجر',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
