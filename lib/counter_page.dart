import 'package:flutter/material.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int counter = 0;

  void levelup() => setState(() => counter++);
  void levelup2() => setState(() => counter+= 2);
  void zero() {
    setState(() => counter = 0);
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
              "Butona $counter kez bastınız.",
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton(onPressed: levelup, child: const Text("Artır")),
                FilledButton(onPressed: levelup2, child: const Text("+2")),
                OutlinedButton(
                  onPressed: counter == 0 ? null : zero,
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
