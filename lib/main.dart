import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // Vérification de la configuration
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    runApp(const MissingConfigApp());
    return;
  }

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );

    runApp(const DevChatApp());
  } catch (e) {
    runApp(
      SupabaseErrorApp(
        error: e.toString(),
      ),
    );
  }
}

class MissingConfigApp extends StatelessWidget {
  const MissingConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF00E676),
      ),
      home: const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'DevChat\n\n'
              'Supabase n’est pas configuré.\n\n'
              'Vérifie que SUPABASE_URL et '
              'SUPABASE_ANON_KEY sont transmis '
              'avec --dart-define.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class SupabaseErrorApp extends StatelessWidget {
  const SupabaseErrorApp({
    super.key,
    required this.error,
  });

  final String error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF00E676),
      ),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Erreur de connexion à Supabase',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  error,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}