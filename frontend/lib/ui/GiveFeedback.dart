import 'package:flutter/material.dart';
import 'package:frontend/theme/colors.dart';
import 'package:frontend/ui/utils/auth.dart';
import 'package:frontend/repos/UserRepository.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/ui/widgets/StatusMessage/StatusMessage.dart';

class GiveFeedbackPage extends StatefulWidget {
  final String title;
  final String credits;
  final String moduleNr;
  final int? initialRating;
  final String? initialComment;

  const GiveFeedbackPage({super.key, required this.title, required this.credits, required this.moduleNr, this.initialRating, this.initialComment});

  @override
  State<GiveFeedbackPage> createState() => _GiveFeedbackPageState();
}

class _GiveFeedbackPageState extends State<GiveFeedbackPage> {
  int? _rating;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;
  late bool _isUpdate;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    if(widget.initialComment != null){
      _commentController.text = widget.initialComment!;
    }
    _isUpdate = widget.initialRating != null;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final comment = _commentController.text.trim();

    if (_rating == null) {
      StatusMessage.show(
        context: context,
        alignment: SnackAlignment.CENTER,
        title: "Missing Rating",
        message: "Please select a rating before submitting",
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    final userID = context.read<ClientSession>().getUserID() ?? "";
    final userRepo = context.read<UserRepository>();
    bool success = await userRepo.submitFeedback(moduleNr: widget.moduleNr, userId: userID, rating: _rating!, feedbackText: comment);

    setState(() {
      _isLoading = false;
      if(success) _isUpdate = true; 
    });

    if(success){
      StatusMessage.show(
        context: context,
        alignment: SnackAlignment.TOP,
        title: "Success!",
        message: "Your feedback has been saved.",
        isError: false
      );
    } else {
      StatusMessage.show(
        context: context,
        alignment: SnackAlignment.TOP,
        title: "Oops! Something went wrong",
        message: "Error submitting your feedback",
        isError: true
      );
    }
  }

  Future<void> _delete() async {
    setState(() => _isLoading = true);

    final userID = context.read<ClientSession>().getUserID() ?? "";
    final userRepo = context.read<UserRepository>();

    bool success = await userRepo.deleteFeedback(widget.moduleNr, userID);

    setState(() {
      _isLoading = false;
      if(success){
        _isUpdate = false; 
        _rating = null;    
        _commentController.clear();
      }
    });

    if(success){
      StatusMessage.show(
        context: context,
        alignment: SnackAlignment.TOP,
        title: "Deleted",
        message: "Your feedback was successfully deleted.",
        isError: false
      );
    } else {
      StatusMessage.show(
        context: context,
        alignment: SnackAlignment.CENTER,
        title: "Oops! Something went wrong",
        message: "Error deleting your feedback",
        isError: true
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Module Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: _isLoading 
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(widget.title, style: textTheme.headlineSmall),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(widget.credits, style: textTheme.headlineSmall),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.moduleNr,
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

                  // Rating bar (clickable stars) + x/5 (only after selection)
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

                  // Comment box (textable)
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

              // Bottom button
                  SizedBox(
                    width: double.infinity,
                    child: AdaptiveButton(
                      onPressed: _submit,
                      child: Center(
                        child: Text(
                          _isUpdate ? "Update Feedback" : "Submit Feedback",
                          style: textTheme.bodyMedium?.copyWith(color: Colors.white)
                        ),
                      ),
                    ),
                  ),

                  if (_isUpdate) ...[

                    SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          filledButtonTheme: FilledButtonThemeData(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.red,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                            ),
                          )
                        ),
                        child: AdaptiveButton(
                          onPressed: _delete,
                          child: Center(
                            child: Text(
                              "Delete Feedback",
                              style: textTheme.bodyMedium?.copyWith(color: Colors.white)
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
    );
  }
}