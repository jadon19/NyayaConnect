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
  String _response = '';
  bool _isLoading = false;

  /// 🔹 Ask NyayaAI (GitHub Models → OpenAI o4-mini)
  Future<void> _askAI() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = '';
    });

    final githubToken = dotenv.env['GITHUB_TOKEN'];

    if (githubToken == null || githubToken.isEmpty) {
      setState(() {
        _response = "⚠️ Missing GITHUB_TOKEN. Please check your .env file.";
        _isLoading = false;
      });
      return;
    }

    try {
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
          "messages": [
            {
              "role": "developer",
              "content": """
You are NyayaAI, an expert in Indian Law only.

Rules:
1. Answer ONLY Indian law-related questions.
2. If the question is not related to Indian law, politely decline.
3. Mention relevant IPC / CrPC / Constitution sections when applicable.
4. Give clear explanations with examples.
5. If unsure, say that a licensed advocate should be consulted.
"""
            },
            {
              "role": "user",
              "content": query,
            }
          ],
        }),
      )
          .timeout(const Duration(seconds: 25));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final reply =
            data["choices"]?[0]?["message"]?["content"] ??
                "⚠️ No response from model.";

        setState(() {
          _response = "🧠 Legal Explanation:\n\n$reply";
        });
      } else {
        setState(() {
          _response =
          "⚠️ GitHub Models Error ${res.statusCode}\n\n${res.body}";
        });
      }
    } catch (e) {
      setState(() {
        _response = "⚠️ Exception: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 🔹 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          /// 🔵 Gradient Header
          const SimpleGradientHeader(
            title: "AI Doubt Forum",
          ),

          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  /// 🔍 Question Input
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _askAI(),
                      decoration: InputDecoration(
                        hintText: 'Ask your legal question (Indian law)...',
                        prefixIcon:
                        const Icon(Icons.gavel, color: Colors.blue),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  /// 🧠 Ask Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _askAI,
                      icon:
                      const Icon(Icons.balance, color: Colors.white),
                      label: const Text(
                        'Ask NyayaAI',
                        style: TextStyle(color: Colors.white),
                      ),
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

                  /// 🧾 Response Section
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withOpacity(0.4),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: _isLoading
                          ? const Center(
                        child: CircularProgressIndicator(),
                      )
                          : _response.isNotEmpty
                          ? SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "AI Response",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _response,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),

                            /// 📋 Copy Button
                            Align(
                              alignment:
                              Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                        text: _response),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Copied to clipboard'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy,
                                    color: Colors.white),
                                label:
                                const Text('Copy'),
                                style:
                                ElevatedButton.styleFrom(
                                  backgroundColor:
                                  Colors.blueAccent,
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                        8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                          : const Center(
                        child: Text(
                          'Ask any question related to Indian law to get an AI-powered legal explanation.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
