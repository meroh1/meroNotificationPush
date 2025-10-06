import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// Background handler para mensajes FCM cuando la app está en segundo plano o terminada.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Solicita permisos de notificación cuando aplica (Android 13+, iOS/macOS/web)
  final messaging = FirebaseMessaging.instance;
  try {
    await messaging.requestPermission();
  } catch (_) {}

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mero Notification',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const MessagingHomePage(),
    );
  }
}

class MessagingHomePage extends StatefulWidget {
  const MessagingHomePage({super.key});

  @override
  State<MessagingHomePage> createState() => _MessagingHomePageState();
}

class _MessagingHomePageState extends State<MessagingHomePage> {
  String? _registrationToken;
  RemoteMessage? _lastForegroundMessage;
  String _permissionStatus = 'unknown';

  @override
  void initState() {
    super.initState();
    _initMessaging();
  }

  Future<void> _initMessaging() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission();
    setState(() {
      _permissionStatus = settings.authorizationStatus.name;
    });

    final token = await messaging.getToken();
    setState(() {
      _registrationToken = token;
    });

    FirebaseMessaging.onMessage.listen((message) {
      setState(() {
        _lastForegroundMessage = message;
      });
      if (!mounted) return;
      final notification = message.notification;
      final title = notification?.title ?? 'Mensaje FCM';
      final body = notification?.body ?? 'Recibido en foreground';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$title — $body')));
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      setState(() {
        _lastForegroundMessage = message;
      });
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      setState(() {
        _lastForegroundMessage = initialMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Cloud Messaging')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Token de registro FCM',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(_registrationToken ?? 'Obteniendo token...'),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final token = await FirebaseMessaging.instance.getToken();
                    setState(() => _registrationToken = token);
                  },
                  child: const Text('Refrescar token'),
                ),
                const SizedBox(width: 12),
                if (Platform.isAndroid)
                  ElevatedButton(
                    onPressed: () async {
                      final settings =
                          await FirebaseMessaging.instance.requestPermission();
                      setState(() {
                        _permissionStatus = settings.authorizationStatus.name;
                      });
                    },
                    child: const Text('Solicitar permiso'),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Último mensaje recibido en foreground',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _lastForegroundMessage == null
                  ? '—'
                  : '${_lastForegroundMessage!.notification?.title ?? '(sin título)'}\n${_lastForegroundMessage!.notification?.body ?? '(sin cuerpo)'}\nData: ${_lastForegroundMessage!.data}',
            ),
            const SizedBox(height: 24),
            Text('Estado de permiso: $_permissionStatus'),
          ],
        ),
      ),
    );
  }
}
