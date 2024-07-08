import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> _handleLocationPermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled, return false
    return false;
  }

  // Check location permissions
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, return false
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, return false
    return false;
  }

  // Permissions are granted, return true
  return true;
}

Future<Position?> _getCurrentPosition() async {
  final hasPermission = await _handleLocationPermission();
  if (!hasPermission) {
    return null;
  }
  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium);
}

Future<String?> getCityNameFromCurrentPosition() async {
  Position? position = await _getCurrentPosition();
  if (position != null) {
    // Tulkarm: 32.313462, 35.025063
    // double latitude = 32.313462;
    // double longitude = 35.025063;

    // Nablue: 32.224069, 35.256784
    // double latitude = 32.224069;
    // double longitude = 35.256784;

    // Ramallah: 31.904961, 35.202590
    // double latitude = 31.904961;
    // double longitude = 35.202590;

    // GeoLocator position.
    double latitude = position.latitude;
    double longitude = position.longitude;

    var uri = Uri.parse(
        "https://geocode.maps.co/reverse?lat=32.313462&lon=35.025063&api_key=665b4749a29db253153120ptle96f36");
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["address"]["city"];
    } else {
      print("Faluire while fetching current city name");
    }
  } else {
    print("can't find current position");
  }
}
