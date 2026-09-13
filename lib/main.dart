import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const url = String.fromEnvironment('SUPABASE_URL');
  const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  if (url.isEmpty || key.isEmpty) {
    runApp(const MissingConfigApp());
    return;
  }

  await Supabase.initialize(url: url, publishableKey: key);
  runApp(const DevChatApp());
}

class MissingConfigApp extends StatelessWidget {
  const MissingConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF00E676)),
      home: const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'DevChat\n\nSupabase n’est pas configuré.\nAjoute SUPABASE_URL et SUPABASE_PUBLISHABLE_KEY avec --dart-define.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
