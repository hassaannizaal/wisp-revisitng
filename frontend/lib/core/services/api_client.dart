import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiClient {
  // Note: If testing on an Android Emulator, use 'http://10.0.2.2:5000'
  // If testing on Windows/Web/iOS Simulator, use 'http://localhost:5000'
  static const String baseUrl = 'http://localhost:5000';

  /// Performs a secure GET request to the backend
  Future<dynamic> getProtectedData() async {
    // 1. Get the current logged-in WISP user
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      throw Exception('Security Alert: No user logged in.');
    }

    // 2. Extract the secure Firebase ID Token
    final idToken = await user.getIdToken();

    // 3. Perform the request with the "Secret Handshake" (Bearer Token)
    final response = await http.get(
      Uri.parse('$baseUrl/api/wisps/protected'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken', 
      },
    );

    // 4. Handle the server's response
    if (response.statusCode == 200) {
      print('Backend says: ${response.body}');
      return jsonDecode(response.body);
    } else {
      print('Backend rejected us: ${response.body}');
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}
