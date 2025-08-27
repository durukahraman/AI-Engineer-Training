// lib/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // iOS Simulator: 127.0.0.1, Android Emulator: 10.0.2.2
  static const String baseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static Uri _u(String path) => Uri.parse('$baseUrl$path');

  static Future<Map<String, dynamic>> predict(List<double> features) async {
    final resp = await http.post(
      _u('/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'features': features}), // FastAPI'nin beklediği format
    );
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  /// YENİ: KNN endpointi: /predict_knn
  static Future<Map<String, dynamic>> predictKnn({
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
