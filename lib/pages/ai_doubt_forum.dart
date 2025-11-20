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

  /// 🔹 Combined Indian Kanoon + OpenAI logic
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
        _response = "⚠️ Missing OpenAI API Key. Please check your .env file.";
        _isLoading = false;
      });
      _scrollToBottom();
      return;
    }

    /// 1️⃣ Ask OpenAI for explanation
    Future<String?> askOpenAI() async {
      try {
        final res = await http
            .post(
          Uri.parse("https://api.openai.com/v1/chat/completions"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $openAiKey",
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages": [
              {
                "role": "system",
                "content":
                "You are an Indian legal expert. Explain IPC sections, constitutional articles, and Indian laws clearly, in plain English, with short summaries and examples."
              },
              {"role": "user", "content": query}
            ],
            "max_tokens": 500,
          }),
        )
            .timeout(const Duration(seconds: 20));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          return data['choices'][0]['message']['content'];
        } else {
          return "⚠️ OpenAI Error: ${res.statusCode}";
        }
      } catch (e) {
        return "⚠️ OpenAI Exception: $e";
      }
    }

    /// 2️⃣ Ask Indian Kanoon for case references
    Future<String?> askIndianKanoon() async {
      if (kanoonKey == null || kanoonKey.isEmpty) {
        return null;
      }

      try {
        String formattedQuery = query;
        if (query.toLowerCase().contains("ipc")) {
          final regex = RegExp(r'\d+');
          final match = regex.firstMatch(query);
          if (match != null) {
            formattedQuery = "Section ${match.group(0)} IPC";
          }
        }

        final res = await http
            .post(
          Uri.parse("https://api.indiankanoon.org/search/"),
          headers: {
            "Authorization": "Token $kanoonKey",
            "Content-Type": "application/x-www-form-urlencoded",
          },
          body: "formInput=${Uri.encodeComponent(formattedQuery)}",
        )
            .timeout(const Duration(seconds: 15));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['results'] != null && data['results'].isNotEmpty) {
            final cases = data['results']
                .take(3)
                .map((e) => "• ${e['title'] ?? 'Untitled Case'}")
                .join("\n");
            return "⚖️ *Top Indian Kanoon Cases:*\n$cases";
          } else {
            return "⚖️ No case references found on Indian Kanoon for this query.";
          }
        } else {
          return "⚖️ Indian Kanoon Error: ${res.statusCode}";
        }
      } catch (e) {
        return "⚖️ Indian Kanoon Exception: $e";
      }
    }

    try {
      // Fetch both in parallel
      final results = await Future.wait([
        askOpenAI(),
        askIndianKanoon(),
      ]);

      final aiResponse = results[0];
      final kanoonResponse = results[1];

      String finalResponse = "";

      if (aiResponse != null && aiResponse.isNotEmpty) {
        finalResponse += "🧠 *AI Summary:*\n$aiResponse\n\n";
      } else {
        finalResponse +=
        "⚠️ AI could not generate a response. Please try again later.\n\n";
      }

      if (kanoonResponse != null && kanoonResponse.isNotEmpty) {
        finalResponse += kanoonResponse;
      } else {
        finalResponse +=
        "⚖️ No case references found on Indian Kanoon for this query.";
      }

      setState(() => _response = finalResponse);
    } catch (e) {
      setState(() => _response = "⚠️ Unexpected error: $e");
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
      appBar: AppBar(
        title: const Text('AI Doubt Forum'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 Input Field
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _askAI(),
                decoration: InputDecoration(
                  hintText: 'Ask a legal question...',
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),

            // 🧠 Ask Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _askAI,
                icon: const Icon(Icons.smart_toy_outlined, color: Colors.white),
                label: const Text('Ask AI Agent'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 💬 Response Section
            Expanded(
              child: Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50.withOpacity(0.4),
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _response.isNotEmpty
                    ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "AI Response:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _response,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: _response));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                  Text('Copied to clipboard')),
                            );
                          },
                          icon: const Icon(Icons.copy,
                              color: Colors.white),
                          label: const Text('Copy'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    : const Center(
                  child: Text(
                    'Ask your legal query to get an AI-powered explanation!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black54, fontSize: 16),
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
