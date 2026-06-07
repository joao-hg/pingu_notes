import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/note_provider.dart';
import '../widgets/pingu_brand.dart';

class AskPinguPage extends StatefulWidget {
  const AskPinguPage({super.key});

  @override
  State<AskPinguPage> createState() => _AskPinguPageState();
}

class _AskPinguPageState extends State<AskPinguPage> {
  final TextEditingController _queryController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  void _sendMessage() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': query});
      _queryController.clear();
      _isTyping = true;
    });

    final response = await context.read<NoteProvider>().chatWithNotes(query);

    setState(() {
      _messages.add({'role': 'pingu', 'text': response});
      _isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💬 Pergunte ao Pingu'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const _AskPinguEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _ChatMessage(
                        text: msg['text']!,
                        isUser: msg['role'] == 'user',
                      );
                    },
                  ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Pingu está pensando...', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            ),
          _ChatInput(
            controller: _queryController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const _ChatMessage({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppColors.deepOceanBlue : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : null,
            bottomLeft: !isUser ? const Radius.circular(0) : null,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : null),
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Pergunte qualquer coisa sobre suas notas...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: AppColors.deepOceanBlue),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}

class _AskPinguEmptyState extends StatelessWidget {
  const _AskPinguEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const PinguMascot(size: 120),
            const SizedBox(height: 24),
            Text(
              'Olá! Eu sou o Pingu.',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Posso te ajudar a encontrar conexões e resumir o que você já sabe.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
