import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/auth_page.dart';
import '../features/home/home_page.dart';

class DevChatApp extends StatelessWidget {
  const DevChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00D97E)),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
      ),
      home: const SessionGate(),
    );
  }
}

class SessionGate extends StatelessWidget {
  const SessionGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return const AuthPage();
    return const HomePage();
  }
}
