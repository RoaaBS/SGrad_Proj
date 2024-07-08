import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgetPassword extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  ForgetPassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color myColor = Color.fromRGBO(240, 235, 232, 1);

    Future<Map<String, dynamic>> _requestPasswordReset(String email) async {
      final url = Uri.parse('http://192.168.1.11:3000/users/forgotpassword');
      final response = await http.post(
        url,
        body: json.encode({'email': email}),
        headers: {'Content-Type': 'application/json'},
      );
      return json.decode(response.body);
    }

    void _submitForm(BuildContext context) async {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('يرجى إدخال البريد الإلكتروني'),
          ),
        );
        return;
      }

      final Map<String, dynamic>? result = await _requestPasswordReset(email);

      // Check if the result is not null
      if (result != null) {
        // Handle the result accordingly
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'تم إرسال رمز التحقق لإعادة تعيين كلمة المرور إلى بريدك الإلكتروني.'),
            ),
          );
          Navigator.pushNamed(context, '/emailver');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'تم إرسال رمز التحقق لإعادة تعيين كلمة المرور إلى بريدك الإلكتروني.'),
            ),
          );
          Navigator.pushNamed(context, '/emailver');
        }
      } else {
        // Handle the case where the response is null
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: الاستجابة فارغة.'),
          ),
        );
      }
    }

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                ),
                const Text(
                  "هديتي",
                  style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.015,
                ),
                const Text(
                  "استرجاع كلمة السر ",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 114),
                Form(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.width * 0.1),
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: "البريد الإلكتروني",
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 41, 40, 40),
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.email,
                                size: MediaQuery.of(context).size.width * 0.06,
                                color: const Color.fromARGB(255, 41, 40, 40),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      MediaQuery.of(context).size.width * 0.01),
                                ),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      MediaQuery.of(context).size.width * 0.1),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width:
                                      MediaQuery.of(context).size.width * 0.01,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      MediaQuery.of(context).size.width * 0.1),
                                ),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      MediaQuery.of(context).size.width * 0.1),
                                ),
                                borderSide: BorderSide(
                                  color:
                                      const Color.fromARGB(255, 225, 121, 243),
                                  width:
                                      MediaQuery.of(context).size.width * 0.008,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'هذا المحتوى لا يمكن ان يكون فارغ';
                              }
                              if (!value.contains('@')) {
                                return 'ادخل البريد الالكتروني بشكل صحيح';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.035,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "استرجاع كلمة السر",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.03,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _submitForm(context);
                              },
                              child: Icon(Icons.navigate_next_rounded),
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    Color.fromARGB(255, 41, 40, 40),
                                backgroundColor:
                                    Color.fromARGB(255, 248, 247, 246),
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 150),
                    ],
                  ),
                ),
              ],
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
