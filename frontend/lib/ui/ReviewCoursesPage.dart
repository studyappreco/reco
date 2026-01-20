import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      create: (_) => ReviewCoursesPageViewmodel(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Review Your courses"),
        ),
        backgroundColor: colorScheme.surface,
        body: Consumer<ReviewCoursesPageViewmodel>(
          builder: (context, vm, child) {
            return Padding(
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
                              Text("3.7", style: textTheme.headlineMedium?.copyWith(color: AppColors.primaryBlue)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 4.0),
                                child: Text("Total ECTS", style: textTheme.titleSmall?.copyWith(color: AppColors.primaryBlue)),
                              ),
                              Text("120", style: textTheme.headlineMedium?.copyWith(color: AppColors.primaryBlue)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    CourseCategoryCard(
                      name: "Information Systems",
                      courses: [
                        Course(
                          name: "Data Structures",
                          moduleNr: "CS101",
                          credits: 4,
                          grade: "A"
                        ),
                        Course(
                          name: "Algorithms",
                          moduleNr: "CS202",
                          credits: 4,
                          grade: "A-"
                        ),
                        Course(
                          name: "Database Systems",
                          moduleNr: "CS150",
                          credits: 3,
                          grade: "B+"
                        ),
                        Course(
                          name: "Web Development",
                          moduleNr: "CS180",
                          credits: 3,
                          grade: "A"
                        )
                      ],
                      requiredCredits: 30,
                    ),
                    CourseCategoryCard(
                      name: "Computer Science",
                      courses: [],
                      requiredCredits: 18,
                    ),
                    CourseCategoryCard(
                      name: "Business/Economics",
                      courses: [],
                      requiredCredits: 30,
                    ),
                    CourseCategoryCard(
                      name: "Free Choice",
                      courses: [],
                      requiredCredits: 30,
                    ),
                    CourseOverview(),
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
  final String name;
  final List<Course> courses;
  final int requiredCredits;

  const CourseCategoryCard({
    super.key,
    required this.name,
    required this.courses,
    required this.requiredCredits,
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

    final coursesLabel = widget.courses.length == 1 ? "course" : "courses";
    final currentCredits = widget.courses.isNotEmpty
        ? widget.courses.map((c) => c.credits).reduce((c1, c2) => c1 + c2)
        : 0;

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
                            widget.name,
                            style: textTheme.titleMedium?.copyWith(color: AppColors.textMain),
                          ),
                          Text(
                            "${widget.courses.length} $coursesLabel \u2022 $currentCredits/${widget.requiredCredits} ECTS",
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
                  children: widget.courses.asMap().entries.map((c) {
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
  final Course course;
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
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                "${course.moduleNr} \u2022 ${course.credits} ECTS",
                style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                course.name,
                style: textTheme.titleMedium?.copyWith(color: AppColors.textMain),
              ),
            ],
          ),
          Grade(grade: course.grade, color: Colors.green)
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
    final textTheme = Theme.of(context).textTheme;

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

class Course {
  final String name;
  final String moduleNr;
  final int credits;
  final String grade;

  const Course({
    required this.name,
    required this.moduleNr,
    required this.credits,
    required this.grade
  });
}

class ReviewCoursesPageViewmodel extends ChangeNotifier {

}
