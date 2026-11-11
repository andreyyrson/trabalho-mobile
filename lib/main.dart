// Visitor app (Android). The admin panel lives in main_admin.dart.
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/home_page.dart';
import 'app/missao.dart';
import 'app/onboarding_page.dart';
import 'firebase_options.dart';
import 'shared/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // The anonymous session persists on the device, so "no session yet"
  // doubles as "first launch" without storing a separate flag.
  final primeiraVez = FirebaseAuth.instance.currentUser == null;
  if (primeiraVez) await FirebaseAuth.instance.signInAnonymously();
  // Don't block the first frame on the network; the list works with the mission off.
  unawaited(iniciarMissao());
  runApp(MaterialApp(
    title: 'Circuito de Descobertas',
    debugShowCheckedModeBanner: false,
    theme: tema(Brightness.light),
    darkTheme: tema(Brightness.dark),
    home: primeiraVez ? const OnboardingPage() : const HomePage(),
  ));
}
