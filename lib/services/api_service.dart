import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // IMPORTANT : Change cette URL selon ton cas
  // Émulateur Android : http://10.0.2.2:8000
  // Appareil physique : http://TON_IP:8000 (trouve avec ipconfig)
  // iOS Simulator : http://localhost:8000
  static const String baseUrl = 'http://localhost:8000'; // Change si nécessaire

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'detail': 'Erreur ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e) {
      return {
        'detail': 'Impossible de se connecter au serveur. Vérifiez que le backend est lancé.'
      };
    }
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'detail': 'Erreur ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e) {
      return {
        'detail': 'Impossible de se connecter au serveur. Vérifiez que le backend est lancé.'
      };
    }
  }

  static Future<Map<String, dynamic>> loginWithGoogle(
      String email, String name, String googleId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'name': name,
          'google_id': googleId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'detail': 'Erreur ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e) {
      return {
        'detail': 'Impossible de se connecter au serveur.'
      };
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me?token=$token'),
      headers: await getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getTransactions(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/?user_id=$userId'),
      headers: await getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addTransaction(
      String userId, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions/?user_id=$userId'),
      headers: await getHeaders(),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<void> deleteTransaction(String transactionId) async {
    await http.delete(
      Uri.parse('$baseUrl/transactions/$transactionId'),
      headers: await getHeaders(),
    );
  }

  static Future<Map<String, dynamic>> getSummary(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/summary/$userId'),
      headers: await getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories/'),
      headers: await getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addCategory(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories/'),
      headers: await getHeaders(),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getRecommendations(
      String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/recommendations/$userId'),
      headers: await getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getSimulation(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/simulation/$userId'),
      headers: await getHeaders(),
    );
    return jsonDecode(response.body);
  }
  // Score financier
static Future<Map<String, dynamic>> getFinancialScore(String userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/data-science/score/$userId'),
    headers: await getHeaders(),
  );
  return jsonDecode(response.body);
}

// Tendances
static Future<Map<String, dynamic>> getTrends(String userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/data-science/trends/$userId'),
    headers: await getHeaders(),
  );
  return jsonDecode(response.body);
}
static Future<Map<String, dynamic>> getPrediction(String userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/data-science/prediction/$userId'),
    headers: await getHeaders(),
  );
  return jsonDecode(response.body);
}

static Future<Map<String, dynamic>> getAnomalies(String userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/data-science/anomalies/$userId'),
    headers: await getHeaders(),
  );
  return jsonDecode(response.body);
}

static Future<Map<String, dynamic>> getClustering(String userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/data-science/clustering/$userId'),
    headers: await getHeaders(),
  );
  return jsonDecode(response.body);
}

// Co-utilisateurs
static Future<List<dynamic>> getCoUsers(String userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/cousers/$userId'),
    headers: await getHeaders(),
  );
  return jsonDecode(response.body);
}

static Future<Map<String, dynamic>> inviteCoUser(
    String userId, String email) async {
  final response = await http.post(
    Uri.parse('$baseUrl/cousers/invite'),
    headers: await getHeaders(),
    body: jsonEncode({'user_id': userId, 'email': email}),
  );
  return jsonDecode(response.body);
}

static Future<void> removeCoUser(String userId, String coUserId) async {
  await http.delete(
    Uri.parse('$baseUrl/cousers/$userId/$coUserId'),
    headers: await getHeaders(),
  );
}
// OCR - Scanner un reçu
static Future<Map<String, dynamic>> scanReceipt(List<int> imageBytes, String fileName) async {
  final token = await getToken();
  final uri = Uri.parse('$baseUrl/ocr/scan');
  
  final request = http.MultipartRequest('POST', uri);
  
  if (token != null) {
    request.headers['Authorization'] = 'Bearer $token';
  }
  
  request.files.add(
    http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: fileName,
    ),
  );
  
  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);
  return jsonDecode(response.body);
}

}