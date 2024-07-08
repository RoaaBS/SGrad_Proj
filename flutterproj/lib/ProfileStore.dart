import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutterproj/constant.dart';
import 'package:flutterproj/utils/cloudinaryUtils.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'auth_storage.dart';

class ProfileStore extends StatefulWidget {
  static String routeName = "/homeP";

  @override
  _ProfileStoreState createState() => _ProfileStoreState();
}

class _ProfileStoreState extends State<ProfileStore> {
  String storeName = "";
  String phoneNumber = "";
  String storeEmail = "";
  String imagePath = "";
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController storeNameController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchStoreProfile();
  }

  Future<void> fetchStoreProfile() async {
    final token = await AuthStorage.getStoreToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication token not found')));
      return;
    }
    print(token);
    final response = await http.get(
      Uri.parse("${Constants.apiUrl}/stores/storeProfile"),
      headers: {
        HttpHeaders.authorizationHeader: token,
      },
    );

    if (response.statusCode == 200) {
      print(token);
      final data = jsonDecode(response.body);
      print("This is the data retrieved from the database ${data}");
      final store = data['store'];
      setState(() {
        storeName = store['storeName'] ?? "";
        phoneNumber = store['phoneNumber'] ?? "Not provided";
        imagePath = store['profileImage'] ?? "";
        storeNameController.text = storeName;
        phoneNumberController.text = phoneNumber;
        storeEmail = store['email'] ?? "Not provided";
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to fetch profile')));
    }
  }

  Future<void> updateStoreName(String newName) async {
    final token = await AuthStorage.getStoreToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication token not found')));
      return;
    }

    try {
      final response = await http.patch(
        Uri.parse('${Constants.apiUrl}/stores/updateStoreName'),
        headers: {"Content-Type": "application/json", "Authorization": token},
        body: jsonEncode({'storeName': newName}),
      );

      if (response.statusCode == 200) {
        setState(() {
          storeName = newName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Store name updated successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update store name')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> updatePhoneNumber(String newPhoneNumber) async {
    final token = await AuthStorage.getStoreToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication token not found')));
      return;
    }

    try {
      final response = await http.patch(
        Uri.parse('${Constants.apiUrl}/stores/updateStorePhoneNumber'),
        headers: {"Content-Type": "application/json", "Authorization": token},
        body: jsonEncode({'phoneNumber': newPhoneNumber}),
      );

      if (response.statusCode == 200) {
        setState(() {
          phoneNumber = newPhoneNumber;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Phone number updated successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update phone number')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> updateStoreImage(String imagePath) async {
    final token = await AuthStorage.getStoreToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication token not found')));
      return;
    }
    print("This is the image path: $imagePath");

    try {
      var response = await http.patch(
        Uri.parse('${Constants.apiUrl}/stores/updateStoreProfileImage'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token,
        },
        body: json.encode({'profileImage': imagePath}),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          this.imagePath = imagePath;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('تم تحديث الصورة بنجاح')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('فشل في تحديث الصورة')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }

  Future<void> _openImagePicker() async {
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
        await updateStoreImage(uploadImageResponse.url!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('فشل رفع الصورة'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "صفحة المتجر ",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFDFABBB),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        imagePath.isNotEmpty ? NetworkImage(imagePath) : null,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: IconButton(
                    onPressed: _openImagePicker,
                    icon: Icon(Icons.camera_alt, color: Colors.black, size: 30),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildProfileTile(
              context,
              "اسم المتجر: $storeName",
              Icons.edit,
              () {
                _showStoreEditDialog(
                    context,
                    "تعديل الملف الشخصي",
                    "اسم المتجر:",
                    storeNameController,
                    storeName, (newStoreName) {
                  updateStoreName(newStoreName);
                });
              },
            ),
            SizedBox(height: 20),
            _buildProfileTile(
              context,
              "رقم الهاتف: $phoneNumber",
              Icons.edit,
              () {
                _showPhoneNumberEditDialog(
                    context,
                    "تغيير رقم الهاتف",
                    "ادخل رقم الهاتف الجديد:",
                    phoneNumberController,
                    phoneNumber, (newPhoneNumber) {
                  updatePhoneNumber(newPhoneNumber);
                });
              },
            ),
            SizedBox(height: 20),
            _buildProfileTile(
              context,
              "الايميل: $storeEmail",
              Icons.email,
              () {
                _showEmailDialog(context, storeEmail);
              },
            ),
            SizedBox(height: 20),
            _buildProfileTile(
              context,
              "المدينة",
              Icons.edit,
              () {
                _showEmailDialog(context, storeEmail);
              },
            ),
            SizedBox(height: 20),
            _buildProfileTile(
              context,
              "تسجيل الخروج",
              Icons.arrow_back_ios,
              () {
                Navigator.pushNamed(context, '/signin');
              },
              iconColor: Colors.red,
              textColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(
      BuildContext context, String title, IconData icon, VoidCallback onPressed,
      {Color? textColor, Color? iconColor}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor ?? Colors.black,
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: iconColor ?? Colors.black),
          Text(title,
              style: TextStyle(fontSize: 20, color: textColor ?? Colors.black)),
        ],
      ),
    );
  }

  void _showStoreEditDialog(
      BuildContext context,
      String dialogTitle,
      String fieldLabel,
      TextEditingController controller,
      String currentValue,
      ValueChanged<String> onSave) {
    controller.text = currentValue;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(dialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(fieldLabel),
              TextField(
                controller: controller,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(hintText: "ادخل قيمة جديدة"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context);
              },
              child: Text("حفظ"),
            ),
          ],
        );
      },
    );
  }

  void _showPhoneNumberEditDialog(
      BuildContext context,
      String dialogTitle,
      String fieldLabel,
      TextEditingController controller,
      String currentValue,
      ValueChanged<String> onSave) {
    controller.text = currentValue;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(dialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(fieldLabel),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number, // Ensures numeric keyboard
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Allow only digits
                  LengthLimitingTextInputFormatter(10), // Limit to 10 digits
                ],
                decoration: InputDecoration(hintText: "Enter new phone number"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.length == 10) {
                  onSave(controller.text);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text("Please enter a valid 10-digit phone number")),
                  );
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showEmailDialog(BuildContext context, String email) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("البريد الإلكتروني"),
            content: Text(email),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("إغلاق"),
              ),
            ],
          );
        });
  }
}
