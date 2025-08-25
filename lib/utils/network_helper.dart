import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

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
        debugPrint('GET Response Body: ${response.body}');
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
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Authorization': apiKey,
      'Content-Type': 'application/json',
    };

    // Debugging: Log request details
    debugPrint('POST Request URL: $url');
    debugPrint('POST Request Headers: $headers');
    debugPrint('POST Request Body: ${jsonEncode(body)}');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    // Debugging: Log response details
    debugPrint('POST Response Status Code: ${response.statusCode}');
    debugPrint('POST Response Headers: ${response.headers}');
    debugPrint('POST Response Body: ${response.body}');

    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, dynamic body, String apiKey) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'authorization': apiKey,
      'Content-Type': 'application/json',
    };

    // Debugging: Log request details
    debugPrint('PUT Request URL: $url');
    debugPrint('PUT Request Headers: $headers'); // Log headers to verify API key
    debugPrint('PUT Request Body: ${jsonEncode(body)}');

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    // Debugging: Log response details
    debugPrint('PUT Response Status Code: ${response.statusCode}');
    debugPrint('PUT Response Headers: ${response.headers}');
    debugPrint('PUT Response Body: ${response.body}');

    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    debugPrint('Response Status Code: ${response.statusCode}');
    debugPrint('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Request failed: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Map<String, String> _headers(String apiKey) {
    return {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
  }

  Future<dynamic> delete(String endpoint, String apiKey) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      // Debugging: Log the request details
      debugPrint('DELETE Request URL: $url');
      debugPrint('DELETE Request Headers: {Authorization: $apiKey}');

      final response = await http.delete(
        url,
        headers: {
          'authorization': apiKey,
          'Content-Type': 'application/json',
        },
      );

      // Debugging: Log the response details
      debugPrint('DELETE Response Status Code: ${response.statusCode}');
      debugPrint('DELETE Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.body.isNotEmpty ? jsonDecode(response.body) : null;
      } else {
        throw Exception('Failed to delete data: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error during DELETE request: $e'); // Log the error for debugging
      throw Exception('Error during DELETE request: $e');
    }
  }
}
