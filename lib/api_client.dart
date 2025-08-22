import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = "http://127.0.0.1:8000";

  static Future<int?> getNFeatures() async {
    final r = await http.get(Uri.parse("$baseUrl/health"));
    if (r.statusCode != 200) return null;
    final j = jsonDecode(r.body);
    return (j["n_features"] as num?)?.toInt();
  }

  static Future<Map<String, dynamic>> predict(List<double> features) async {
    final r = await http.post(
      Uri.parse("$baseUrl/predict"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"features": features}),
    );
    if (r.statusCode != 200) {
      throw Exception("API hata: ${r.statusCode} ${r.body}");
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
}
