import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'counter_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kartvizit',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const BusinessCardPage(),
    );
  }
}

class BusinessCardPage extends StatefulWidget {
  const BusinessCardPage({super.key});

  @override
  State<BusinessCardPage> createState() => _BusinessCardPageState();
}

class _BusinessCardPageState extends State<BusinessCardPage> {
  String _name = 'Duru Kahraman';
  String _email = 'durukahraman1234@gmail.com';
  String _locationOrNote = 'Ankara, TR'; // Mesajı burada göstereceğiz (not/konum)

  @override
  void initState() {
    super.initState();
    _loadData(); // açılışta kaydedilmiş verileri getir
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? _name;
      _email = prefs.getString('email') ?? _email;
      _locationOrNote = prefs.getString('note') ?? _locationOrNote;
    });
  }
  Future<void> _saveData({
    required String name,
    required String email,
    required String note,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('note', note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade100,
      body: Center(
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundImage: AssetImage('assets/avatar.png'),
                ),
                const SizedBox(height: 12),
                // İSİM: artık state’ten geliyor (const kaldırıldı)
                Text(
                  _name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Flutter Geliştirici Adayı',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.teal.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const _InfoTile(
                  icon: Icons.phone,
                  label: 'Telefon',
                  value: '+90 538 *** ****',
                ),
                // E-POSTA: state’ten
                _InfoTile(
                  icon: Icons.email,
                  label: 'E-posta',
                  value: _email,
                ),
                // NOT/KONUM: state’ten
                _InfoTile(
                  icon: Icons.location_on,
                  label: 'Not/Konum',
                  value: _locationOrNote,
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () async {
                    // ContactPage’e git ve dönüş değerini bekle
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ContactPage()),
                    );

                    // result bir Map bekliyoruz: {'ad': ..., 'email': ..., 'mesaj': ...}
                    if (result != null && mounted) {
                      // 1) Yeni değerleri hazırla
                      final newName = (result['ad'] ?? _name).toString();
                      final newEmail = (result['email'] ?? _email).toString();
                      final newNote = (result['mesaj'] ?? _locationOrNote).toString();

                      // 2) Ekranı güncelle
                      setState(() {
                        _name = newName;
                        _email = newEmail;
                        _locationOrNote = newNote;
                      });

                      // 3) Kalıcı olarak kaydet
                      await _saveData(name: newName, email: newEmail, note: newNote);

                      // 4) Bildirim
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bilgiler güncellendi!')),
                      );
                    }
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('İletişime Geç'),

                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CounterPage()),
                    );
                  },
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Sayaç Sayfası'),
                ),

                const SizedBox(height: 8), // butonlar arası boşluk
                TextButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('name');
                    await prefs.remove('email');
                    await prefs.remove('note');
                    setState(() {
                      _name = 'Duru Kahraman';
                      _email = 'durukahraman1234@gmail.com';
                      _locationOrNote = 'Ankara, TR';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bilgiler sıfırlandı')),
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Sıfırla'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
}


class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value),
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(vertical: -2),
    );
  }
}

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
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

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'İsim gerekli';
    if (v.trim().length < 2) return 'İsim çok kısa';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'E-posta gerekli';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Geçerli bir e-posta girin';
  }

  String? _validateMsg(String? v) {
    if (v == null || v.trim().isEmpty) return 'Mesaj gerekli';
    if (v.trim().length < 5) return 'Mesaj en az 5 karakter olmalı';
    return null;
  }

  void _submit() {
    // Tüm validator’lar true dönerse form geçerli
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus(); // klavyeyi kapat
      // Veriyi önceki sayfaya gönder
      Navigator.pop(context, {
        'ad': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'mesaj': _msgCtrl.text.trim(),
      });
      // İstersen burada SnackBar da gösterebilirsin.
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gönderildi!')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İletişim')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: _validateName,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: _validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _msgCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mesaj',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.message),
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: _validateMsg,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send),
                label: const Text('Gönder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
