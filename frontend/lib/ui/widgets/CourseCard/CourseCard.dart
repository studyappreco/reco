import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/theme/colors.dart'; 
import 'CourseCard_styles.dart'; 

class CourseCard extends StatelessWidget {
  final String title;
  final String moduleNr;
  final String credits;
  final String? matchBasis; 
  final List<String> tags;
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
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onCardTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(  // I divide the stuff into top, middle, and bottom
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // top
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      // https://api.flutter.dev/flutter/widgets/RichText-class.html
                      child: RichText(
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
                    ),
                    
                    // Buttons Favorite + Plan
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: InkWell(
                            onTap: onFavoriteTap,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: CourseCardStyles.getFavoriteDecoration(isActive: isFavorite),
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: AppColors.pink, 
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: InkWell(
                            onTap: onPlanTap,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: CourseCardStyles.getPlanDecoration(isActive: isPlanned),
                              child: SvgPicture.asset(  // https://www.geeksforgeeks.org/flutter/flutter-how-to-use-svg-image/ and https://stackoverflow.com/questions/67588713/flutter-changing-svg-icon-color
                                isPlanned ? 'assets/icons/book-open-filled.svg' : 'assets/icons/book-open.svg', 
                                width: 20,
                                height: 20,
                                colorFilter: ColorFilter.mode(AppColors.grey, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                
                // middle
                if(tags.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        // I have implemented it so that the first 3 tags are shown and the rest are not, so that not too much is displayed. Feel free to suggest other options if you have any
                        for(var tagText in tags.take(3))
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: CourseCardStyles.getTagDecoration(),
                            child: Text(
                              tagText,
                              style: textTheme.labelSmall?.copyWith(color: AppColors.primaryBlue),
                            ),
                          ),

                        // I made it so that if there are more than 3 tags, the total number of tags is displayed at the end instead of listing them all
                        if(tags.length > 3)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: CourseCardStyles.getTagDecoration(),
                            child: Text('+${tags.length - 3}', 
                              style: textTheme.labelSmall?.copyWith(color: AppColors.primaryBlue),
                            ),
                          ),
                      ],
                    ),
                  ),

                // bottom
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating
                      Row(
                        children: [
                          Icon(
                            hasRating ? Icons.star : Icons.star_border, 
                            color: AppColors.star, 
                            size: 25
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: Text(
                              hasRating ? rating.toString() : '-',
                              style: textTheme.titleMedium?.copyWith(color: isDarkMode ? Colors.white : AppColors.textMain),
                            ),
                          ),
                        ],
                      ),
                      
                      // Match Percentage Area
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          if(matchBasis != null)
                            Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Based on your $matchBasis ',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: AppColors.green,
                                    ),
                                  ),
                                  Icon(
                                    Icons.check_box, 
                                    color: AppColors.matchGreen,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: CourseCardStyles.getMatchDecoration(),
                            child: Text(
                              '$matchPercentage% match',
                              style: textTheme.labelSmall?.copyWith(color: AppColors.green),
                            ),
                          ),
                        ],
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