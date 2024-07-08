import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutterproj/constant.dart';
import 'package:flutterproj/utils/cloudinaryUtils.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'auth_storage.dart';

class Profile extends StatefulWidget {
  static String routeName = "/homeP";

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String userName = "";
  String phoneNumber = "";
  String userEmail = "";
  String imagePath = "";
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final token = await AuthStorage.getToken(); // Retrieve the token
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication token not found')));
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/users/userProfile'),
        headers: {"Content-Type": "application/json", "Authorization": token},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userName = data['user']['username'];
          phoneNumber = data['user']['phoneNumber'] ?? "Not provided";
          imagePath = data['user']['userPicture'] ?? "";
          userNameController.text = userName;
          phoneNumberController.text = phoneNumber;
          userEmail = data['user']['email'] ?? "Not provided";
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to fetch profile')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> updateUserName(String newName) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication token not found')));
      return;
    }

    try {
      final response = await http.patch(
        Uri.parse('${Constants.apiUrl}/users/updateUserName'),
        headers: {"Content-Type": "application/json", "Authorization": token},
        body: jsonEncode({'username': newName}),
      );

      if (response.statusCode == 200) {
        setState(() {
          userName = newName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Username updated successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to update username')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> updatePhoneNumber(String newPhoneNumber) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication token not found')));
      return;
    }

    try {
      final response = await http.patch(
        Uri.parse('${Constants.apiUrl}/users/updatePhoneNumber'),
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

  Future<void> updateUserImage(String imagePath) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication token not found')));
      return;
    }

    try {
      var response = await http.patch(
        Uri.parse('${Constants.apiUrl}/users/updateImage'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token,
        },
        body: json.encode({'userPicture': imagePath}),
      );

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
        await updateUserImage(uploadImageResponse.url!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('فشل رفع الصورة'),
        ));
      }
    }
  }
  // Future<void> _openImagePicker() async {
  //   final picker = ImagePicker();
  //   final PickedFile? image =
  //       await picker.getImage(source: ImageSource.gallery);

  //   if (image != null) {
  //     final croppedFile = await ImageCropper().cropImage(
  //       sourcePath: image.path,
  //       aspectRatioPresets: [
  //         CropAspectRatioPreset.square,
  //         CropAspectRatioPreset.ratio3x2,
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
  //       await updateUserImage(croppedFile.path);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "صفحتي",
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
              " $userName :اسم المستخدم",
              Icons.edit,
              () {
                _showUserEditDialog(
                    context,
                    "تعديل الملف الشخصي",
                    "اسم المستخدم:",
                    userNameController,
                    userName, (newUserName) {
                  updateUserName(newUserName);
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
              " $userEmail :الايميل",
              Icons.email,
              () {
                _showEmailDialog(context, userEmail);
              },
            ),
            SizedBox(height: 20),
            _buildProfileTile(
              context,
              "موقعي",
              Icons.arrow_back_ios,
              () {
                Navigator.pushNamed(context, '/Add_Location');
              },
            ),
            SizedBox(height: 20),
            _buildProfileTile(
              context,
              "بطاقات",
              Icons.arrow_back_ios,
              () {
                Navigator.pushNamed(context, '/cardsPage');
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

  void _showUserEditDialog(
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
