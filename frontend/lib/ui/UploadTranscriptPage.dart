import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/theme/colors.dart';

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
        allowedExtensions: const ['pdf'],
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
      final isSupported = ext == 'pdf';

      if (!isSupported) {
        setState(() {
          _selectedFileName = null;
          _errorMessage = 'Unsupported file type. Please upload a PDF.';
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textMain),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Upload Transcript',
          style: theme.textTheme.titleLarge?.copyWith(color: AppColors.textMain),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Upload your transcript to automatically import completed courses',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            if (_uploadConfirmed && _errorMessage == null) ...[
              _StatusBanner(
                background: AppColors.greenLight,
                border: AppColors.greenLight,
                icon: Icons.check_circle,
                iconColor: AppColors.green,
                title: 'Success!',
                message: 'Your transcript has been recorded.',
                onClose: () {
                  setState(() {
                    _uploadConfirmed = false;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
            if (_errorMessage != null) ...[
              _StatusBanner(
                background: const Color(0xFFFFF1F2),
                border: const Color(0xFFFFE4E6),
                icon: Icons.error_outline,
                iconColor: Colors.red,
                title: 'Upload failed',
                message: _errorMessage!,
                onClose: () {
                  setState(() {
                    _errorMessage = null;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
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
                        : AppColors.border,
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlueLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        size: 28,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedFileName ?? 'Browse to upload files',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.textMain,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Supported formats: PDF',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (_isPicking) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(strokeWidth: 2),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (_selectedFileName != null && _errorMessage == null && !_isPicking)
                  ? _confirmUpload
                  : null,
              child: const Text('Confirm Upload'),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final Color background;
  final Color border;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final VoidCallback onClose;

  const _StatusBanner({
    required this.background,
    required this.border,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.textMain,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
          )
        ],
      ),
    );
  }
}
