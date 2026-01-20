import 'package:flutter/material.dart';
import 'package:frontend/theme/colors.dart';
import 'package:go_router/go_router.dart';

class CourseOverview extends StatelessWidget {
  final String? detailsButtonDestination;

  /// Creates the course overview section displayed on home page and review your courses page.
  ///
  /// If [detailsButtonDestination] equals [null], then
  /// the see details butten is hidden.
  const CourseOverview({
    super.key,
    this.detailsButtonDestination,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        border: BoxBorder.all(color: colorScheme.surfaceContainer, width: 1),
        borderRadius: BorderRadius.circular(13),
        color: Colors.white,
      ),
      child: Column(
        spacing: 15,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            crossAxisAlignment: .center,
            children: [
              Text(
                  "Course Overview",
                  style: textTheme.titleLarge?.copyWith(color: AppColors.textMain)
              ),
              if (detailsButtonDestination != null)
              TextButton(
                  onPressed: () => context.go(detailsButtonDestination!),
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                  child: Text(
                      "See Details",
                      style: textTheme.titleSmall?.copyWith(color: AppColors.textSecondary)
                  )
              )
            ],
          ),
          PercentageBar(
            label: "Information Systems",
            percentage: 75,
            color: colorScheme.primary
          ),
          PercentageBar(
            label: "Computer Science",
            percentage: 60,
            color: Colors.purple
          ),
          PercentageBar(
            label: "Business/Economics",
            percentage: 45,
            color: Colors.green
          ),
          PercentageBar(
            label: "Free Choice",
            percentage: 30,
            color: Colors.deepOrangeAccent
          ),
        ],
      ),
    );
  }
}

class PercentageBar extends StatelessWidget {
  final String label;
  final int percentage;
  final Color color;

  const PercentageBar({
    super.key,
    required this.label,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          crossAxisAlignment: .center,
          children: [
            Text(
              label,
              style: textTheme.bodyMedium
            ),
            Text(
              "$percentage%",
              style: textTheme.bodyMedium
            )

          ],
        ),
        Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage / 100,
              child: SizedBox(
                width: double.infinity,
                height: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            )
          ],
        )
      ]
    );
  }
}