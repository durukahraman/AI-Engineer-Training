import 'package:flutter/material.dart';
import 'counter_page.dart';
import 'contact_page.dart';

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
                  backgroundImage: AssetImage('assets/avatar.png'), // örnek avatar
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
                    final result = await Navigator.push<Map<String, String>?>(
                      context,
                      MaterialPageRoute(builder: (_) => const ContactPage()),
                    );

                    if (result != null) {
                      // Basit gösterim: SnackBar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Mesaj alındı: ${result['name']} • ${result['email']}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );

                      // (İsteğe bağlı) Son mesajı ekranda göstermek için setState kullan:
                      // setState(() => _lastMessage = result);
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
                  const Divider(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Son İletişim:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_lastName != null) Text('Ad: $_lastName'),
                        if (_lastEmail != null) Text('E-posta: $_lastEmail'),
                        const SizedBox(height: 6),
                        Text('Mesaj: $_lastMessage'),
                      ],
                    ),
                  ),
                ],
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
