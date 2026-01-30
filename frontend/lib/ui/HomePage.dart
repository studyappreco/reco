import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/repos/TranscriptRepository.dart';
import 'package:frontend/repos/transcriptUtils.dart';
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
            return vm.loading
            ? Center(child: CircularProgressIndicator())
            : Padding(
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
                                Text(vm.gpa.toStringAsFixed(1), style: textTheme.headlineMedium?.copyWith(color: Colors.white)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 4.0),
                                  child: Text("Current ECTS", style: textTheme.titleSmall?.copyWith(color: Colors.white)),
                                ),
                                Text(vm.ects.toString(), style: textTheme.headlineMedium?.copyWith(color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: CourseOverview(
                        categories: vm.categories,
                        detailsButtonDestination: "/review-courses"
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

class HomePageViewmodel extends ChangeNotifier {
  HomePageViewmodel() {
    _init();
  }

  bool _loading = false;
  double _gpa = 0.0;
  int _ects = 0;
  List<OverviewCategory> _categories = [];

  bool get loading => _loading;
  double get gpa => _gpa;
  int get ects => _ects;
  List<OverviewCategory> get categories => _categories;

  Future<void> _init() async {
    _loading = true;
    final repo = TranscriptRepository();
    final userId = clientSession.session?.userId;
    if (userId == null) {
      _loading = false;
      notifyListeners();
      return;
    }

    final userTranscript = await repo.getTranscript(userId);
    final dto = userTranscriptToDashboardDTO(userTranscript);
    if (dto == null) {
      _loading = false;
      notifyListeners();
      return;
    }

    _gpa = dto.gpa ?? 0.0;
    _ects = dto.earnedECTS;
    _categories = dto.categories;
    _loading = false;
    notifyListeners();
  }
}
