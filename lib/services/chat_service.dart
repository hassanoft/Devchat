import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  ChatService(this.client);

  final SupabaseClient client;

  String get userId => client.auth.currentUser!.id;

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final result = await client
        .from('profiles')
        .select('id, username, bio, skills')
        .neq('id', userId)
        .ilike('username', '%${query.trim()}%')
        .order('username')
        .limit(50);

    return List<Map<String, dynamic>>.from(result);
  }

  Future<List<Map<String, dynamic>>> recentUsers() async {
    final result = await client
        .from('profiles')
        .select('id, username, bio, skills')
        .neq('id', userId)
        .order('username')
        .limit(50);

    return List<Map<String, dynamic>>.from(result);
  }

  Future<void> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    final text = content.trim();
    if (text.isEmpty) return;

    await client.from('messages').insert({
      'sender_id': userId,
      'receiver_id': receiverId,
      'content': text,
    });
  }

  Stream<List<Map<String, dynamic>>> messages(String otherUserId) {
    final stream = client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at');

    return stream.map(
      (rows) => rows.where((row) {
        final sender = row['sender_id'] as String?;
        final receiver = row['receiver_id'] as String?;
        return (sender == userId && receiver == otherUserId) ||
            (sender == otherUserId && receiver == userId);
      }).toList(),
    );
  }
}
