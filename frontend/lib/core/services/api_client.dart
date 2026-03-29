import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../src/features/auth/data/auth_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return ApiClient(authRepo);
});

class ApiClient {
  final AuthRepository _authRepo;
  late final String baseUrl;

  ApiClient(this._authRepo) {
    // Falls back to localhost if .env is missing or key is undefined
    baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000/api';
  }

  /// Performs a secure GET request to the backend
  Future<dynamic> getProtectedData() async {
    // 1. Get the current logged-in WISP user from the repository
    final user = _authRepo.currentUser;
    if (user == null) throw Exception('Security Alert: No user logged in.');

    // 2. Extract the secure Firebase ID Token via the repository abstraction
    final idToken = await _authRepo.getIdToken();
    if (idToken == null) throw Exception('Security Alert: Could not retrieve ID Token.');

    // 3. Perform the request with the "Secret Handshake" (Bearer Token)
    final response = await http.get(
      Uri.parse('$baseUrl/wisps/protected'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken', 
      },
    );

    // 4. Handle the server's response
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  /// Performs a secure POST request to save a new Wisp
  Future<Map<String, dynamic>> saveWisp(String mood, String reflection) async {
    // 1. Get the current logged-in WISP user from the repository
    final user = _authRepo.currentUser;
    if (user == null) throw Exception('Security Alert: No user logged in.');

    // 2. Extract the secure Firebase ID Token via the repository abstraction
    final idToken = await _authRepo.getIdToken();
    if (idToken == null) throw Exception('Security Alert: Could not retrieve ID Token.');

    // 3. Perform the POST request to the backend
    final response = await http.post(
      Uri.parse('$baseUrl/wisps'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'mood': mood,
        'reflection': reflection,
      }),
    );

    // 4. Handle the response
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return responseData;
    } else {
      throw Exception(responseData['error'] ?? 'Failed to save Wisp');
    }
  }
}
