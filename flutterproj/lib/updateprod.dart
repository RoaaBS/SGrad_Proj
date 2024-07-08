import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterproj/constant.dart';
import 'package:flutterproj/utils/cloudinaryUtils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class updateproduct extends StatefulWidget {
  @override
  _updateproductState createState() => _updateproductState();
}

class _updateproductState extends State<updateproduct> {
  final picker = ImagePicker();
  String imagePath = "";
  String productId = ""; // Variable to store product ID
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productDescriptionController =
      TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  final TextEditingController productQuantityController =
      TextEditingController();
  String? productCategory;
  File? _image;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null) {
      setState(() {
        productId = args;
      });
      print("Product ID set to: $productId"); // Check the ID assignment
    }
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    final token = await AuthStorage.getStoreToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    try {
      var response = await http.get(
        Uri.parse('${Constants.apiUrl}/stores/ProductId/$productId'),
        headers: {"Authorization": token},
      );

      if (response.statusCode == 200) {
        var productData =
            json.decode(response.body)['product']; // Parse the data correctly
        setState(() {
          productNameController.text = productData['productName'];
          productDescriptionController.text = productData['description'];
          productPriceController.text = productData['price'].toString();
          productQuantityController.text = productData['quantity'].toString();
          productCategory = productData['category'];
          imagePath = productData['image']; // Assume URL or local path to image
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load product data: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching product data: $e')),
      );
    }
  }

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

  Future<void> _updateProduct(String id) async {
    final token = await AuthStorage.getStoreToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    try {
      var response = await http.put(
        Uri.parse('${Constants.apiUrl}/stores/updateprod/$id'),
        headers: {"Content-Type": "application/json", "Authorization": token},
        body: json.encode({
          'productName': productNameController.text,
          'description': productDescriptionController.text,
          'price': double.parse(productPriceController.text),
          'quantity': int.parse(productQuantityController.text),
          'image': imagePath,
          'category': productCategory,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تعديل المنتج بنجاح')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تعديل المنتج : ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تعديل المنتج: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "تعديل المنتج",
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
              "اسم المنتج ",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: productNameController,
              decoration: InputDecoration(hintText: 'ادخل اسم المنتج'),
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
                return DropdownMenuItem(value: category, child: Text(category));
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
            ),
            SizedBox(height: 10),
            Text(
              "سعر المنتج ",
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
            ),
            SizedBox(height: 10),
            Text(
              "كمية المنتج ",
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
            ),
            SizedBox(height: 10),
            imagePath.isEmpty
                ? Icon(Icons.image)
                : Image.network((imagePath), width: 100, height: 100),
            IconButton(
              onPressed: () => _openImagePicker(context),
              icon: Icon(Icons.camera),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (productId.isNotEmpty) {
                    _updateProduct(productId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Product ID is missing')),
                    );
                    print("Product ID is empty at button press");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDFABBB),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                ),
                child: Text(
                  'تعديل المنتج',
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
