import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İletişim')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Ad
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Adınız',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ad kısmı boş olamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // E-posta
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'E-posta boş olamaz';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Geçerli bir e-posta giriniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Mesaj
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Mesajınız',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Mesaj boş olamaz';
                  }
                  if (value.length < 10) {
                    return 'Mesaj en az 10 karakter olmalı';
                  }
                  if (value.length > 200) {
                    return 'Mesaj en fazla 200 karakter olabilir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Hero(
                tag: 'profile-pic',
                child: CircleAvatar(
                  radius: 64, // burada boyut farklı olabilir
                  backgroundImage: AssetImage('assets/avatar.png'),
                ),
              ),


              // Gönder butonu
              ElevatedButton.icon(
                onPressed: _isSending
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isSending = true);

                    // Simüle gönderim
                    Future.delayed(const Duration(seconds: 1), () {
                      setState(() => _isSending = false);
                      Navigator.pop(context, {
                        'name': _nameController.text,
                        'email': _emailController.text,
                        'message': _messageController.text,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mesaj başarıyla gönderildi!'),
                        ),
                      );
                      _formKey.currentState!.reset();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen tüm alanları doğru doldurun'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.send),
                label: _isSending
                    ? const Text('Gönderiliyor...')
                    : const Text('Gönder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
