import 'package:flutter/material.dart';


class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  // 1) Form anahtarı ve controller'lar
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  // 2) Basit e-posta kontrolü (çok katı değil, başlangıç için yeterli)
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'E-posta gerekli';
    final email = v.trim();
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return ok ? null : 'Geçerli bir e-posta gir';
  }

  // 3) Boş bırakma kontrolleri
  String? _validateRequired(String? v, String field) {
    if (v == null || v.trim().isEmpty) return '$field gerekli';
    return null;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final result = {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'message': _msgCtrl.text.trim(),
      };
      Navigator.pop(context, {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'message': _msgCtrl.text.trim(),
      }); // 🔙 sonucu geri döndür
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen formdaki hataları düzelt.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İletişim Sayfası')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled, // istersen .onUserInteraction yap
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Ad',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _validateRequired(v, 'Ad'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  border: OutlineInputBorder(),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _msgCtrl,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Mesaj',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _validateRequired(v, 'Mesaj'),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send),
                label: const Text('Gönder'),
              ),

              // (Opsiyonel) En altta girilen bilgileri canlı göster
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Önizleme',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text('Ad: ${_nameCtrl.text}'),
              Text('E-posta: ${_emailCtrl.text}'),
              Text('Mesaj: ${_msgCtrl.text}'),
            ],
          ),
        ),
      ),
    );
  }
}
