import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterproj/constant.dart';
import 'package:http/http.dart' as http;
import 'package:flutterproj/homeP.dart';

import 'package:flutterproj/auth_storage.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _showpassword = false;
  bool _showConfirmpassword = false;
  String _selectedAccountType = " ";
  final String _baseUrl = "http://192.168.1.8:3000/users";

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmpasswordController = TextEditingController();

  Future<bool> register(
      String username, String email, String password, String userType) async {
    try {
      // Register user in Firebase
      // UserCredential userCredential =
      //     await FirebaseAuth.instance.createUserWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // );

      // String uid = userCredential.user!.uid;
      // await FirebaseFirestore.instance.collection('users').doc(uid).set({
      //   'username': username,
      //   'email': email,
      //   'userType': userType,
      //   'uid': uid, // Storing UID is optional since it's the document ID
      // });
      // If Firebase registration is successful, register the user in your MongoDB
      final response = await http.post(
        Uri.parse("${Constants.apiUrl}/users/register"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password':
              password, // Consider not sending password to MongoDB if Firebase handles auth
          'userType': userType,
          // 'uid': userCredential.user!.uid // Optionally store Firebase UID in MongoDB
        }),
      );
      if (response.statusCode == 201) {
        var data = json.decode(response.body);
        await AuthStorage.setToken(data['token']); // Save token to storage
        print(
            "Token saved: ${data['token']}"); // Add this line to debug token storage
        return true;
      } else {
        print('MongoDB registration error: ${response.body}');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase registration failed with error code: ${e.code}');
      print(e.message);
      return false;
    }
  }

  void _signUp() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmpasswordController.text.trim();

    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("خطأ"),
          content: Text("كلمة المرور وتأكيد كلمة المرور غير متطابقين."),
          actions: [
            TextButton(
              child: Text("حسناً"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    bool isRegistered =
        await register(username, email, password, _selectedAccountType);
    if (isRegistered) {
      switch (_selectedAccountType) {
        case 'مستخدم':
          Navigator.pushReplacementNamed(context, HomeP.routeName);
          break;
        case 'صاحب متجر':
          Navigator.pushReplacementNamed(context, HomeP.routeName);
          break;
        default:
          Navigator.pushReplacementNamed(context, HomeP.routeName);
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("خطأ"),
          content: Text("فشل في التسجيل، الرجاء المحاولة مرة أخرى."),
          actions: [
            TextButton(
              child: Text("حسناً"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
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
          Align(
            alignment: Alignment.topLeft,
            child: Image.asset(
              "assets/images/signIn01.jpeg",
              width: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                const Text(
                  "إنشاء حساب ",
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Form(
                  child: Column(
                    children: [
                      _buildUsernameField(),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      _buildAccountTypeField(),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      _buildEmailField(),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      _buildPasswordField(),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      _buildConfirmPasswordField(),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.10),
                      _buildSignUpButton(),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.06),
                      _buildLoginPrompt(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Image.asset(
              "assets/images/signIn02.jpeg",
              height: MediaQuery.of(context).size.height * 0.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameField() {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Material(
        elevation: 4,
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.width * 0.1),
        child: TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            hintText: "اسم المستخدم",
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.person,
                size: MediaQuery.of(context).size.width * 0.06,
                color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(MediaQuery.of(context).size.width * 0.1)),
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(MediaQuery.of(context).size.width * 0.1)),
              borderSide: BorderSide(
                  color: const Color.fromARGB(255, 225, 121, 243),
                  width: MediaQuery.of(context).size.width * 0.008),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTypeField() {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Material(
        elevation: 4,
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.width * 0.1),
        child: DropdownButtonFormField<String>(
          value: _selectedAccountType,
          decoration: InputDecoration(
            hintText: "نوع الحساب  ",
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.person,
                size: MediaQuery.of(context).size.width * 0.06,
                color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(MediaQuery.of(context).size.width * 0.1)),
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(MediaQuery.of(context).size.width * 0.1)),
              borderSide: BorderSide(
                  color: const Color.fromARGB(255, 225, 121, 243),
                  width: MediaQuery.of(context).size.width * 0.008),
            ),
          ),
          items: [" ", "مستخدم", "صاحب متجر"]
              .map<DropdownMenuItem<String>>(
                  (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
              .toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedAccountType = value!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Material(
        elevation: 4,
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.width * 0.1),
        child: TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: "البريد الإلكتروني",
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.email,
                size: MediaQuery.of(context).size.width * 0.06,
                color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(MediaQuery.of(context).size.width * 0.1)),
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(MediaQuery.of(context).size.width * 0.1)),
              borderSide: BorderSide(
                  color: const Color.fromARGB(255, 225, 121, 243),
                  width: MediaQuery.of(context).size.width * 0.008),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Material(
        elevation: 4,
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.width * 0.1),
        child: TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: "كلمة السر",
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.lock,
                size: MediaQuery.of(context).size.width * 0.06,
                color: Colors.grey),
            suffixIcon: IconButton(
              icon:
                  Icon(_showpassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _showpassword = !_showpassword;
                });
              },
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(MediaQuery.of(context).size.width * 0.01)),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(MediaQuery.of(context).size.width * 0.1)),
              borderSide: BorderSide(
                  color: Colors.red,
                  width: MediaQuery.of(context).size.width * 0.01),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(MediaQuery.of(context).size.width * 0.1)),
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(MediaQuery.of(context).size.width * 0.1)),
              borderSide: BorderSide(
                  color: const Color.fromARGB(255, 225, 121, 243),
                  width: MediaQuery.of(context).size.width * 0.008),
            ),
          ),
          keyboardType: TextInputType.visiblePassword,
          obscureText: !_showpassword,
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Material(
        elevation: 4,
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.width * 0.1),
        child: TextFormField(
          controller: _confirmpasswordController,
          decoration: InputDecoration(
            hintText: "تأكيد كلمة السر",
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.lock,
                size: MediaQuery.of(context).size.width * 0.06,
                color: Colors.grey),
            suffixIcon: IconButton(
              icon: Icon(_showConfirmpassword
                  ? Icons.visibility_off
                  : Icons.visibility),
              onPressed: () {
                setState(() {
                  _showConfirmpassword = !_showConfirmpassword;
                });
              },
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(MediaQuery.of(context).size.width * 0.1)),
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(MediaQuery.of(context).size.width * 0.1)),
              borderSide: BorderSide(
                  color: const Color.fromARGB(255, 225, 121, 243),
                  width: MediaQuery.of(context).size.width * 0.008),
            ),
          ),
          keyboardType: TextInputType.visiblePassword,
          obscureText: !_showConfirmpassword,
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "تسجيل",
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
            borderRadius:
                BorderRadius.circular(MediaQuery.of(context).size.height * 0.1),
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
                    MediaQuery.of(context).size.height * 0.1),
              ),
              width: MediaQuery.of(context).size.width * 0.18,
              height: MediaQuery.of(context).size.height * 0.05,
              child: IconButton(
                onPressed: _signUp,
                icon: Icon(Icons.navigate_next_rounded),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Text(
        "هل لديك حساب؟ تسجيل الدخول",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
