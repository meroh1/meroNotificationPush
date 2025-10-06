import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotifyPage(),
    );
  }
}

class NotifyPage extends StatefulWidget {
  const NotifyPage({super.key});

  @override
  State<NotifyPage> createState() => _NotifyPageState();
}

class _NotifyPageState extends State<NotifyPage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Título y cuerpo son obligatorios')),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      final resp = await http.post(
        Uri.parse('http://localhost:3000/notify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'body': body}),
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Éxito: notificación enviada')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error ${resp.statusCode}: ${resp.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Admin - Notificaciones')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Título'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Escribe el título',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Cuerpo'),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _bodyController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Escribe el cuerpo del mensaje',
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : _send,
                child: Text(_sending ? 'Enviando...' : 'Enviar notificación'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
