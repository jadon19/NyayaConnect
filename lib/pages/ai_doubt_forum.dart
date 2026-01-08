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
  
  /// Stores conversation history: [{"role": "user", "content": "..."}, {"role": "assistant", "content": "..."}]
  final List<Map<String, String>> _messages = [];
  
  bool _isLoading = false;

  /// 🔹 Ask NyayaAI (GitHub Models → OpenAI o4-mini)
  Future<void> _askAI() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      // Add user message to UI immediately
      _messages.add({"role": "user", "content": query});
      _isLoading = true;
    });
    
    _controller.clear();
    _scrollToBottom();

    final githubToken = dotenv.env['GITHUB_TOKEN'];

    if (githubToken == null || githubToken.isEmpty) {
      setState(() {
        _messages.add({
          "role": "model", 
          "content": "⚠️ Missing GITHUB_TOKEN. Please check your .env file."
        });
        _isLoading = false;
      });
      _scrollToBottom();
      return;
    }

    try {
      // Construct the full conversation history for context
      final List<Map<String, dynamic>> apiMessages = [
        {
          "role": "developer", // or "system" depending on the model
          "content": """
You are NyayaAI, an expert in Indian Law.

Rules:
1. Answer ONLY Indian law-related questions.
2. If the question is not related to Indian law, politely decline.
3. Mention relevant IPC / CrPC / Constitution sections when applicable.
4. Give clear explanations with examples.
5. If unsure, say that a licensed advocate should be consulted.
"""
        },
        // Map internal history format to API format
        ..._messages.map((m) => {
          "role": m["role"] == "user" ? "user" : "assistant",
          "content": m["content"]
        }),
      ];

      final res = await http
          .post(
        Uri.parse(
          "https://models.github.ai/inference/chat/completions",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $githubToken",
        },
        body: jsonEncode({
          "model": "openai/gpt-4o-mini",
          "messages": apiMessages,
        }),
      )
          .timeout(const Duration(seconds: 25));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final reply = data["choices"]?[0]?["message"]?["content"] ??
            "⚠️ No response from model.";

        setState(() {
          _messages.add({"role": "model", "content": reply});
        });
      } else {
        setState(() {
          _messages.add({
            "role": "model", 
            "content": "⚠️ GitHub Models Error ${res.statusCode}\n\n${res.body}"
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({"role": "model", "content": "⚠️ Exception: $e"});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 🔹 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Subtle light grey background
      body: Column(
        children: [
          /// 🔵 Gradient Header
          const SimpleGradientHeader(
            title: "AI Doubt Forum",
          ),

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
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        // Loading indicator
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 16,
                              child: Icon(Icons.psychology, size: 18, color: Color(0xFF1976D2)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: 40,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildDot(0),
                                    _buildDot(0.2),
                                    _buildDot(0.4),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      final msg = _messages[index];
                      final isUser = msg['role'] == 'user';

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
