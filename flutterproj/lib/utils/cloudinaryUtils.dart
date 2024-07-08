import 'dart:io';
import 'package:flutterproj/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CouldinaryResponse {
  bool success;
  String? url;

  CouldinaryResponse({required this.success, this.url});
}

Future<CouldinaryResponse> uploadImage(File imageFile) async {
  var uri = Uri.parse(Constants.cloudinaryUrl);
  print(imageFile);
  print(uri);
  const preset = Constants.coudinaryUploadPreset;
  print(preset);
  var request = http.MultipartRequest("POST", uri);
  request.fields['upload_preset'] = preset;
  var multipartFile = await http.MultipartFile.fromPath('file', imageFile.path);
  request.files.add(multipartFile);

  print("HELLO");
  var response = await request.send();
  print("BYE");
  print(response);

  if (response.statusCode == 200) {
    var responseData = await response.stream.toBytes();
    var result = String.fromCharCodes(responseData);
    var data = json.decode(result);
    return CouldinaryResponse(success: true, url: data['secure_url']);
  } else {
    return CouldinaryResponse(success: true, url: null);
  }
}
