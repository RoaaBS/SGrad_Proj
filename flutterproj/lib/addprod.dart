import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterproj/constant.dart';
import 'package:flutterproj/utils/cloudinaryUtils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'dart:io';
import 'package:http/http.dart' as http;

import 'auth_storage.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final picker = ImagePicker();
  String imagePath = "";
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productDescriptionController =
      TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  final TextEditingController productQuantityController =
      TextEditingController();
  String? productCategory;
  File? _image;

  // Future<void> _openImagePicker(BuildContext context) async {
  //   final PickedFile? image =
  //       await picker.getImage(source: ImageSource.gallery);

  //   if (image != null) {
  //     ImageCropper imageCropper =
  //         ImageCropper(); // Correctly instantiate the ImageCropper

  //     final croppedFile = await imageCropper.cropImage(
  //       sourcePath: image.path,
  //       aspectRatioPresets: [
  //         CropAspectRatioPreset.square,
  //         CropAspectRatioPreset.ratio3x2,
  //         // Add other aspect ratios as needed
  //       ],
  //       androidUiSettings: AndroidUiSettings(
  //         toolbarTitle: 'قص الصورة',
  //         toolbarColor: Colors.deepOrange,
  //         toolbarWidgetColor: Colors.white,
  //         initAspectRatio: CropAspectRatioPreset.original,
  //         lockAspectRatio: false,
  //       ),
  //       iosUiSettings: IOSUiSettings(
  //         minimumAspectRatio: 1.0,
  //       ),
  //     );

  //     if (croppedFile != null) {
  //       setState(() {
  //         imagePath = croppedFile.path;
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text('تم اختيار الصورة بنجاح'),
  //       ));
  //     }
  //   }
  // }
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

  Future<void> _addProduct(BuildContext context) async {
    if (productNameController.text.isEmpty ||
        productDescriptionController.text.isEmpty ||
        productPriceController.text.isEmpty ||
        productQuantityController.text.isEmpty ||
        imagePath.isEmpty ||
        productCategory == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('ادخل صورة ')));
      return;
    }

    final token = await AuthStorage.getStoreToken(); // Retrieve the store token
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الحساب غير مسموح له لعمل تعديلات')));
      return;
    }

    try {
      var response = await http.post(
        Uri.parse('${Constants.apiUrl}/stores/addProduct'), // Updated endpoint
        headers: {
          "Content-Type": "application/json",
          "Authorization": token // Use the store token
        },
        body: json.encode({
          'productName': productNameController.text,
          'description': productDescriptionController.text,
          'price': double.parse(productPriceController.text),
          'quantity': int.parse(productQuantityController.text),
          'image': imagePath,
          'category': productCategory,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('تم اضافة المنتج بنجاح')));
        Navigator.pushNamed(context, "/homePO");
        // Optionally reset the form or navigate away
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تعذر اضافة المنتج: ${response.body}')));
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
        title: Text(
          "إضافة منتج",
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
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "اسم المنتج",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: productNameController,
              decoration: InputDecoration(hintText: 'ادخل اسم المنتج'),
              textDirection: TextDirection.rtl,
            ),
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
              value: productCategory,
              items: ['شوكولاته', 'عطور', 'ورد'].map((String category) {
                return DropdownMenuItem(
                    value: category,
                    child: Text(category, textDirection: TextDirection.rtl));
              }).toList(),
              onChanged: (value) => setState(() => productCategory = value),
              decoration: InputDecoration(hintText: 'اختر نوع المنتج'),
            ),
            SizedBox(height: 10),
            Text(
              "وصف المنتج",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: productDescriptionController,
              decoration: InputDecoration(hintText: 'ادخل وصف المنتج'),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 10),
            Text(
              "سعر المنتج",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: productPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'ادخل سعر المنتج'),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 10),
            Text(
              "كمية المنتج",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: productQuantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'ادخل كمية المنتج'),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 10),
            imagePath.isEmpty
                ? Icon(Icons.image)
                : Image.network(imagePath, width: 100, height: 100),
            IconButton(
                onPressed: () => _openImagePicker(context),
                icon: Icon(Icons.camera)),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _addProduct(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDFABBB),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                ),
                child: Text(
                  'اضافة المنتج ',
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
    );
  }
}
