import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class EmailVerification extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  static const String routeName = "/emailver";

  EmailVerification({Key? key});

  Future<Map<String, dynamic>?> resetPassword(
      String email, String verificationCode, String newPassword) async {
    final url = Uri.parse('http://192.168.1.11:3000/users/resetpassword');
    final response = await http.post(
      url,
      body: json.encode({
        'email': email,
        'verificationCode': verificationCode,
        'newPassword': newPassword
      }),
      headers: {'Content-Type': 'application/json'},
    );
    return json.decode(response.body);
  }

  void _submitForm(BuildContext context) async {
    final email = _emailController.text.trim();
    final verificationCode = _verificationCodeController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    final Map<String, dynamic>? result =
        await resetPassword(email, verificationCode, newPassword);

    if (result != null) {
      if (result['msg'] == 'تم تحديث كلمة المرور بنجاح.') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تعيين كلمة سر جديدة.',
            ),
          ),
        );
        Navigator.pushNamed(context, '/signin');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ: ${result['msg']}',
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: الاستجابة فارغة.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color myColor = Color.fromRGBO(240, 235, 232, 1);
    return Scaffold(
      backgroundColor: myColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              "assets/images/signIn01.jpeg",
              width: MediaQuery.of(context).size.width * 1,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  const Text(
                    "هديتي",
                    style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  const Text(
                    "الحصول على الرمز",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "الرجاء إدخال  البريد الإلكتروني",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _emailController,
                      onChanged: (value) {},
                      decoration: InputDecoration(
                        hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "الرجاء إدخال الرمز الذي  تم إرساله إلى عنوان بريدك الإلكتروني",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _verificationCodeController,
                      onChanged: (value) {},
                      decoration: InputDecoration(
                        hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "ادخل كلمة السر الجديدة",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _newPasswordController,
                      onChanged: (value) {},
                      decoration: InputDecoration(
                        hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/forgetPassword');
                        },
                        child: Text(
                          "اعادة ارسال الرمز",
                          style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "  نأكيد الرمز",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.height * 0.1,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 248, 247, 246),
                                Color.fromARGB(255, 230, 186, 200),
                              ],
                              begin: Alignment.bottomRight,
                              end: Alignment.topLeft,
                            ),
                            borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.height * 0.1,
                            ),
                          ),
                          width: MediaQuery.of(context).size.width * 0.18,
                          height: MediaQuery.of(context).size.height * 0.05,
                          child: IconButton(
                            onPressed: () {
                              _submitForm(context);
                            },
                            icon: Icon(Icons.navigate_next_rounded),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 200),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              "assets/images/signIn02.jpeg",
              height: MediaQuery.of(context).size.height * 0.25,
            ),
          ),
        ],
      ),
    );
  }
}
