import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class PredictPage extends StatefulWidget {
  const PredictPage({super.key});
  @override
  State<PredictPage> createState() => _PredictPageState();
}

class _PredictPageState extends State<PredictPage> {
  final _formKey = GlobalKey<FormState>();
  final _hoursCtrl = TextEditingController();
  bool _loading = false;
  String? _result;

  @override
  void dispose() {
    _hoursCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(String text) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('last_prediction', text);
  }

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;
    final hours = double.parse(_hoursCtrl.text.trim());
    setState(() => _loading = true);
    try {
      final y = await ApiClient.predict(hours);
      final text = 'Tahmini puan: ${y.toStringAsFixed(1)}';
      setState(() => _result = text);
      await _save(text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sunucuya bağlanılamadı: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tahmin')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _hoursCtrl,
                decoration: const InputDecoration(
                  labelText: 'Çalışma saati (0–12)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _predict,
                icon: _loading
                    ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.cloud),
                label: Text(_loading ? 'Gönderiliyor...' : 'API’den Tahmin Al'),
              ),
            ),
            const SizedBox(height: 16),
            if (_result != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.insights),
                  title: Text(_result!, style: const TextStyle(fontSize: 18)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
