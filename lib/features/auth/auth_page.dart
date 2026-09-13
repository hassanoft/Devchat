import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final username = TextEditingController();
  bool signup = false;
  bool loading = false;

  Future<void> submit() async {
    setState(() => loading = true);
    try {
      final auth = Supabase.instance.client.auth;
      if (signup) {
        await auth.signUp(
          email: email.text.trim(),
          password: password.text,
          data: {'username': username.text.trim()},
        );
      } else {
        await auth.signInWithPassword(email: email.text.trim(), password: password.text);
      }
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const _AuthDone()));
    } on AuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  Image.asset('assets/icon.png', width: 100, height: 100),
                  const SizedBox(height: 14),
                  Text('DevChat', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Code • Discuss • Build', style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 28),
                  if (signup)
                    TextField(controller: username, decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.alternate_email), border: OutlineInputBorder())),
                  if (signup) const SizedBox(height: 12),
                  TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder())),
                  const SizedBox(height: 18),
                  SizedBox(width: double.infinity, height: 52, child: FilledButton(onPressed: loading ? null : submit, child: loading ? const CircularProgressIndicator() : Text(signup ? 'Créer mon compte' : 'Se connecter'))),
                  const SizedBox(height: 10),
                  TextButton(onPressed: loading ? null : () => setState(() => signup = !signup), child: Text(signup ? 'J’ai déjà un compte' : 'Créer un compte')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthDone extends StatelessWidget {
  const _AuthDone();
  @override
  Widget build(BuildContext context) => const HomePage();
}
