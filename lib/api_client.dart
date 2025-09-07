// lib/api_client.dart
import 'dart:convert'; // jsonEncode/jsonDecode
import 'package:http/http.dart' as http;

class ApiClient {
  // iOS: 127.0.0.1, Android emulator: 10.0.2.2
  static const String baseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static Uri _u(String path) => Uri.parse('$baseUrl$path');

  // Classic 2-feature model
  static Future<Map<String, dynamic>> predict(List<double> features) async {
    final resp = await http.post(
      _u('/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'features': features}),
    );
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  // Diabetes regression (KNNReg)
  static Future<double> predictDiabetes(List<double> features) async {
    final resp = await http.post(
      _u('/predict_diabetes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'features': features}),
    );
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (data['prediction'] != null) {
      return (data['prediction'] as num).toDouble();
    }
    throw Exception(data['error'] ?? 'Beklenmeyen yanıt');
  }

  /// Iris KNN – FEATURES LİSTESİ VERSİYONU (ÖNERİLEN)
  static Future<Map<String, dynamic>> predictKnnWithFeatures({
    required double sepalLength,
    required double sepalWidth,
    required double petalLength,
    required double petalWidth,
  }) async {
    final resp = await http.post(
      _u('/predict_knn'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'features': [sepalLength, sepalWidth, petalLength, petalWidth],
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  /// Iris KNN – ADLANDIRILMIŞ ALANLAR VERSİYONU (EĞER BACKEND BÖYLEYSE BUNU KULLAN)
  static Future<Map<String, dynamic>> predictKnnWithNamedFields({
    required double sepalLength,
    required double sepalWidth,
    required double petalLength,
    required double petalWidth,
  }) async {
    final resp = await http.post(
      _u('/predict_knn'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sepal_length': sepalLength,
        'sepal_width': sepalWidth,
        'petal_length': petalLength,
        'petal_width': petalWidth,
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }
}
