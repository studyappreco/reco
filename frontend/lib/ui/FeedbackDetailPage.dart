import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/Module.dart';
import 'package:frontend/repos/CourseSearchRepo.dart';
import 'package:frontend/utils/RecoLog.dart';
import 'package:frontend/theme/colors.dart'; 

class FeedbackDetailPage extends StatelessWidget {
  final String moduleNr; 
  final String moduleTitle;

  const FeedbackDetailPage({
    super.key,
    required this.moduleNr, 
    required this.moduleTitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider<FeedbackDetailPageViewmodel>(
      create: (_) => FeedbackDetailPageViewmodel(context.read(), moduleNr),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('Student Feedback'),
        ),
        backgroundColor: colorScheme.surface,
        body: Consumer<FeedbackDetailPageViewmodel>(
          builder: (context, vm, child) {
            // Loading status
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final displayTitle = vm.module?.title ?? moduleTitle;
            final feedbacks = vm.module?.feedbacks ?? [];

            return SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: textTheme.headlineSmall?.copyWith(color: AppColors.textMain, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  
                  _RatingSummary(feedbacks: feedbacks),
                  
                  const SizedBox(height: 24),
                  Text(
                    'Common themes',
                    style: textTheme.titleMedium?.copyWith(color: AppColors.textMain, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  
                  // TODO placeholder (Future Work)
                   _CommonThemes(),
                  
                  const SizedBox(height: 24),
                  Text(
                    'Reviews',
                    style: textTheme.titleMedium?.copyWith(color: AppColors.textMain, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  feedbacks.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            "No feedback has been given for this module yet.",
                            style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                          ),
                        )
                      : _ReviewList(feedbacks: feedbacks),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final List<dynamic> feedbacks;

  const _RatingSummary({required this.feedbacks});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final int totalReviews = feedbacks.length;
    
    // calculating the average
    double averageRating = 0.0;
    if(totalReviews > 0){
      final totalStars = feedbacks.fold(0, (sum, f) => sum + (f.rating as num).toInt());
      averageRating = totalStars / totalReviews;
    }

    // calculation of the distribution for the progress bars
    List<double> progressBars = [0.0, 0.0, 0.0, 0.0, 0.0];
    if(totalReviews > 0){
      for(var f in feedbacks){
        int rating = (f.rating as num).toInt();
        progressBars[rating - 1] += 1;
      }
      
      for(int i = 0; i < 5; i++){
        progressBars[i] = progressBars[i] / totalReviews;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textMain),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.star, color: Colors.amber, size: 32),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Based on $totalReviews reviews',
                style: textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 5; i >= 1; i--)
                Row(
                  children: [
                    Text('$i', style: textTheme.labelSmall?.copyWith(color: AppColors.textMain)),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 60,
                      child: LinearProgressIndicator(
                        value: progressBars[i - 1],
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// TODO: Replace with a widget that takes common themes from backend or state
class _CommonThemes extends StatelessWidget {
  const _CommonThemes();

  @override
  Widget build(BuildContext context) {
    // TODO: Replace hardcoded themes with data from backend or state
    final themes = [
      'Exam heavy (22)',
      'Project based (31)',
      'Great lecturer (28)',
      'Lots of coding (19)',
      'Challenging (15)',
      'Practical (25)',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: themes
          .map((theme) => Chip(
                label: Text(theme, style: const TextStyle(fontSize: 13)),
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ))
          .toList(),
    );
  }
}

class _ReviewList extends StatelessWidget {
  final List<dynamic> feedbacks;
  const _ReviewList({required this.feedbacks});

  DateTime _parseDate(String dateStr) {
    final p = dateStr.split('.');
    return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
  }

  @override
  Widget build(BuildContext context) {
    // sorting the list by date in descending order
    // TODO we should add a filter button and change this, so that the user can sort by other criteria as well
    final sortedFeedbacks = List<dynamic>.from(feedbacks)..sort((a, b) => 
      _parseDate(b.createdAt).compareTo(_parseDate(a.createdAt))
    );

    return Column(
      children: sortedFeedbacks.map((feedback) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _ReviewCard(feedback: feedback),
        );
      }).toList(),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final dynamic feedback;

  const _ReviewCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final rating = (feedback.rating as num?)?.toInt() ?? 0;
    final name = feedback.userName ?? "Anonymous"; 
    final date = feedback.createdAt; 
    
    final String feedbackText = feedback.feedbackText ?? "";
    final bool hasComment = feedbackText.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryBlueLight, 
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textMain),
                    ),
                    Text(
                      date,
                      style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          
          // If the feedback contains text, it will only be displayed then
          if(hasComment) ...[
            const SizedBox(height: 12),
            Text(
              feedbackText,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textMain),
            ),
          ],
        ],
      ),
    );
  }
}

class FeedbackDetailPageViewmodel extends ChangeNotifier {
  final CourseSearchRepo courseRepo;
  final String moduleNr;

  bool isLoading = true;
  Module? module;

  FeedbackDetailPageViewmodel(this.courseRepo, this.moduleNr) {
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      module = await courseRepo.getModuleByNumber(moduleNr, "");
    } catch (e, s) {
      RecoLog.error("Error loading feedback details", e, s);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}