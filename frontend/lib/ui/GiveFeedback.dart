import 'package:flutter/material.dart';
import 'package:frontend/theme/colors.dart';

class GiveFeedbackPage extends StatefulWidget {
  const GiveFeedbackPage({super.key});

  @override
  State<GiveFeedbackPage> createState() => _GiveFeedbackPageState();
}

class _GiveFeedbackPageState extends State<GiveFeedbackPage> {
  int? _rating; // null = not selected yet (1..5 once selected)
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    final comment = _commentController.text.trim();

    if (_rating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a rating.")),
      );
      return;
    }

    // Optional: validate comment too (uncomment if required)
    // if (comment.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Please write a comment.")),
    //   );
    //   return;
    // }

    // TODO: Replace with backend submit later
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Submitted: ${_rating!}/5 - $comment")),
    );

    // Optional: clear after submit
    // setState(() => _rating = null);
    // _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Module Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Header (manual for now) =====
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Algorithm", style: textTheme.headlineSmall),
                    Text("6", style: textTheme.headlineSmall),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "CS201",
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    "ECTS",
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ===== Rating bar (clickable stars) + x/5 (only after selection) =====
              Row(
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      final starValue = index + 1; // 1..5
                      final isFilled =
                          _rating != null && starValue <= _rating!;

                      return IconButton(
                        onPressed: () => setState(() => _rating = starValue),
                        icon: Icon(
                          isFilled ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                      );
                    }),
                  ),
                  const SizedBox(width: 12),
                  if (_rating != null)
                    Text(
                      "$_rating/5",
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // ===== Comment box (textable) =====
              TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Write your feedback here",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.blue.shade400, width: 1.2),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),

              const Spacer(),

              // ===== Bottom button =====
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1677FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "+  Submit Feedback",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}