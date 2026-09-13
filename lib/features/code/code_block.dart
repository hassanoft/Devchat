import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

class CodeBlock extends StatelessWidget {
  const CodeBlock({super.key, required this.code, required this.language, this.filename});

  final String code;
  final String language;
  final String? filename;

  @override
  Widget build(BuildContext context) {
    final lang = language == 'js' ? 'javascript' : language;
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF282C34), borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              Expanded(child: Text(filename?.isNotEmpty == true ? filename! : language.toUpperCase(), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
              IconButton(
                tooltip: 'Copier',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: code));
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copié')));
                },
                icon: const Icon(Icons.copy, color: Colors.white70, size: 19),
              ),
            ]),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: HighlightView(
              code,
              language: lang,
              theme: atomOneDarkTheme,
              padding: EdgeInsets.zero,
              textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
