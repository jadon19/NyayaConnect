import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';

class DocumentReviewPage extends StatefulWidget {
  const DocumentReviewPage({super.key});

  @override
  State<DocumentReviewPage> createState() => _DocumentReviewPageState();
}

class _DocumentReviewPageState extends State<DocumentReviewPage> {
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

  void _openFile(String path) {
    OpenFilex.open(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Review', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF42A5F5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _documents.isEmpty
            ? const Center(
          child: Text(
            'No documents uploaded yet.\nTap the + button to add one.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        )
            : ListView.builder(
          itemCount: _documents.length,
          itemBuilder: (context, index) {
            final doc = _documents[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(_getIconForFile(doc["ext"] ?? "")),
                title: Text(doc["name"] ?? "Unknown File"),
                subtitle: Text(doc["path"] ?? ""),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () => _openFile(doc["path"] ?? ""),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickDocument,
        backgroundColor: const Color(0xFF42A5F5),
        child: const Icon(Icons.add),
      ),
    );
  }
}
