import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunitiesPage extends StatefulWidget {
  const CommunitiesPage({super.key});
  @override State<CommunitiesPage> createState() => _CommunitiesPageState();
}

class _CommunitiesPageState extends State<CommunitiesPage> {
  final client = Supabase.instance.client;

  Future<void> _create() async {
    final name=TextEditingController(); final desc=TextEditingController();
    final ok=await showDialog<bool>(context: context,builder:(_)=>AlertDialog(title:const Text('Nouvelle communauté'),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:name,decoration:const InputDecoration(labelText:'Nom')),TextField(controller:desc,decoration:const InputDecoration(labelText:'Description'))]),actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('Annuler')),FilledButton(onPressed:()=>Navigator.pop(context,true),child:const Text('Créer'))]));
    if(ok!=true||name.text.trim().isEmpty)return;
    final row=await client.from('communities').insert({'name':name.text.trim(),'description':desc.text.trim(),'owner_id':client.auth.currentUser!.id}).select('id').single();
    await client.from('community_members').insert({'community_id':row['id'],'user_id':client.auth.currentUser!.id,'role':'admin'});
    if(mounted)setState((){});
  }

  Future<void> _join(String id) async { await client.from('community_members').upsert({'community_id':id,'user_id':client.auth.currentUser!.id,'role':'member'}); if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Communauté rejointe'))); }

  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Communautés')),floatingActionButton:FloatingActionButton.extended(onPressed:_create,icon:const Icon(Icons.add),label:const Text('Créer')),body:FutureBuilder<List<Map<String,dynamic>>>(future:client.from('communities').select().order('created_at',ascending:false),builder:(context,snap){if(snap.hasError)return Center(child:Text('Erreur: ${snap.error}'));final rows=snap.data??[];if(rows.isEmpty)return const Center(child:Text('Aucune communauté pour le moment.'));return ListView.builder(padding:const EdgeInsets.all(10),itemCount:rows.length,itemBuilder:(_,i){final r=rows[i];return Card(child:ListTile(contentPadding:const EdgeInsets.all(14),leading:const CircleAvatar(radius:27,child:Icon(Icons.public)),title:Text(r['name']??'',style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text(r['description']??''),trailing:FilledButton(onPressed:()=>_join(r['id']),child:const Text('Rejoindre'))));});}));
}
