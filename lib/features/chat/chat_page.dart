import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import '../code/code_block.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.conversationId, this.title = 'DevChat'});
  final String? conversationId;
  final String title;
  @override State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final service = ChatService();
  final controller = TextEditingController();
  String language = 'dart';
  bool codeMode = false;

  Future<void> send() async {
    final text = controller.text;
    controller.clear();
    if (codeMode) {
      await service.sendCode(code: text, language: language, conversationId: widget.conversationId);
    } else {
      await service.sendText(text, conversationId: widget.conversationId);
    }
  }

  @override void dispose() { controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(children: [
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: service.messages(conversationId: widget.conversationId),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Erreur: ${snapshot.error}'));
              final rows = snapshot.data ?? const [];
              if (rows.isEmpty) return const Center(child: Text('Aucun message. Sois le premier à écrire !'));
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: rows.length,
                itemBuilder: (_, i) {
                  final row = rows[i];
                  final isMe = row['sender_id'] == service.userId;
                  final type = row['message_type'] as String? ?? 'text';
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 380),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: type == 'code'
                          ? CodeBlock(code: row['content'] ?? '', language: row['code_language'] ?? 'plaintext', filename: row['code_filename'])
                          : DecoratedBox(decoration: BoxDecoration(color: isMe ? const Color(0xFFD7F8E8) : Colors.white, borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(13), child: Text(row['content'] ?? ''))),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              IconButton.filledTonal(onPressed: () => setState(() => codeMode = !codeMode), icon: Icon(codeMode ? Icons.chat_bubble_outline : Icons.code)),
              const SizedBox(width: 8),
              Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (codeMode) DropdownButtonFormField<String>(initialValue: language, items: const ['dart','javascript','typescript','python','java','cpp','c','html','css','json','sql','bash'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => language = v ?? 'dart'), decoration: const InputDecoration(labelText: 'Langage', isDense: true, border: OutlineInputBorder())),
                if (codeMode) const SizedBox(height: 7),
                TextField(controller: controller, maxLines: codeMode ? 6 : 3, minLines: 1, decoration: InputDecoration(hintText: codeMode ? 'Colle ton code…' : 'Écrire un message…', border: const OutlineInputBorder(), suffixIcon: IconButton(onPressed: send, icon: const Icon(Icons.send)))),
              ])),
            ]),
          ),
        ),
      ]),
    );
  }
}
