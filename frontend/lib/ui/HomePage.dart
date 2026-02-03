import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';
import 'package:frontend/ui/widgets/AdaptiveSearchfield.dart';
import 'package:frontend/ui/widgets/CourseCard/CourseCard.dart';
import 'package:frontend/ui/widgets/CourseOverview.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/theme/colors.dart';
import 'package:frontend/ui/widgets/Chip.dart';

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
                        onPressed: () => context.push("/review-courses"),
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
                      child: CourseOverview(detailsButtonDestination: "/home/review-courses")
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
                      onCardTap: () => context.go('/home/course-details', extra: "404"),
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
                      onCardTap: () => context.go('/home/course-details', extra: "404"),
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
                      onCardTap: () => context.go('/home/course-details', extra: "404"),
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
                      onCardTap: () => context.go('/home/course-details', extra: "404"),
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

class HomePageViewmodel extends ChangeNotifier {

}
