import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';
import 'package:frontend/ui/widgets/AdaptiveSearchfield.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/theme/colors.dart';

class PlannerPage extends StatelessWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider<PlannerPageViewmodel>(
      create: (_) => PlannerPageViewmodel(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: AdaptiveSearchField(
            onChanged: (str) {},
          ),
        ),
        backgroundColor: colorScheme.surface,
        body: Consumer<PlannerPageViewmodel>(
          builder: (context, vm, child) {
            return Padding(
              padding: EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 20,
                  children: [
                    Row(
                      spacing: 16,
                      children: [
                        CreditsButton(
                          title: "Current Credits",
                          credits: 54,
                          modules: 6,
                          onPressed: () => context.push("/review-courses"),
                        ),
                        CreditsButton(
                          title: "Planned Credits",
                          credits: 66,
                          modules: 8,
                          onPressed: () => {},
                        )
                      ]
                    ),
                    SemesterSection(
                      title: "Current Semester",
                      period: "Fall 2024",
                      credits: 12,
                      expanded: true,
                    ),
                    SemesterSection(
                        title: "Next Semester",
                        period: "Spring 2025",
                        credits: 12
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

class CreditsButton extends StatelessWidget {
  final String title;
  final int credits;
  final int modules;
  final VoidCallback? onPressed;

  const CreditsButton({
    super.key,
    required this.title,
    required this.credits,
    required this.modules,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: AdaptiveButton(
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 10,
          children: [
            Text(title, style: textTheme.titleMedium?.copyWith(color: Colors.white)),
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: .center,
                  children: [
                    Text(credits.toString(), style: textTheme.headlineMedium?.copyWith(color: Colors.white)),
                    Text("ECTS", style: textTheme.titleSmall?.copyWith(color: Colors.white)),
                  ],
                ),
                Column(
                  crossAxisAlignment: .center,
                  children: [
                    Text(modules.toString(), style: textTheme.headlineMedium?.copyWith(color: Colors.white)),
                    Text("Modules", style: textTheme.titleSmall?.copyWith(color: Colors.white)),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SemesterSection extends StatefulWidget {
  final String title;
  final String period;
  final int credits;
  final bool? expanded;

  const SemesterSection({
    super.key,
    required this.title,
    required this.period,
    required this.credits,
    this.expanded,
  });

  @override
  State<SemesterSection> createState() => _SemesterSectionState();
}

class _SemesterSectionState extends State<SemesterSection> {
  late bool expanded = widget.expanded ?? false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      spacing: 20,
      children: [
        GestureDetector(
          onTap: () => setState(() {
            expanded = !expanded;
          }),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            crossAxisAlignment: .center,
            children: [
              Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                      widget.title,
                      style: textTheme.titleLarge?.copyWith(color: AppColors.textMain)
                  ),
                  Text(
                      widget.period,
                      style: textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: .end,
                children: [
                  Text(
                      widget.credits.toString(),
                      style: textTheme.titleLarge?.copyWith(color: AppColors.textMain)
                  ),
                  Text(
                      "ECTS",
                      style: textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)
                  ),
                ],
              ),
            ],
          ),
        ),
        if (expanded)
          Column(
            spacing: 20,
            children: [
              Container(
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
                    CourseItem(
                      name: "Deep Learning",
                      moduleNr: "AI301",
                      credits: 6
                    ),
                    CourseItem(
                      name: "Data Mining",
                      moduleNr: "DS202",
                      credits: 6
                    )
                  ]
                )
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: colorScheme.surfaceContainerHighest,
                          width: 3
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.textMain,
                        shape: RoundedRectangleBorder(
                            borderRadius: .circular(13)
                        )
                      ),
                      child: Text(
                        "+ Add Module",
                        style: textTheme.titleMedium?.copyWith(color: AppColors.textMain)
                      ),
                    )
                  )
                ],
              )
            ]
          )
      ],
    );
  }
}

class CourseItem extends StatelessWidget {
  final String name;
  final String moduleNr;
  final int credits;

  const CourseItem({
    super.key,
    required this.name,
    required this.moduleNr,
    required this.credits,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: colorScheme.surface,
        ),
        padding: EdgeInsets.fromLTRB(24, 10, 14, 10),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                    name,
                    style: textTheme.bodyLarge?.copyWith(color: AppColors.textMain)
                ),
                Text(
                    "$moduleNr • $credits ECTS",
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => {},
                  icon: SvgPicture.asset('assets/icons/check-button-green.svg'),
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                ),
                IconButton(
                  onPressed: () => {},
                  icon: SvgPicture.asset('assets/icons/trash-red.svg'),
                  style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                )
              ],
            )
          ],
        )
    );
  }
}

class PlannerPageViewmodel extends ChangeNotifier {

}
