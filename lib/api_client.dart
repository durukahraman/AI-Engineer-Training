import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // iOS Simulator için 127.0.0.1; gerçek cihazda Mac IP adresini kullan
  static const baseUrl = 'http://127.0.0.1:8000';

  static Future<double> predict(double hours) async {
    final res = await http.post(
      Uri.parse('$baseUrl/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'hours': hours}),
    );
    if (res.statusCode != 200) {
      throw Exception('API hata: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    // Backend’in regresyon döndürdüğünü biliyoruz:
    return (data['predicted'] as num).toDouble();
  }
}
