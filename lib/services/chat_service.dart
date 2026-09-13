import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient client = Supabase.instance.client;

  String get userId => client.auth.currentUser!.id;

  Stream<List<Map<String, dynamic>>> messages({String? conversationId}) {
    return client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((rows) => rows.where((row) => row['deleted_at'] == null && (conversationId == null || row['conversation_id'] == conversationId)).toList());
  }

  Future<void> sendText(String text, {String? conversationId}) async {
    if (text.trim().isEmpty) return;
    await client.from('messages').insert({
      'sender_id': userId,
      'conversation_id': conversationId,
      'content': text.trim(),
      'message_type': 'text',
    });
  }

  Future<void> sendCode({required String code, required String language, String? filename, String? conversationId}) async {
    if (code.trim().isEmpty) return;
    await client.from('messages').insert({
      'sender_id': userId,
      'conversation_id': conversationId,
      'content': code,
      'message_type': 'code',
      'code_language': language,
      'code_filename': filename?.trim().isEmpty == true ? null : filename?.trim(),
    });
  }
}
