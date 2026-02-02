import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';
import 'package:frontend/ui/widgets/CourseCard/CourseCard_styles.dart';
import 'package:provider/provider.dart';
import 'package:frontend/theme/colors.dart';
import 'package:frontend/ui/widgets/Chip.dart';

class CourseDetailsPage extends StatelessWidget {
  const CourseDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider<CourseDetailsPageViewmodel>(
      create: (_) => CourseDetailsPageViewmodel(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Module Details"),
        ),
        backgroundColor: colorScheme.surface,
        body: Consumer<CourseDetailsPageViewmodel>(
          builder: (context, vm, child) {
            final isFavorite = vm.isFavorite;
            return Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: .start,
                        spacing: 24,
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  mainAxisAlignment: .spaceBetween,
                                  children: [
                                    Text("Algorithm", style: textTheme.headlineSmall),
                                    Text("6", style: textTheme.headlineSmall)
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: .spaceBetween,
                                children: [
                                  Text("CS201", style: textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)),
                                  Text("ECTS", style: textTheme.titleMedium?.copyWith(color: AppColors.textSecondary))
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisAlignment: .spaceBetween,
                                  children: [
                                    Flexible(
                                      child: ChipWidget(label: "Recommended for you - 88% match", color: Colors.green),
                                    ),
                                    InkWell(
                                      onTap: () {},
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Section(
                            title: "Description",
                            children: [
                              Text(
                                "This comprehensive course covers advanced concepts and practical applications in algorithm. Students will gain hands-on experience through projects and assignments, developing both theoretical understanding and practical skills essential for modern software development.",
                                style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                                textAlign: .justify,
                              )
                            ],
                          ),
                          Section(
                            title: "Prerequisites",
                            children: [
                              Text(
                                "\u2022 Introduction to Programming",
                                style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                              ),
                              Text(
                                "\u2022 Data Structures",
                                style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          Section(
                            title: "Student feedback",
                            rightContent: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amberAccent,
                                ),
                                Text(
                                  "4.5",
                                  style: textTheme.titleMedium?.copyWith(color: AppColors.textMain),
                                ),
                              ],
                            ),
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                decoration: BoxDecoration(
                                  border: BoxBorder.all(color: colorScheme.surfaceContainer, width: 1),
                                  borderRadius: BorderRadius.circular(13),
                                  color: Colors.white,
                                ),
                                child:
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
                                              "assets/icons/speech-bubble-blue.svg",
                                              width: 24,
                                              height: 24,
                                            ),
                                          ],
                                        )
                                      ),
                                    ),
                                    Expanded( 
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "View all feedback",
                                              style: textTheme.titleMedium?.copyWith(color: AppColors.textMain),
                                            ),
                                            Text(
                                              "See what other students are saying",
                                              style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ),
                            ]
                          ),
                          IntrinsicHeight(
                            child: Row(
                              spacing: 21,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                DetailCard(value: "85%", item: "Pass Rate"),
                                DetailCard(value: "120", item: "Students"),
                                DetailCard(value: "12", item: "Weeks"),
                              ],
                            ),
                          ),
                        ]
                      )
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Column(
                      children: [
                        IntrinsicHeight( 
                          child: Row(
                            spacing: 12,
                            crossAxisAlignment: CrossAxisAlignment.stretch, 
                            children: [
                              Expanded(
                                child: AdaptiveButton(
                                  onPressed: () {},
                                  child: Center( 
                                    child: Text(
                                      "+ Add to Plan",
                                      style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: AdaptiveButton(
                                  onPressed: () {},
                                  child: Center(
                                    child: Text(
                                      "+ Give Feedback",
                                      style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
            );
          },
        ),
      ),
    );
  }
}

class Section extends StatelessWidget {
  final String? title;
  final Widget? rightContent;
  final List<Widget> children;

  const Section({
    super.key,
    this.title,
    this.rightContent,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        if (title != null)
          Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  title!,
                  style: textTheme.titleMedium?.copyWith(color: AppColors.textMain),
                ),
                if (rightContent != null)
                  rightContent!
              ],
            ),
          ),
        ...children
      ],
    );
  }
}

class DetailCard extends StatelessWidget {
  final String value;
  final String item;

  const DetailCard({
    super.key,
    required this.value,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Text(value, style: textTheme.headlineSmall),
            ),
            Text(item, style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
          ],
        )
      ),
    );
  }
}

class CourseDetailsPageViewmodel extends ChangeNotifier {
  bool isFavorite = false;
}

