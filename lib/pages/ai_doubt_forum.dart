import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../widgets/simple_gradient_header.dart';

class AIDoubtForumPage extends StatefulWidget {
  const AIDoubtForumPage({super.key});

  @override
  State<AIDoubtForumPage> createState() => _AIDoubtForumPageState();
}

class _AIDoubtForumPageState extends State<AIDoubtForumPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final http.Client _client;
  bool _isLoading = false;
  String? _githubToken;
  late final Uri _apiUri;
  late final Map<String, String> _apiHeaders;
  
  // 🔘 Model Choice: Fixed to your preferred GPT-4o Mini
  final String _selectedModel = "openai/gpt-4o-mini";

  @override
  void initState() {
    super.initState();
    _client = http.Client();
    _githubToken = dotenv.env['GITHUB_TOKEN'];
    _apiUri = Uri.parse("https://models.github.ai/inference/chat/completions");
    _apiHeaders = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $_githubToken",
      "Connection": "keep-alive",
    };
    
    // 🌡️ Warm up the connection immediately!
    _warmUpConnection();
  }

  void _warmUpConnection() {
    if (_githubToken == null) return;
    _client.post(
      _apiUri,
      headers: _apiHeaders,
      body: jsonEncode({
        "model": _selectedModel,
        "messages": [{"role": "user", "content": "."}],
        "max_tokens": 1,
      }),
    ).ignore();
  }

  @override
  void dispose() {
    _client.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  /// Stores conversation history
  final List<Map<String, dynamic>> _messages = [];

  /// 🔹 Ask NyayaAI (GitHub Models → GPT-4o Mini)
  Future<void> _askAI() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    // Start timer at the absolute first millisecond of interaction
    final stopwatch = Stopwatch()..start();

    setState(() {
      _messages.add({"role": "user", "content": query});
      _messages.add({"role": "model", "content": "..."});
      _isLoading = true;
    });
    
    _controller.clear();
    _scrollToBottom();

    if (_githubToken == null || _githubToken!.isEmpty) {
      setState(() {
        _messages.last["content"] = "⚠️ Missing GITHUB_TOKEN.";
        _isLoading = false;
      });
      return;
    }

    try {
      // ⚡ RE-ENABLED System prompt with 'system' role for better intelligence
      final List<Map<String, dynamic>> apiMessages = [
        {"role": "system", "content": "Indian Law Expert"}
      ];

      // Minimal context: just the last 2 messages
      if (_messages.length >= 4) {
        final lastUser = _messages[_messages.length - 4];
        final lastModel = _messages[_messages.length - 3];
        if (lastUser['content'] != null && lastUser['content'] != '...') 
          apiMessages.add({"role": "user", "content": lastUser['content']!});
        if (lastModel['content'] != null && lastModel['content'] != '...') 
          apiMessages.add({"role": "assistant", "content": lastModel['content']!});
      }

      apiMessages.add({"role": "user", "content": query});

      final request = http.Request('POST', _apiUri)
        ..headers.addAll(_apiHeaders)
        ..followRedirects = false // Fast path
        ..body = jsonEncode({
          "model": _selectedModel, // Use dynamic model
          "messages": apiMessages,
          "temperature": 0,
          "stream": true,
        });

      // Start network timer
      final requestSentStopwatch = Stopwatch()..start();
      final streamedResponse = await _client.send(request).timeout(const Duration(seconds: 10));
      final networkRttMs = requestSentStopwatch.elapsedMilliseconds;

      if (streamedResponse.statusCode != 200) {
        final body = await streamedResponse.stream.transform(utf8.decoder).join();
        setState(() => _messages.last["content"] = "⚠️ API Error: $body");
        return;
      }

      bool isFirstChunk = true;
      String buffer = "";

      // 🚀 Ultra-fast raw stream processing (skips LineSplitter overhead)
      await for (final dataChunk in streamedResponse.stream.transform(utf8.decoder)) {
        buffer += dataChunk;
        
        final lines = buffer.split('\n');
        buffer = lines.last; // Keep partial line for next chunk

        for (int i = 0; i < lines.length - 1; i++) {
          final line = lines[i].trim();
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6).trim();
            if (jsonStr == '[DONE]') continue;

            try {
              final json = jsonDecode(jsonStr);
              final chunk = json['choices']?[0]?['delta']?['content'];
              
              if (chunk != null && chunk.isNotEmpty) {
                setState(() {
                  if (isFirstChunk) {
                  stopwatch.stop();
                  final totalMs = stopwatch.elapsedMilliseconds;
                  final aiThinkingMs = totalMs - networkRttMs;
                  
                  _messages.last["content"] = chunk;
                  _messages.last["latency"] = 
                    "${(totalMs / 1000).toStringAsFixed(2)}s (AI: ${(aiThinkingMs / 1000).toStringAsFixed(2)}s | Net: ${(networkRttMs / 1000).toStringAsFixed(2)}s)";
                  isFirstChunk = false;
                } else {
                    _messages.last["content"] = (_messages.last["content"] ?? "") + chunk;
                  }
                });
                
                if (_messages.last["content"]!.length % 40 == 0) _scrollToBottom();
              }
            } catch (_) {}
          }
        }
      }
      
    } catch (e) {
      setState(() {
        _messages.last["content"] = "⚠️ Exception: $e";
      });
    } finally {
      // Do NOT close the persistent client here
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  /// 🔹 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          /// 🔵 Gradient Header
          const SimpleGradientHeader(
            title: "AI Doubt Forum",
          ),

          // Comparison chips removed to keep it lean

          /// 💬 Chat List
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.psychology, size: 64, color: Color(0xFF1976D2)),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'NyayaAI Legal Assistant',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Ask any question regarding Indian Law.\nI can explain sections of IPC, CrPC, and more.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 20, bottom: 20, left: 16, right: 16),
                    itemCount: _messages.length, // Removed extra loader item
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg['role'] == 'user';
                      final content = msg['content'] ?? '';


                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isUser) ...[
                              const CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 18,
                                child: Icon(Icons.psychology, size: 20, color: Color(0xFF1976D2)),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: isUser
                                      ? const LinearGradient(
                                          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isUser ? null : Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(20),
                                    topRight: const Radius.circular(20),
                                    bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                                    bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg['content'] ?? '',
                                      style: TextStyle(
                                        color: isUser ? Colors.white : Colors.black87,
                                        fontSize: 16,
                                        height: 1.5,
                                      ),
                                    ),
                                    if (msg.containsKey('latency') && !isUser) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        "Response time: ${msg['latency']}",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade500,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                    if (!isUser) ...[
                                      const SizedBox(height: 10),
                                      const Divider(height: 1, color: Colors.black12),
                                      const SizedBox(height: 6),
                                      InkWell(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(text: msg['content'] ?? ''));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Response copied to clipboard'),
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              backgroundColor: Colors.black87,
                                              duration: const Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.copy_rounded, size: 14, color: Colors.grey.shade600),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Copy Response",
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          /// 🔍 Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _askAI(),
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.black45),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: _isLoading ? null : _askAI,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(double delay) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.black54.withOpacity((value + delay).clamp(0.2, 1.0) % 1.0),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
