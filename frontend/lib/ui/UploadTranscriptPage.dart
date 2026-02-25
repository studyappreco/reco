import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' show Session;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/repos/TranscriptRepository.dart';
import 'package:frontend/repos/UserRepository.dart';
import 'package:frontend/theme/colors.dart';
import 'package:frontend/ui/utils/auth.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/ui/widgets/StatusMessage/StatusMessageCard.dart'; 

class UploadTranscriptPage extends StatefulWidget {
  const UploadTranscriptPage({super.key});

  @override
  State<UploadTranscriptPage> createState() => _UploadTranscriptPageState();
}

class _UploadTranscriptPageState extends State<UploadTranscriptPage> {
  String? _selectedFileName;
  String? _selectedFilePath;
  String? _errorMessage;
  bool _isPicking = false;
  late final clientSession = context.read<ClientSession>();
  late final session = clientSession.session;

  late final _selectedLiteral = clientSession.newUserLiteral;

  Future<void> _pickTranscript() async {
    setState(() {
      _isPicking = true;
      _errorMessage = null;
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
          _selectedFilePath = null;
        });
        return;
      }

      final pickedFile = result.files.first;
      final ext = pickedFile.extension?.toLowerCase();
      final isSupported = ext == 'pdf';

      if (!isSupported) {
        setState(() {
          _selectedFileName = null;
          _selectedFilePath = null;
          _errorMessage = 'Unsupported file type. Please upload a PDF.';
        });
        return;
      }

      setState(() {
        _selectedFileName = pickedFile.name;
        _selectedFilePath = pickedFile.path;
        _errorMessage = null;
      });
    } catch (err) {
      setState(() {
        _errorMessage = 'Could not open file picker. Please try again.';
        _selectedFileName = null;
        _selectedFilePath = null;
      });
    } finally {
      setState(() {
        _isPicking = false;
      });
    }
  }

  Future<void> _onContinue() async {
    if (session == null) {
      await _uploadTranscriptFromRegister();
    } else {
      _uploadTranscriptFromHome();
    }
  }

  Future<void> _uploadTranscriptFromRegister() async {
    final userId = clientSession.newUser?.$id;
    final email = clientSession.newUser?.email;
    final password = clientSession.newUserPassword;
    if (userId == null || email == null || password == null || _selectedFilePath == null || _selectedLiteral == null) return;

    final processor = context.read<TranscriptProcessor>();
    processor.processTranscript(
      pdfFile: File(_selectedFilePath!),
      userID: userId,
      programLiteral: _selectedLiteral,
    );

    // Create session with new user
    Client? client = BackendClient.getBackendClient();
    if (client == null) throw Exception("Backend client could not be initialized");
    Account account = Account(client);

    Session newSession = await account.createEmailPasswordSession(email: email, password: password);
    clientSession.setUserSession(newSession);
    clientSession.resetNewUser();
  }

  Future<void> _uploadTranscriptFromHome() async {
    final userId = clientSession.getUserID();
    if (userId == null) return;

    final userRepository = context.read<UserRepository>();
    final literal = (await userRepository.getUserDetails(userId))?.programLiteral;
    if (_selectedFilePath == null || literal == null || !mounted) return;

    final processor = context.read<TranscriptProcessor>();
    processor.processTranscript(
      pdfFile: File(_selectedFilePath!),
      userID: userId,
      programLiteral: literal,
    );

    context.pop();
  }

  Future<void> _onSkip() async {
    if (_selectedLiteral == null) return;

    final clientSession = context.read<ClientSession>();
    final userId = clientSession.newUser?.$id;
    final email = clientSession.newUser?.email;
    final password = clientSession.newUserPassword;
    if (userId == null || email == null || password == null) return;

    // Create session with new user
    Client? client = BackendClient.getBackendClient();
    if (client == null) throw Exception("Backend client could not be initialized");
    Account account = Account(client);

    Session session = await account.createEmailPasswordSession(email: email, password: password);
    clientSession.setUserSession(session);
    clientSession.resetNewUser();
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
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          spacing: 10,
          mainAxisAlignment: .spaceBetween,
          children: [
            /*Expanded(
              child:*/ Text(
                'Upload your transcript to automatically import completed courses',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            /*)*/,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  if (_selectedFilePath != null && _errorMessage == null) ...[
                    StatusMessageCard(
                      isError: false,
                      title: 'Success!',
                      message: 'Your transcript has been recorded.',
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_errorMessage != null) ...[
                    StatusMessageCard(
                      isError: true,
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
                  if (_selectedFilePath == null && _errorMessage == null) ...[
                    StatusMessageCardPlaceholder(),
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
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: .end,
                crossAxisAlignment: .center,
                children: [
                  AdaptiveButton(
                    onPressed: _selectedFilePath != null && _errorMessage == null && !_isPicking
                      ? _onContinue
                      : null,
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(child: Text("Continue"))
                    )
                  ),
                  if (session == null)
                  Row(
                    mainAxisAlignment: .center,
                    children: [
                      Text("Don't have a transcript yet?"),
                      TextButton(
                        onPressed: _onSkip,
                        child: Text("Skip")
                      )
                    ],
                  )
                ],
              )
            )
          ]
        ),
      )
    );
  }
}
