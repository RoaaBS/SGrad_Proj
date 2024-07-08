// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import './auth_storage.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class AddLocationPage extends StatefulWidget {
//   @override
//   _AddLocationPageState createState() => _AddLocationPageState();
// }

// class _AddLocationPageState extends State<AddLocationPage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('إضافة موقع جديد'),
//         backgroundColor: Color(0xFFDFABBB),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: <Widget>[
//             TextField(
//               controller: _addressController,
//               decoration: InputDecoration(
//                 labelText: 'العنوان',
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _saveLocation,
//               child: Text(
//                 'حفظ الموقع',
//                 style: TextStyle(
//                     color: Colors.white), // Correct placement of TextStyle
//               ),
//               style: ButtonStyle(
//                 backgroundColor:
//                     MaterialStateProperty.all<Color>(Color(0xFFDFABBB)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _saveLocation() async {
//     String? token = await AuthStorage.getToken(); // Retrieve the token

//     if (token == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('لم يتم تسجيل الدخول')),
//       );
//       return;
//     }

//     var response = await http.post(
//       Uri.parse(
//           'http://192.168.1.4:3000/users/addAddress/662d2ee5ba320fae2c71d714'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': token,
//       },
//       body: json.encode({
//         'address': _addressController.text,
//       }),
//     );

//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('تم حفظ الموقع بنجاح!')),
//       );
//       // Example coordinates, replace with actual data or fetch from API
//       LatLng location = LatLng(37.4219999, -122.0840575);
//       Navigator.pushNamed(context, "/MapPage");
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text(
//                 'فشل في حفظ الموقع: ${json.decode(response.body)['message']}')),
//       );
//     }
//   }
// }
