import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AIDoubtForumPage extends StatefulWidget {
  const AIDoubtForumPage({super.key});

  @override
  State<AIDoubtForumPage> createState() => _AIDoubtForumPageState();
}

class _AIDoubtForumPageState extends State<AIDoubtForumPage> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _isLoading = false;

  /// 🔹 Ask GitHub Models → OpenAI GPT-4o-mini
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
        Uri.parse("https://models.github.ai/inference/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $githubToken",
        },
        body: jsonEncode({
          "model": "openai/gpt-4o-mini",
          "messages": [
            {
              "role": "system",
              "content": """
You are **NyayaAI**, an expert in **Indian Law only** (IPC, CrPC, IEA, Constitution of India, Special Acts, legal rights, legal procedures, and judicial interpretations).

### Your strict rules:
1. **Answer ONLY law-related questions.**
2. If a question is not related to *Indian law*, politely decline:
   - Example: “I can only help with Indian law–related questions.”
3. For every valid query:
   - Provide clear, simple explanations.
   - Mention relevant IPC/CrPC/Constitution sections.
   - Add examples or real-life scenarios.
   - Add legal procedure where needed (FIR, Bail, Court process, etc.)
4. Do NOT hallucinate. If unsure, say:
   - “This requires a licensed advocate. However, here is the general legal information…”

Stay accurate and helpful.
"""
            },
            {
              "role": "user",
              "content": query
            }
          ]
        }),
      ).timeout(const Duration(seconds: 25));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        final reply =
            data["choices"]?[0]?["message"]?["content"] ??
                "⚠️ No response from model.";

        setState(() => _response = "🧠 *Legal Explanation:*\n$reply");
      } else {
        setState(() => _response =
        "⚠️ GitHub Model Error ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      setState(() => _response = "⚠️ Exception: $e");
    } finally {
      setState(() => _isLoading = false);
    }
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _askAI(),
                decoration: InputDecoration(
                  hintText: 'Ask your legal question (Indian law only)...',
                  prefixIcon: const Icon(Icons.gavel, color: Colors.blue),
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _askAI,
                icon: const Icon(Icons.balance, color: Colors.white),
                label: const Text('Ask NyayaAI'),
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

            Expanded(
              child: Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50.withOpacity(0.4),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
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
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content:
                                Text('Copied to clipboard'),
                              ),
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
                    'Ask any query related to *Indian law* to receive an AI-powered explanation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black54, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
