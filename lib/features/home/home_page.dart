import 'package:flutter/material.dart';
import '../chat/chat_page.dart';
import '../groups/groups_page.dart';
import '../communities/communities_page.dart';
import '../profile/profile_page.dart';
import '../search/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  final pages = const [ChatPage(), GroupsPage(), CommunitiesPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      floatingActionButton: index == 0 ? FloatingActionButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage())), child: const Icon(Icons.search)) : null,
      bottomNavigationBar: NavigationBar(selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v), destinations: const [NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'), NavigationDestination(icon: Icon(Icons.group_outlined), selectedIcon: Icon(Icons.group), label: 'Groupes'), NavigationDestination(icon: Icon(Icons.public), label: 'Communautés'), NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil')]),
    );
  }
}
