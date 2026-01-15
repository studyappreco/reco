import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';
import 'package:frontend/ui/widgets/AdaptiveSearchfield.dart';
import 'package:frontend/ui/widgets/CourseCard/CourseCard.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/theme/colors.dart';
import 'package:frontend/ui/widgets/Chip.dart';
import 'package:frontend/ui/UploadTranscriptPage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider<HomePageViewmodel>(
      create: (_) => HomePageViewmodel(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: AdaptiveSearchField(
            onChanged: (str) {},
          ),
        ),
        backgroundColor: colorScheme.surface,
        body: Consumer<HomePageViewmodel>(
          builder: (context, vm, child) {
            return Padding(
              padding: EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 4,
                  children: [
                    Text(
                      "Hello Zohreh",
                      style: textTheme.headlineSmall?.copyWith(color: AppColors.textMain),
                    ),
                    Text(
                      "Here's your academic overview",
                      style: textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: AdaptiveButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 4.0),
                                  child: Text("Current GPA", style: textTheme.titleSmall?.copyWith(color: Colors.white)),
                                ),
                                Text("3.7", style: textTheme.headlineMedium?.copyWith(color: Colors.white)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 4.0),
                                  child: Text("Total ECTS", style: textTheme.titleSmall?.copyWith(color: Colors.white)),
                                ),
                                Text("120", style: textTheme.headlineMedium?.copyWith(color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Container(
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
                                TextButton(
                                  onPressed: () {},
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
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: .spaceBetween,
                        crossAxisAlignment: .center,
                        children: [
                          Text(
                            "Recommended for you",
                            style: textTheme.titleLarge?.copyWith(color: AppColors.textMain)
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap
                            ),
                            child: Text(
                              "See all",
                              style: textTheme.titleMedium?.copyWith(color: colorScheme.primary)
                            ),
                          ),
                        ],
                      ),
                    ),
                    CourseCard(
                      title: "Algorithm",
                      moduleNr: "CS201",
                      credits: "6",
                      category: "Computer Science",
                      tags: [
                        ChipType("Data Science", colorScheme.primary),
                        ChipType("C++",  Colors.purpleAccent)
                      ],
                      rating: 4.5,
                      matchPercentage: 88,
                      isFavorite: false,
                      isPlanned: false,
                      matchBasis: "interests",
                      onCardTap: () => context.go('/home/course-details'),
                      onFavoriteTap: () {},
                      onPlanTap: () {},
                    ),
                    CourseCard(
                      title: "Deep Learning",
                      moduleNr: "AI301",
                      credits: "6",
                      category: "Computer Science",
                      tags: [
                        ChipType("AI", colorScheme.primary),
                        ChipType("Python",  Colors.purpleAccent)
                      ],
                      rating: 4.2,
                      matchPercentage: 95,
                      isFavorite: false,
                      isPlanned: false,
                      matchBasis: "interests",
                      onCardTap: () => context.go('/home/course-details'),
                      onFavoriteTap: () {},
                      onPlanTap: () {},
                    ),
                    CourseCard(
                      title: "Data Mining",
                      moduleNr: "DS202",
                      credits: "6",
                      category: "Computer Science",
                      tags: [
                        ChipType("Data Science", colorScheme.primary),
                        ChipType("C++",  Colors.purpleAccent)
                      ],
                      rating: 3.9,
                      matchPercentage: 92,
                      isFavorite: false,
                      isPlanned: false,
                      matchBasis: "interests",
                      onCardTap: () => context.go('/home/course-details'),
                      onFavoriteTap: () {},
                      onPlanTap: () {},
                    ),
                    CourseCard(
                      title: "Advanced Algorithms",
                      moduleNr: "CS204",
                      credits: "6",
                      category: "Computer Science",
                      tags: [
                        ChipType("Data Science", colorScheme.primary),
                        ChipType("Java",  Colors.purpleAccent)
                      ],
                      rating: 4.8,
                      matchPercentage: 88,
                      isFavorite: false,
                      isPlanned: false,
                      matchBasis: "interests",
                      onCardTap: () => context.go('/home/course-details'),
                      onFavoriteTap: () {},
                      onPlanTap: () {},
                    ),
                  ]
                )
              )
            );
          },
        ),
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

class HomePageViewmodel extends ChangeNotifier {

}
