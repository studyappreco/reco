import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UploadTranscriptPage extends StatefulWidget {
  const UploadTranscriptPage({super.key});

  @override
  State<UploadTranscriptPage> createState() => _UploadTranscriptPageState();
}

class _UploadTranscriptPageState extends State<UploadTranscriptPage> {
  String? _selectedFileName;
  String? _errorMessage;
  bool _isPicking = false;
  bool _uploadConfirmed = false;

  Future<void> _pickTranscript() async {
    setState(() {
      _isPicking = true;
      _errorMessage = null;
      _uploadConfirmed = false;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'csv'],
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _selectedFileName = null;
        });
        return;
      }

      final pickedFile = result.files.first;
      final ext = pickedFile.extension?.toLowerCase();
      final isSupported = ext == 'pdf' || ext == 'csv';

      if (!isSupported) {
        setState(() {
          _selectedFileName = null;
          _errorMessage = 'Unsupported file type. Please upload a PDF or CSV.';
        });
        return;
      }

      setState(() {
        _selectedFileName = pickedFile.name;
        _errorMessage = null;
      });
    } catch (err) {
      setState(() {
        _errorMessage = 'Could not open file picker. Please try again.';
        _selectedFileName = null;
      });
    } finally {
      setState(() {
        _isPicking = false;
      });
    }
  }

  void _confirmUpload() {
    if (_selectedFileName == null) return;
    setState(() {
      _uploadConfirmed = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_selectedFileName ready to upload'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Upload Transcript'),
        centerTitle: true,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Upload your transcript to automatically import completed courses',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _isPicking ? null : _pickTranscript,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _errorMessage != null
                        ? Colors.redAccent
                        : Colors.grey.shade300,
                  ),
                  color: Colors.grey.shade50,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.upload_rounded,
                        size: 28,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedFileName ?? 'Browse to upload files',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _selectedFileName != null
                            ? Colors.black
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Supported formats: PDF, CSV',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    if (_isPicking) ...[
                      const SizedBox(height: 12),
                      const CircularProgressIndicator(strokeWidth: 2),
                    ],
                    if (_uploadConfirmed && _errorMessage == null) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'File ready to upload',
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: ElevatedButton(
            onPressed: (_selectedFileName != null && _errorMessage == null && !_isPicking)
                ? _confirmUpload
                : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade400,
            ),
            child: const Text('Confirm Upload'),
          ),
        ),
      ),
    );
  }
}
