import 'package:flutter/material.dart';
import 'package:frontend/theme/colors.dart';
import 'package:frontend/ui/widgets/Chip.dart';
import 'package:frontend/ui/widgets/AnimatedIconButton.dart';
import 'CourseCard_styles.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String moduleNr;
  final String credits;
  final String category;
  final String? matchBasis; 
  final List<ChipType> tags;
  final double? rating;
  final int matchPercentage;
  
  final bool isFavorite;
  final bool isPlanned; 

  final VoidCallback onCardTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onPlanTap; 

  const CourseCard({
    super.key,
    required this.title,
    required this.moduleNr,
    required this.credits,
    required this.category,
    this.matchBasis,
    required this.tags,
    this.rating,
    required this.matchPercentage,
    required this.isFavorite,
    required this.isPlanned,
    required this.onCardTap,
    required this.onFavoriteTap,
    required this.onPlanTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final hasRating = rating != null && rating! > 0;

    return Container(
      decoration: CourseCardStyles.getCardDecoration(isDarkMode: isDarkMode),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onCardTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Top
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: textTheme.titleMedium?.copyWith(color: isDarkMode ? Colors.white : AppColors.textMain, fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(text: title),
                                TextSpan(text: ' ($moduleNr)'),
                                TextSpan(text: ' • $credits ECTS', style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Text(category, style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),

                    // Buttons (heart & Planner)
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Herz Button
                          AnimatedIconButton(
                            isSelected: isFavorite,
                            onTap: onFavoriteTap,
                            icon: Icons.favorite_border,
                            selectedIcon: Icons.favorite,
                            activeColor: AppColors.pink,
                            activeBackgroundColor: AppColors.pinkLight,
                            inactiveColor: AppColors.pink, 
                          ),
                          
                          SizedBox(width: 8), 

                          // Plan Button
                          AnimatedIconButton(
                            isSelected: isPlanned,
                            onTap: onPlanTap,
                            svgAsset: 'assets/icons/book-open.svg',
                            selectedSvgAsset: 'assets/icons/book-open-filled.svg',
                            activeColor: AppColors.primaryBlue,
                            activeBackgroundColor: AppColors.primaryBlueLight,
                            inactiveColor: AppColors.primaryBlue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // middle (Tags)
                if (tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (var tag in tags.take(3))
                          ChipWidget(label: tag.label, color: tag.color),
                        if (tags.length > 3)
                          ChipWidget(label: "+${tags.length - 3}", color: Colors.blueGrey)
                      ],
                    ),
                  ),

                // bottom (Rating & Match)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Rating
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: AppColors.star, size: 25),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              hasRating ? rating.toString() : '-',
                              style: textTheme.titleMedium?.copyWith(
                                color: isDarkMode ? Colors.white : AppColors.textMain,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Match Rechts
                      Flexible(
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: [
                            if (matchBasis != null)
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Based on your $matchBasis ',
                                      style: textTheme.labelSmall?.copyWith(color: AppColors.green),
                                    ),
                                    const WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 2.0),
                                        child: Icon(Icons.check_box, color: AppColors.matchGreen, size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ChipWidget(label: "$matchPercentage% match", color: Colors.green),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}