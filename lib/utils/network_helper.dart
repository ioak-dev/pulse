import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkHelper {
  final String baseUrl;

  NetworkHelper(this.baseUrl);


  Future<dynamic> get(String endpoint, String token) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(
        url,
        headers: {
          'authorization': token,
          'Content-Type': 'application/json',
        },
      );
      print('response from api, $response');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body,
      {required String apiKey}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Request failed: ${response.statusCode}');
    }
  }

  Future<dynamic> put(String endpoint, dynamic body, String apiKey) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(apiKey),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Map<String, String> _headers(String apiKey) {
    return {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
  }

  Future<dynamic> delete(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.body.isNotEmpty ? jsonDecode(response.body) : null;
      } else {
        throw Exception('Failed to delete data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during DELETE request: $e');
    }
  }
}
