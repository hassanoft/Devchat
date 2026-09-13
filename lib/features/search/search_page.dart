import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Recherche')), body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Développeur, groupe, communauté…', border: OutlineInputBorder())), const SizedBox(height: 24), const Text('Recherche globale disponible dans la prochaine couche Supabase.')]));
}
