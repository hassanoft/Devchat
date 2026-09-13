import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../chat/chat_page.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});
  @override State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final client = Supabase.instance.client;

  Future<void> _create() async {
    final name = TextEditingController();
    final description = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Nouveau groupe'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'Nom')), TextField(controller: description, decoration: const InputDecoration(labelText: 'Description'))]), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Créer'))]));
    if (ok != true || name.text.trim().isEmpty) return;
    final row = await client.from('groups').insert({'name': name.text.trim(), 'description': description.text.trim(), 'owner_id': client.auth.currentUser!.id}).select('id').single();
    await client.from('group_members').insert({'group_id': row['id'], 'user_id': client.auth.currentUser!.id, 'role': 'admin'});
    if (mounted) setState(() {});
  }

  Future<void> _join(String id) async {
    await client.from('group_members').upsert({'group_id': id, 'user_id': client.auth.currentUser!.id, 'role': 'member'});
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Groupes')), floatingActionButton: FloatingActionButton.extended(onPressed: _create, icon: const Icon(Icons.add), label: const Text('Créer')), body: FutureBuilder<List<Map<String,dynamic>>>(future: client.from('groups').select().order('created_at', ascending: false), builder: (context, snap) { if (snap.hasError) return Center(child: Text('Erreur: ${snap.error}')); final rows=snap.data??[]; if(rows.isEmpty)return const Center(child: Text('Aucun groupe pour le moment.')); return ListView.builder(itemCount: rows.length,itemBuilder:(_,i){final r=rows[i]; return ListTile(leading: const CircleAvatar(child: Icon(Icons.group)), title: Text(r['name']??''), subtitle: Text(r['description']??''), trailing: const Icon(Icons.chevron_right), onTap: () async { await _join(r['id']); if(context.mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(conversationId: r['id'], title: r['name']??'Groupe'))); });}); }));
  }
}
