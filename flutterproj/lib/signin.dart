import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterproj/constant.dart';
import 'package:http/http.dart' as http;
import 'package:flutterproj/forgetPassword.dart';
import 'package:flutterproj/homeP.dart';

import 'package:flutterproj/signup.dart';
import 'package:flutterproj/auth_storage.dart'; // Ensure this is correctly imported

class SignIn extends StatefulWidget {
  static const String routeName = "/signin";

  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _showPassword = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Color myColor = Color.fromRGBO(240, 235, 232, 1);
    return Scaffold(
      backgroundColor: myColor,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Image.asset(
                "assets/images/signIn01.jpeg",
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                const Text(
                  "هديتي",
                  style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                const Text(
                  "تسجيل الدخول ",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                _buildEmailField(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.035),
                _buildPasswordField(),
                _buildForgotPasswordButton(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.10),
                _buildSignInButton(),
                SizedBox(height: 55),
                _buildSignUpPrompt(),
              ],
            ),
            Positioned.fill(
              left: 0,
              bottom: 0,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Image.asset(
                  "assets/images/signIn02.jpeg",
                  height: MediaQuery.of(context).size.height * 0.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Material(
        elevation: 4,
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.width * 0.1),
        child: TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: "البريد الإلكتروني",
            hintStyle:
                TextStyle(color: Color.fromARGB(255, 41, 40, 40), fontSize: 14),
            prefixIcon: Icon(Icons.email,
                size: MediaQuery.of(context).size.width * 0.06,
                color: Color.fromARGB(255, 41, 40, 40)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(MediaQuery.of(context).size.width * 0.01)),
                borderSide: BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(MediaQuery.of(context).size.width * 0.1)),
                borderSide: BorderSide(
                    color: Colors.red,
                    width: MediaQuery.of(context).size.width * 0.01)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(MediaQuery.of(context).size.width * 0.1)),
                borderSide: BorderSide(color: Colors.white)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(MediaQuery.of(context).size.width * 0.1)),
                borderSide: BorderSide(
                    color: Color.fromARGB(255, 225, 121, 243),
                    width: MediaQuery.of(context).size.width * 0.008)),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Material(
        elevation: 4,
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.width * 0.1),
        child: TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: "كلمة السر",
            hintStyle: TextStyle(color: Color.fromARGB(255, 41, 40, 40)),
            prefixIcon: Icon(Icons.lock,
                size: MediaQuery.of(context).size.width * 0.06,
                color: Color.fromARGB(255, 41, 40, 40)),
            suffixIcon: IconButton(
              icon:
                  Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
            ),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(MediaQuery.of(context).size.width * 0.01)),
                borderSide: BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(MediaQuery.of(context).size.width * 0.1)),
                borderSide: BorderSide(
                    color: Colors.red,
                    width: MediaQuery.of(context).size.width * 0.01)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(MediaQuery.of(context).size.width * 0.1)),
                borderSide: BorderSide(color: Colors.white)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(MediaQuery.of(context).size.width * 0.1)),
                borderSide: BorderSide(
                    color: Color.fromARGB(255, 225, 121, 243),
                    width: MediaQuery.of(context).size.width * 0.008)),
          ),
          keyboardType: TextInputType.visiblePassword,
          obscureText: !_showPassword,
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 32),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ForgetPassword(),
              ),
            );
          },
          child: Text(
            "هل نسيت كلمة السر ",
            style: TextStyle(
              color: Color.fromARGB(255, 112, 102, 102),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "الدخول",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.03,
          ),
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
                  _handleSignIn(context);
                },
                icon: Icon(Icons.navigate_next_rounded),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "ليس لديك حساب؟ ",
          style: TextStyle(fontSize: 16),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return SignUp();
                },
              ),
            );
          },
          child: Text(
            "إنشاء حساب",
            style: TextStyle(
              decoration: TextDecoration.underline,
              decorationThickness: 2.0,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final url = Uri.parse('${Constants.apiUrl}/users/Login');
    final response = await http.post(
      url,
      body: json.encode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    return json.decode(response.body);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("خطأ"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("حسناً"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleSignIn(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog(
          context, "البريد الالكتروني و كلمة السر لا يمكن ان يكون فارغ.");
      return;
    }

    // Sign in with Firebase
    // UserCredential userCredential =
    //     await FirebaseAuth.instance.signInWithEmailAndPassword(
    //   email: email,
    //   password: password,
    // );

    // After successful Firebase Authentication, proceed directly
    final response = await signIn(email, password);
    if (response['status'] == 'success' && response.containsKey('token')) {
      await AuthStorage.setToken(response['token']);

      final userType = response['user']['userType'];
      if (userType == 'صاحب متجر') {
        Navigator.pushReplacementNamed(context, HomeP.routeName);
      } else {
        Navigator.pushReplacementNamed(context, HomeP.routeName);
      }
    } else {
      _showErrorDialog(context,
          "MongoDB Login failed: ${response['message'] ?? 'Unknown error'}");
    }
  }
  //   _showErrorDialog(context, "فشل تسجيل الدخول : ${e.message}");
  // } catch (e) {
  //   _showErrorDialog(context, "حدث خطأ اثناء الدخول .");
  //   print('Error during sign in: $e');
  // }
}
