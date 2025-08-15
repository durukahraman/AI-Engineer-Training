import 'package:flutter/material.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int sayac = 0;

  void arttir() => setState(() => sayac++);
  void arttir2() => setState(() => sayac += 2);
  void sifirla() {
    setState(() => sayac = 0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sayaç sıfırlandı')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sayaç Sayfası")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Butona $sayac kez bastınız.",
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton(onPressed: arttir, child: const Text("Artır")),
                FilledButton(onPressed: arttir2, child: const Text("+2")),
                OutlinedButton(
                  onPressed: sayac == 0 ? null : sifirla,
                  child: const Text("Sıfırla"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
