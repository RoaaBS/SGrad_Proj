// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class MapPage extends StatefulWidget {
//   final LatLng location;

//   // Constructor requires a location argument
//   MapPage({Key? key, required this.location}) : super(key: key);

//   @override
//   _MapPageState createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   late GoogleMapController mapController;

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Google Map'),
//         backgroundColor: Color(0xFFDFABBB),
//       ),
//       body: GoogleMap(
//         onMapCreated: _onMapCreated,
//         initialCameraPosition: CameraPosition(
//           target: widget.location, // Uses the passed location
//           zoom: 14.0,
//         ),
//       ),
//     );
//   }
// }
