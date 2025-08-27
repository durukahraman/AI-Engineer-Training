import 'package:flutter/material.dart';
import 'counter_page.dart';
import 'contact_page.dart';
import 'predict_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  // ContactPage'den dönen son veriyi burada tutacağız
  String? _lastName;
  String? _lastEmail;
  String? _lastMessage;


  @override
  void initState() {
    super.initState();
    loadLastMessage().then((msg) {
      if (msg != null) {
        setState(() {
          _lastName = msg['name'];
          _lastEmail = msg['email'];
          _lastMessage = msg['message'];
        });
      }
    });

  }


  Future<void> _goToContact() async {
    final result = await Navigator.push<Map<String, String>?>(
      context,
      MaterialPageRoute(builder: (_) => const ContactPage()),
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mesaj alındı: ${result['name']} • ${result['email']}')),

      );

      // (Opsiyonel) setState(() => _lastMessage = result););
    }
  }

  Future<void> saveLastMessage(Map<String, String> msg) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('last_message', jsonEncode(msg));
  }

  Future<Map<String, String>?> loadLastMessage() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('last_message');
    if (raw == null) return null;
    final map = Map<String, dynamic>.from(jsonDecode(raw));
    return map.map((k, v) => MapEntry(k, v.toString()));
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
                const Hero(
                  tag: 'profile-pic',
                  child: CircleAvatar(
                    radius: 44,
                    backgroundImage: AssetImage('assets/avatar.png'),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Duru Kahraman',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Flutter & AI Çalışmaları',
                  style: TextStyle(
                    fontSize: 18,
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
                const _InfoTile(
                  icon: Icons.email,
                  label: 'E-posta',
                  value: 'durukahraman1234@gmail.com',
                ),
                const _InfoTile(
                  icon: Icons.location_on,
                  label: 'Konum',
                  value: 'Ankara, TR',
                ),
                const SizedBox(height: 12),

                // --- Butonlar ---
                FilledButton.icon(
                  onPressed: () async {
                    final res = await Navigator.push<String?>(
                      context,
                      MaterialPageRoute(builder: (_) => const PredictPage()),
                    );
                    if (res != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gelen tahmin: $res')),
                      );
                    }
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const PredictPage(),
                        transitionsBuilder: (_, a, __, child) =>
                            FadeTransition(opacity: a, child: child),
                      ),
                    );
                  },
                  icon: const Icon(Icons.trending_up),
                  label: const Text('Tahmin Sayfası'),
                ),

                FilledButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push<Map<String, String>?>(
                      context,
                      MaterialPageRoute(builder: (_) => const ContactPage()),
                    );

                    if (result != null) {
                      setState(() {
                        _lastName = result['name'];
                        _lastEmail = result['email'];
                        _lastMessage = result['message'];
                      });
                      await saveLastMessage(result);
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
                      MaterialPageRoute(builder: (_) => const CounterPage()),
                    );
                  },
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Sayaç Sayfası'),
                ),


                // --- Son mesaj önizleme (ContactPage'den dönen veri) ---
                if (_lastMessage != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Son İletişim',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.teal, fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_lastName != null) Text('👤 Ad: $_lastName'),
                          if (_lastEmail != null) Text('✉ E-posta: $_lastEmail'),
                          const SizedBox(height: 6),
                          Text('💬 Mesaj: $_lastMessage'),
                        ],
                      ),
                    ),
                  ),
                ]

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

/// ContactPage: Form + controller + validation + Navigator.pop ile veri döndürme
