// Admin panel (web). Run with: flutter run -d chrome -t lib/main_admin.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'admin/login_page.dart';
import 'admin/painel_page.dart';
import 'firebase_options.dart';
import 'shared/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(
    title: 'Painel — Circuito de Descobertas',
    debugShowCheckedModeBanner: false,
    theme: tema(Brightness.light),
    darkTheme: tema(Brightness.dark),
    home: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) => snap.data == null ? const LoginPage() : const PainelPage(),
    ),
  ));
}
