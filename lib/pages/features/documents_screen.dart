import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final List<Map<String, String>> _documents = [];

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _documents.add({
          "name": file.name,
          "path": file.path ?? "",
          "ext": file.extension ?? "",
        });
      });
    }
  }

  IconData _getIconForFile(String ext) {
    switch (ext) {
      case "pdf":
        return Icons.picture_as_pdf;
      case "doc":
      case "docx":
        return Icons.description;
      case "jpg":
      case "png":
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _openDocument(String path) async {
    if (path.isNotEmpty) {
      await OpenFilex.open(path); // ✅ opens file with native viewer
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File not found")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Documents"),
        centerTitle: true,
      ),
      body: _documents.isEmpty
          ? const Center(
        child: Text("No documents uploaded yet."),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _documents.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final doc = _documents[index];
          return ListTile(
            leading: Icon(
              _getIconForFile(doc["ext"] ?? ""),
              color: Colors.blue,
              size: 32,
            ),
            title: Text(doc["name"] ?? ""),
            subtitle: Text(doc["ext"]?.toUpperCase() ?? "File"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  _documents.removeAt(index);
                });
              },
            ),
            onTap: () => _openDocument(doc["path"] ?? ""),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickDocument,
        icon: const Icon(Icons.upload_file),
        label: const Text("Upload"),
      ),
    );
  }
}