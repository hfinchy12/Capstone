import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // final String _baseUrl = "http://10.0.2.2:5000"; // For Android emulator
  final String _baseUrl = "http://127.0.0.1:5000"; 
  // For iOS use localhost or your machine's IP, for Android use 10.0.2.2 for emulator

  Future<String> fetchData() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/data'));

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return json.decode(response.body)['data'];
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load data');
    }
  }

  Future<void> sendData(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/data'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send data');
    }
  }

  Future<void> uploadImage(String filePath) async {
    var uri = Uri.parse('$_baseUrl/upload');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('picture', filePath));

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Image uploaded successfully.');
    } else {
      print('Image upload failed.');
    }
  }

}
