import 'package:flutter/material.dart';
import 'package:frontend/ui/upload_transcript_page.dart';
import 'package:frontend/ui/InterestSelectionPage.dart';

class CourseIntakeMethodPage extends StatelessWidget {
  const CourseIntakeMethodPage({super.key});

  void _goToManualSelection(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => InterestSelectionPage()),
    );
  }

  void _goToUploadTranscript(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UploadTranscriptPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Select the courses you had taken so far',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you’d like to import your completed courses',
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
              _IntakeOptionCard(
                icon: Icons.description_outlined,
                iconBackground: Colors.blue.shade50,
                title: 'Select Manually',
                subtitle: 'Choose courses from a list',
                onTap: () => _goToManualSelection(context),
              ),
              const SizedBox(height: 12),
              _IntakeOptionCard(
                icon: Icons.upload_file_outlined,
                iconBackground: Colors.green.shade50,
                title: 'Upload Transcript',
                subtitle: 'Upload PDF or CSV file',
                onTap: () => _goToUploadTranscript(context),
              ),
              const SizedBox(height: 12),
              _IntakeOptionCard(
                icon: Icons.document_scanner_outlined,
                iconBackground: Colors.purple.shade50,
                title: 'Scan Transcript (Future Work)',
                subtitle: 'Use your camera to scan',
                onTap: () {},
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Skip for now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntakeOptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _IntakeOptionCard({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.black87),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
