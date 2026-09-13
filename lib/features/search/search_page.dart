import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;

  bool _loading = false;
  String? _error;

  List<Map<String, dynamic>> _profiles = [];
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _communities = [];

  bool get _hasQuery => _controller.text.trim().isNotEmpty;
  bool get _hasResults =>
      _profiles.isNotEmpty || _groups.isNotEmpty || _communities.isNotEmpty;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(value.trim());
    });
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _profiles = [];
        _groups = [];
        _communities = [];
        _error = null;
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final client = Supabase.instance.client;
      final pattern = '%$query%';

      final results = await Future.wait([
        // Profils : recherche sur username OU bio
        client
            .from('profiles')
            .select('id, username, bio, avatar_url, skills')
            .or('username.ilike.$pattern,bio.ilike.$pattern')
            .limit(20),
        // Groupes : recherche sur name OU description
        client
            .from('groups')
            .select('id, name, description, owner_id, community_id')
            .or('name.ilike.$pattern,description.ilike.$pattern')
            .limit(20),
        // Communautés : recherche sur name OU description
        client
            .from('communities')
            .select('id, name, description, owner_id')
            .or('name.ilike.$pattern,description.ilike.$pattern')
            .limit(20),
      ]);

      if (!mounted) return;
      setState(() {
        _profiles = List<Map<String, dynamic>>.from(results[0] as List);
        _groups = List<Map<String, dynamic>>.from(results[1] as List);
        _communities = List<Map<String, dynamic>>.from(results[2] as List);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recherche')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Développeur, groupe, communauté…',
                border: const OutlineInputBorder(),
                suffixIcon: _hasQuery
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _search('');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Erreur : $_error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (!_hasQuery) {
      return const Center(
        child: Text(
          'Tape un mot-clé pour lancer la recherche.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    if (!_hasResults) {
      return const Center(
        child: Text('Aucun résultat.', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView(
      children: [
        if (_profiles.isNotEmpty) ...[
          _sectionTitle('Développeurs', _profiles.length),
          ..._profiles.map(_profileTile),
        ],
        if (_groups.isNotEmpty) ...[
          _sectionTitle('Groupes', _groups.length),
          ..._groups.map(_groupTile),
        ],
        if (_communities.isNotEmpty) ...[
          _sectionTitle('Communautés', _communities.length),
          ..._communities.map(_communityTile),
        ],
      ],
    );
  }

  Widget _sectionTitle(String text, int count) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(
          children: [
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 6),
            Text(
              '($count)',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );

  // ---------------------------------------------------------------
  // Profil
  // ---------------------------------------------------------------
  Widget _profileTile(Map<String, dynamic> p) {
    final username = (p['username'] as String?) ?? 'Inconnu';
    final avatar = p['avatar_url'] as String?;
    final bio = (p['bio'] as String?) ?? '';
    final skills = (p['skills'] as List?)?.cast<String>() ?? const [];

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: (avatar != null && avatar.isNotEmpty)
            ? NetworkImage(avatar)
            : null,
        child: (avatar == null || avatar.isEmpty)
            ? Text(username.substring(0, 1).toUpperCase())
            : null,
      ),
      title: Text(username),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bio.isNotEmpty)
            Text(bio, maxLines: 2, overflow: TextOverflow.ellipsis),
          if (skills.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: skills
                    .take(5)
                    .map((s) => Chip(
                          label: Text(s, style: const TextStyle(fontSize: 11)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
      isThreeLine: bio.isNotEmpty || skills.isNotEmpty,
      onTap: () {
        // TODO: naviguer vers la page profil
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (_) => ProfilePage(userId: p['id'] as String),
        // ));
      },
    );
  }

  // ---------------------------------------------------------------
  // Groupe
  // ---------------------------------------------------------------
  Widget _groupTile(Map<String, dynamic> g) {
    final name = (g['name'] as String?) ?? 'Groupe';
    final description = (g['description'] as String?) ?? '';
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.groups)),
      title: Text(name),
      subtitle: description.isNotEmpty
          ? Text(description, maxLines: 2, overflow: TextOverflow.ellipsis)
          : null,
      onTap: () {
        // TODO: naviguer vers la page groupe
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (_) => GroupPage(groupId: g['id'] as String),
        // ));
      },
    );
  }

  // ---------------------------------------------------------------
  // Communauté
  // ---------------------------------------------------------------
  Widget _communityTile(Map<String, dynamic> c) {
    final name = (c['name'] as String?) ?? 'Communauté';
    final description = (c['description'] as String?) ?? '';
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.public)),
      title: Text(name),
      subtitle: description.isNotEmpty
          ? Text(description, maxLines: 2, overflow: TextOverflow.ellipsis)
          : null,
      onTap: () {
        // TODO: naviguer vers la page communauté
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (_) => CommunityPage(communityId: c['id'] as String),
        // ));
      },
    );
  }
}