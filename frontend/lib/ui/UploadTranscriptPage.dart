import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/colors.dart';
import 'SpecifyDegreePage.dart';

class UploadTranscriptPage extends StatefulWidget {
  const UploadTranscriptPage({super.key});

  @override
  State<UploadTranscriptPage> createState() => _UploadTranscriptPageState();
}

class _UploadTranscriptPageState extends State<UploadTranscriptPage> {
  PlatformFile? _pickedFile;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _pickedFile = result.files.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload your transcript"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primaryBlue,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue.shade50,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload_file,
                      size: 64,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _pickedFile != null
                          ? _pickedFile!.name
                          : 'Tap to upload PDF',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: _pickedFile != null
                            ? Colors.green
                            : AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_pickedFile == null)
                      Text(
                        'or drag and drop',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_pickedFile != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'File uploaded',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              _pickedFile!.name,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _pickedFile = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _pickedFile != null
                  ? AppColors.primaryBlue
                  : AppColors.primaryBlueLight,
              foregroundColor: AppColors.buttonText,
              disabledBackgroundColor: AppColors.primaryBlueLight,
              disabledForegroundColor: AppColors.buttonText,
            ),
            onPressed: _pickedFile != null
                ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SpecifyDegreePage(),
                ),
              );
            }
                : null,
            child: const Text("Finish create your account"),
          ),
        );
  }
}
