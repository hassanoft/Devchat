import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final username = user?.userMetadata?['username']?.toString() ?? 'developer';
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const CircleAvatar(radius: 44, child: Icon(Icons.person, size: 44)),
        const SizedBox(height: 12),
        Center(child: Text('@$username', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
        const SizedBox(height: 6),
        Center(child: Text(user?.email ?? '', style: TextStyle(color: Colors.grey.shade700))),
        const SizedBox(height: 25),
        const Text('Compétences', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: const [Chip(label: Text('Flutter')), Chip(label: Text('Dart')), Chip(label: Text('JavaScript')), Chip(label: Text('Python'))]),
        const SizedBox(height: 20),
        ListTile(leading: const Icon(Icons.link), title: const Text('GitHub'), subtitle: const Text('Ajouter mon profil GitHub'), onTap: () {}),
        ListTile(leading: const Icon(Icons.language), title: const Text('Portfolio'), subtitle: const Text('Ajouter mon portfolio'), onTap: () {}),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: () async { await Supabase.instance.client.auth.signOut(); if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst); }, icon: const Icon(Icons.logout), label: const Text('Se déconnecter')),
      ]),
    );
  }
}
