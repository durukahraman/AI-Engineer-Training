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
  final List<TextEditingController> _ctrls =
  List.generate(10, (_) => TextEditingController());
  bool _loading = false;
  String? _result;

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  Future<void> _save(String text) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('last_prediction', text);
  }

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;

    final features = _ctrls.map((c) => double.parse(c.text.trim())).toList();

    setState(() => _loading = true);
    try {
      final resp = await ApiClient.predict(features);
      final pred = resp["prediction"];
      final proba = resp["proba"];
      final text = proba == null
          ? "Tahmin: $pred"
          : "Tahmin: $pred  •  Güven: ${(proba * 100).toStringAsFixed(1)}%";
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

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    isDense: true,
  );

  String? _validator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Boş bırakılamaz';
    final x = double.tryParse(v);
    if (x == null) return 'Sayı girin';
    // opsiyonel sınır: if (x < -10 || x > 10) return '-10 ile 10 arası';
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tahmin')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // GridView mutlaka sınırlı yükseklik almalı → Expanded
              Expanded(
                child: Form(
                  key: _formKey,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3.6,
                    ),
                    itemCount: _ctrls.length, // 10
                    itemBuilder: (_, i) => TextFormField(
                      controller: _ctrls[i],
                      decoration: InputDecoration(
                        labelText: 'f$i',
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Boş bırakılamaz';
                        final x = double.tryParse(v);
                        if (x == null) return 'Sayı girin';
                        return null;
                      },
                    ),
                  ),
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

              const SizedBox(height: 12),

              if (_result != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.insights),
                    title: Text(_result!, style: const TextStyle(fontSize: 16)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}
