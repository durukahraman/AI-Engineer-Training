import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

enum ModelType { knn, classic } // classic: /predict ile çalışan (2 feature)

class PredictPage extends StatefulWidget {
  const PredictPage({super.key});
  @override
  State<PredictPage> createState() => _PredictPageState();
}

class _PredictPageState extends State<PredictPage> {
  final _formKey = GlobalKey<FormState>();

  ModelType _model = ModelType.knn;

  // Max 4 alan; classic model 2'sini kullanır.
  final List<TextEditingController> _ctrls =
  List.generate(4, (_) => TextEditingController());

  bool _loading = false;
  String? _result;

  String? _className;
  List<double>? _probs;

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  Future<void> _save(String text) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('last_prediction', text);
  }

  String? _validator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Boş bırakılamaz';
    final x = double.tryParse(v.trim().replaceAll(',', '.'));
    if (x == null) return 'Sayı girin';
    return null;
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    isDense: true,
  );

  List<Widget> _buildInputs() {
    if (_model == ModelType.knn) {
      return [
        TextFormField(controller: _ctrls[0], decoration: _dec('Sepal Length'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validator),
        const SizedBox(height: 12),
        TextFormField(controller: _ctrls[1], decoration: _dec('Sepal Width'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validator),
        const SizedBox(height: 12),
        TextFormField(controller: _ctrls[2], decoration: _dec('Petal Length'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validator),
        const SizedBox(height: 12),
        TextFormField(controller: _ctrls[3], decoration: _dec('Petal Width'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validator),
      ];
    } else {
      return [
        TextFormField(controller: _ctrls[0], decoration: _dec('x1'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validator),
        const SizedBox(height: 12),
        TextFormField(controller: _ctrls[1], decoration: _dec('x2'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validator),
      ];
    }
  }

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      if (_model == ModelType.knn) {
        final sepalLength =
        double.parse(_ctrls[0].text.trim().replaceAll(',', '.'));
        final sepalWidth =
        double.parse(_ctrls[1].text.trim().replaceAll(',', '.'));
        final petalLength =
        double.parse(_ctrls[2].text.trim().replaceAll(',', '.'));
        final petalWidth =
        double.parse(_ctrls[3].text.trim().replaceAll(',', '.'));

        final resp = await ApiClient.predictKnn(
          sepalLength: sepalLength,
          sepalWidth: sepalWidth,
          petalLength: petalLength,
          petalWidth: petalWidth,
        );

        final className = resp['class_name'] as String?;
        final probs = (resp['probs'] as List).map((e) => (e as num).toDouble()).toList();

        final text =
            'Tahmin: $className  •  Olasılıklar: ${probs.map((e) => e.toStringAsFixed(2)).toList()}';

        setState(() {
          _result = text;
          _className = className;   // yeni
          _probs = probs;           // yeni
        });
        await _save(text);
      } else {
        final x1 =
        double.parse(_ctrls[0].text.trim().replaceAll(',', '.'));
        final x2 =
        double.parse(_ctrls[1].text.trim().replaceAll(',', '.'));

        final resp = await ApiClient.predict([x1, x2]);
        final y = (resp['prediction'] ?? resp['class']) as num?;
        final proba = resp['proba'] as num?;
        final text = proba == null
            ? 'Model: Classic • Tahmin: ${y?.toString()}'
            : 'Model: Classic • Tahmin: ${y?.toString()} • Güven: ${(proba * 100).toStringAsFixed(1)}%';
        setState(() => _result = text);
        await _save(text);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sunucuya bağlanılamadı: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _reset() {
    for (final c in _ctrls) c.clear();
    setState(() {
      _result = null;
      _className = null;
      _probs = null;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Model Seçimli Tahmin')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Model seçimi
              Row(
                children: [
                  const Text('Model:'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<ModelType>(
                      value: _model,
                      decoration: _dec('Model'),
                      items: const [
                        DropdownMenuItem(
                          value: ModelType.knn,
                          child: Text('KNN (4 özellik)'),
                        ),
                        DropdownMenuItem(
                          value: ModelType.classic,
                          child: Text('Classic (/predict, 2 özellik)'),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _model = v ?? ModelType.knn;
                          _result = null; // eski sonucu temizle
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dinamik inputlar
              Form(
                key: _formKey,
                child: Column(children: _buildInputs()),
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _loading ? null : _predict,
                      icon: _loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.cloud),
                      label: Text(_loading ? 'Gönderiliyor...' : 'API’den Tahmin Al'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              if (_result != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.insights),
                            SizedBox(width: 8),
                            Text('Tahmin Sonucu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_className != null)
                          Chip(
                            label: Text(_className!, style: const TextStyle(color: Colors.white)),
                            backgroundColor: Colors.blue,
                          ),
                        const SizedBox(height: 8),
                        Text(_result!),
                      ],
                    ),
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }
}
