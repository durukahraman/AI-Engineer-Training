import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PredictPage extends StatefulWidget {
  const PredictPage({super.key});

  @override
  State<PredictPage> createState() => _PredictPageState();
}

class _PredictPageState extends State<PredictPage> {
  final _formKey = GlobalKey<FormState>();
  final _hoursCtrl = TextEditingController();
  String? _result;                 // ekranda gösterilecek mock sonuç
  String? _lastSavedPrediction;    // (ops) en son kaydedilen tahmin

  @override
  void initState() {
    super.initState();
    _loadLastPrediction();
  }

  Future<void> _loadLastPrediction() async {
    final sp = await SharedPreferences.getInstance();
    setState(() => _lastSavedPrediction = sp.getString("last_prediction"));
  }

  Future<void> _saveLastPrediction(String value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString("last_prediction", value);
  }

  void _predict() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli bir saat değeri girin')),
      );
      return;
    }

    final hours = double.parse(_hoursCtrl.text.trim());

    // --- MOCK TAHMİN --- (şimdilik basit bir formül)
    final predictedScore = (hours * 9.5 + 30).clamp(0, 100).toStringAsFixed(1);
    final text = "Tahmini puan: $predictedScore";

    setState(() => _result = text);

    // (Opsiyonel) kaydet
    await _saveLastPrediction(text);
  }

  @override
  void dispose() {
    _hoursCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tahmin')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_lastSavedPrediction != null) ...[
              Card(
                elevation: 1,
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Son kaydedilen tahmin'),
                  subtitle: Text(_lastSavedPrediction!),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _hoursCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Çalışma saati (0–12)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Boş bırakılamaz';
                  final x = double.tryParse(v);
                  if (x == null) return 'Sayı girin';
                  if (x < 0 || x > 12) return '0–12 arası olmalı';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _predict,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Tahmin Et'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _result = null),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Sıfırla'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_result != null)
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.insights),
                  title: Text(_result!, style: const TextStyle(fontSize: 18)),
                  trailing: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      Navigator.pop(context, _result); // geri dönüş örneği
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tahmin döndürüldü')),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
