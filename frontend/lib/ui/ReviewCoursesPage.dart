import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/models/TranscriptDocument.dart';
import 'package:frontend/repos/TranscriptRepository.dart';
import 'package:frontend/repos/UserRepository.dart';
import 'package:frontend/repos/transcriptUtils.dart';
import 'package:frontend/ui/utils/auth.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';
import 'package:frontend/ui/widgets/CourseOverview.dart';
import 'package:provider/provider.dart';
import 'package:frontend/theme/colors.dart';

class ReviewCoursesPage extends StatelessWidget {
  const ReviewCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider<ReviewCoursesPageViewmodel>(
      create: (_) => ReviewCoursesPageViewmodel(context.read()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Review Your courses"),
        ),
        backgroundColor: colorScheme.surface,
        body: Consumer<ReviewCoursesPageViewmodel>(
          builder: (context, vm, child) {
            return vm.loading
              ? Center(child: CircularProgressIndicator())
              : Padding(
              padding: EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 12,
                  children: [
                    AdaptiveButton(
                      onPressed: null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 4.0),
                                child: Text("Current GPA", style: textTheme.titleSmall?.copyWith(color: AppColors.primaryBlue)),
                              ),
                              Text(vm.gpa.toStringAsFixed(1), style: textTheme.headlineMedium?.copyWith(color: AppColors.primaryBlue)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 4.0),
                                child: Text("Total ECTS", style: textTheme.titleSmall?.copyWith(color: AppColors.primaryBlue)),
                              ),
                              Text(vm.ects.toString(), style: textTheme.headlineMedium?.copyWith(color: AppColors.primaryBlue)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: .start,
                      spacing: 12,
                      children: vm.categories.map((category) {
                        return CourseCategoryCard(category: category);
                      }).toList()
                    ),
                    CourseOverview(
                      categories: vm.categories,
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

class CourseCategoryCard extends StatefulWidget {
  final OverviewCategory category;

  const CourseCategoryCard({
    super.key,
    required this.category,
  });

  @override
  State<CourseCategoryCard> createState() => _CourseCategoryCardState();
}

class _CourseCategoryCardState extends State<CourseCategoryCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final coursesLabel = widget.category.courses.length == 1 ? "course" : "courses";

    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.all(color: colorScheme.surfaceContainer, width: 1),
        borderRadius: BorderRadius.circular(13),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 10, 20),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlueLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: .center,
                          crossAxisAlignment: .center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/book-open.svg",
                              colorFilter: ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn),
                              width: 24,
                              height: 24,
                            ),
                          ],
                        )
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.category.name,
                            style: textTheme.titleMedium?.copyWith(color: AppColors.textMain),
                          ),
                          Text(
                            "${widget.category.courses.length} $coursesLabel \u2022 ${widget.category.earnedCredits}/${widget.category.requiredCredits} ECTS",
                            style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => setState(() {
                    expanded = !expanded;
                  }),
                  icon: Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                )
              ],
            ),
          ),
          if (expanded)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(13)),
                color: colorScheme.surfaceContainerLow,
              ),
              child:Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Column(
                  children: widget.category.courses.asMap().entries.map((c) {
                    return Column(
                      children: [
                        CourseCategoryCardCourseItem(
                          course: c.value,
                          isFirst: c.key == 0,
                        ),
                      ],
                    );
                  }).toList(),
                )
              )
            )
        ]
      )
    );
  }
}

class CourseCategoryCardCourseItem extends StatelessWidget {
  final TranscriptCourse course;
  final bool isFirst;

  const CourseCategoryCardCourseItem({
    super.key,
    required this.course,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        border: isFirst ? BoxBorder.fromLTRB() : BoxBorder.fromLTRB(top: BorderSide(color: colorScheme.surfaceContainer, width: 1))
      ),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  "${course.id} \u2022 ${course.ects} ECTS",
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  course.courseName,
                  style: textTheme.titleMedium?.copyWith(color: AppColors.textMain),
                ),
              ],
            )
          ),
          Expanded(
            flex: 1,
            child: Grade(
              grade: course.grade.toStringAsFixed(1),
              color: Colors.green
            )
          )
        ],
      )
    );
  }
}

class Grade extends StatelessWidget {
  final String grade;
  final Color color;

  const Grade({
    super.key,
    required this.grade,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme
        .of(context)
        .textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      decoration: BoxDecoration(
        border: BoxBorder.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(9),
        color: color.withAlpha(50),
      ),
      child: Text(
          grade,
          style: textTheme.bodySmall?.copyWith(color: color)
      ),
    );
  }
}

class ReviewCoursesPageViewmodel extends ChangeNotifier {
  ClientSession clientSession;

  ReviewCoursesPageViewmodel(this.clientSession) {
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
  final userRepo = UserRepository();
  final userId = clientSession.getUserID();
  if (userId == null) {
  _loading = false;
  notifyListeners();
  return;
  }

  final userTranscript = await repo.getTranscript(userId);
  final userDetails = await userRepo.getUserDetails(userId);
  final dto = userTranscriptToDashboardDTO(userTranscript, userDetails?.programLiteral);
  if (dto == null) {
  _loading = false;
  notifyListeners();
  return;
  }

  _gpa = dto.gpa ?? 0.0;
  _ects = dto.earnedCredits;
  _categories = dto.categories;
  _loading = false;
  notifyListeners();
  }
}
