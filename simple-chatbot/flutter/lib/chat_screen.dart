import 'package:flutter/material.dart';
import 'package:genkit/client.dart';
import 'package:uuid/uuid.dart';

class _ChatService {
  String _sessionId = const Uuid().v4();
  String _backend = 'nodejs';
  String get _backendUrl =>
      _backend == 'nodejs' ? 'http://localhost:3000' : 'http://localhost:3001';

  RemoteAction<GenerateResponse, GenerateResponseChunk> get chatFlow =>
      defineRemoteAction(
        url: '$_backendUrl/flows/chat',
        fromResponse: (json) => GenerateResponse.fromJson(json),
        fromStreamChunk: (json) => GenerateResponseChunk.fromJson(json),
      );

  RemoteAction<List<Message>, void> get historyFlow =>
      defineRemoteAction(
        url: '$_backendUrl/flows/getHistory',
        fromResponse: (json) =>
            (json as List).map((i) => Message.fromJson(i)).toList(),
      );

  void setBackend(String backend) {
    _backend = backend;
  }

  void startNewConversation() {
    _sessionId = const Uuid().v4();
  }

  Future<List<Message>> getHistory() async {
    return await historyFlow(input: {'sessionId': _sessionId});
  }

  Stream<GenerateResponseChunk> sendMessage(String message) {
    return chatFlow.stream(input: {
      'sessionId': _sessionId,
      'message': message,
    });
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = _ChatService();
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
    });
    try {
      final history = await _chatService.getHistory();
      setState(() {
        _messages.clear();
        _messages.addAll(history);
      });
    } on GenkitException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error loading history: ${e.message}'),
      ));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Chatbot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _startNewConversation,
            tooltip: 'New Conversation',
          ),
          PopupMenuButton<String>(
            onSelected: (String result) {
              _chatService.setBackend(result);
              _loadHistory();
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'nodejs',
                child: Text('Node.js'),
              ),
              const PopupMenuItem<String>(
                value: 'go',
                child: Text('Go'),
              ),
            ],
            icon: const Icon(Icons.computer),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUserMessage = message.role == Role.user;
                return Container(
                  alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUserMessage ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildMessageContent(message),
                  ),
                );
              },
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startNewConversation() {
    _chatService.startNewConversation();
    setState(() {
      _messages.clear();
    });
  }

  Widget _buildMessageContent(Message message) {
    final parts = message.content;
    if (parts == null || parts.isEmpty) {
      return const SizedBox.shrink();
    }
    final textParts = parts.whereType<TextPart>().map((p) => p.text ?? '').join();
    final otherParts = parts.where((p) => p is! TextPart);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (textParts.isNotEmpty) Text(textParts),
        ...otherParts.map((part) {
          if (part is ToolRequestPart) {
            return _ToolPartWidget(
              title: 'Tool: ${part.toolRequest?.name ?? ''}',
              content: part.toolRequest?.input.toString() ?? '',
              color: Colors.grey[300]!,
            );
          }
          if (part is ToolResponsePart) {
            return _ToolPartWidget(
              title: 'Tool response:',
              content: part.toolResponse?.output.toString() ?? '',
              color: Colors.green[100]!,
            );
          }
          return const SizedBox.shrink();
        }).toList(),
      ],
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text;
    if (text.isEmpty) return;

    final userMessage = Message(
      role: Role.user,
      content: [TextPart(text: text)],
    );

    setState(() {
      _messages.add(userMessage);
      _controller.clear();
      _loading = true;
    });

    try {
      final stream = _chatService.sendMessage(text);

      int initialMessagesCount = _messages.length;

      await for (final chunk in stream) {
        setState(() {
          _loading = false;
          final chunkIndex = chunk.index ?? 0;
          final targetIndex = initialMessagesCount + chunkIndex.toInt();

          if (targetIndex < _messages.length) {
            // Append to existing message
            final existingMessage = _messages[targetIndex];
            final existingContent = existingMessage.content ?? [];
            final lastPart = existingContent.isNotEmpty ? existingContent.last : null;
            final newPart = chunk.content?.isNotEmpty == true ? chunk.content!.first : null;

            if (lastPart is TextPart && newPart is TextPart) {
              final updatedPart = TextPart(text: (lastPart.text ?? '') + (newPart.text ?? ''));
              final updatedContent = [...existingContent.sublist(0, existingContent.length - 1), updatedPart];
               _messages[targetIndex] = Message(role: existingMessage.role, content: updatedContent);
            } else {
              final updatedContent = [...existingContent, ...?chunk.content];
              _messages[targetIndex] = Message(role: existingMessage.role, content: updatedContent);
            }
          } else {
            // Create new message
            _messages.add(Message(
              role: chunk.role ?? Role.model,
              content: chunk.content,
            ));
          }
        });
      }
      if (_loading) {
        setState(() {
          _loading = false;
        });
      }
    } on GenkitException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.message}'),
      ));
      setState(() {
        _loading = false;
      });
    }
  }
}

class _ToolPartWidget extends StatelessWidget {
  final String title;
  final String content;
  final Color color;

  const _ToolPartWidget({
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(content),
        ],
      ),
    );
  }
}
