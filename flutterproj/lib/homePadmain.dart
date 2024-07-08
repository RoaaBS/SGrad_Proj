import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:flutterproj/constant.dart';
import 'package:flutterproj/utils/cloudinaryUtils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

class homePadmin extends StatefulWidget {
  static String routeName = "/homePadmin";
  final String token; // Add token field

  homePadmin({Key? key, required this.token}) : super(key: key);

  @override
  _homePadminState createState() => _homePadminState();
}

class _homePadminState extends State<homePadmin> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String imagePath = "";

  Future<void> _openFilePicker(String token) async {
    try {
      // Allowing user to pick images and PDFs
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        // Upload the file to Cloudinary
        var uploadImageResponse = await uploadImage(file);

        if (uploadImageResponse.success) {
          // Use the URL from Cloudinary to show the file in the dialog
          String fileUrl = uploadImageResponse.url!;

          bool confirmed = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('تأكيد الملف'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('هل أنت متأكد من استخدام هذا الملف؟'),
                      SizedBox(height: 20),
                      result.files.single.extension == 'pdf'
                          ? Text("PDF File: ${file.path}")
                          : Image.network(fileUrl), // Displaying the file
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('نعم'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('إلغاء'),
                  ),
                ],
              );
            },
          );

          if (confirmed) {
            // Proceed with updating the license image or other actions
            updateLicenseImage(fileUrl, token);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('تم إلغاء تحديث الملف'),
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('فشل رفع الملف'),
          ));
        }
      }
    } catch (e) {
      print('Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('حدث خطأ أثناء رفع الملف'),
      ));
    }
  }

  Future<void> updateLicenseImage(String imageUrl, String token) async {
    final response = await http.put(
      Uri.parse(
          '${Constants.apiUrl}/stores/storeImage'), // Change URL to actual endpoint
      headers: {
        "Content-Type": "application/json",
        "Authorization": token,
      },
      body: jsonEncode({'licenseImageUrl': imageUrl}),
    );

    if (response.statusCode == 200) {
      print('License image updated successfully');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('تم تحديث الصورة بنجاح'),
      ));

      // Navigate or refresh as needed
      Navigator.pushNamed(context, '/joinOrder');
    } else {
      print('Failed to update license image');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update license image: ${response.body}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 235, 232, 1),
      appBar: AppBar(
        title: const Text(" الصفحة الرئيسية "),
        centerTitle: true,
        backgroundColor: Color(0xFFDFABBB),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'لتفعيل المتجر في النظام, ارفع صورة رخصة المحل',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _openFilePicker(widget.token),
              icon: Icon(Icons.add),
              label: Text('رفع الصورة'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFFDFABBB),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
