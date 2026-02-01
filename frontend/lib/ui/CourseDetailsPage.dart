import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/models/Module.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';
import 'package:frontend/ui/widgets/CourseCard/CourseCard_styles.dart';
import 'package:provider/provider.dart';
import 'package:frontend/theme/colors.dart';
import 'package:frontend/ui/widgets/Chip.dart';
import 'package:frontend/ui/widgets/StatusMessage/StatusMessageCard.dart'; 
import 'package:frontend/ui/utils/auth.dart';
import 'package:frontend/repos/CourseSearchRepo.dart';
import 'package:frontend/repos/UserRepository.dart';

class CourseDetailsPage extends StatelessWidget {
  final String moduleNr; 

  const CourseDetailsPage({super.key, required this.moduleNr});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider<CourseDetailsPageViewmodel>(
      create: (_) => CourseDetailsPageViewmodel(moduleNr),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Module Details"),
        ),
        backgroundColor: colorScheme.surface,
        body: Consumer<CourseDetailsPageViewmodel>(
          builder: (context, vm, child) {
            // Loading status
            if(vm.isLoading){
              return Center(child: CircularProgressIndicator());
            }
            // error
            if(vm.module == null){
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusMessageCard(
                        isError: true,
                        title: "Error during loading",
                        message: vm.errorMessage ?? "The module could not be found",
                        onClose: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
            // Display data
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
                                    Flexible(
                                      child: Text(vm.module!.title, style: textTheme.headlineSmall)
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Text(vm.module!.credits, style: textTheme.headlineSmall),
                                    )
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: .spaceBetween,
                                children: [
                                  Text(vm.module!.moduleNr, style: textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)),
                                  Text("ECTS", style: textTheme.titleMedium?.copyWith(color: AppColors.textSecondary))
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisAlignment: .spaceBetween,
                                  children: [
                                    Flexible(
                                      child: ChipWidget(label: "Recommended for you - ${vm.module!.matchPercentage}% match", color: Colors.green),
                                    ),
                                    InkWell(
                                      onTap: () => vm.toggleFavorite(context),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: CourseCardStyles.getFavoriteDecoration(isActive: vm.module!.isFavorite),
                                        child: Icon(
                                          vm.module!.isFavorite ? Icons.favorite : Icons.favorite_border,
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
                          if(vm.module!.courseSummary != null && vm.module!.courseSummary!.isNotEmpty)
                            Section(
                              title: "Description",
                              children: [
                                Text(
                                  vm.module!.courseSummary!,
                                  style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                                  textAlign: .justify,
                                )
                              ],
                            ),

                            // TODO missing in DB
                            Section(
                            title: "Prerequisites",
                              children: [
                                Text(
                                "Missing",
                                style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                              ),
                              Text(
                                ".....",
                                  style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),

                          if(vm.module!.learnResult != null && vm.module!.learnResult!.isNotEmpty)
                            Section(
                              title: "Learning Outcomes",
                              children: [
                                Text(
                                  vm.module!.learnResult!,
                                  style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                                  textAlign: .justify,
                                )
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
                                  vm.module!.rating != null ? vm.module!.rating.toString() : "-",
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
                                DetailCard(value: vm.module!.passRate, item: "Pass Rate"),
                                DetailCard(value: "${vm.module!.students}", item: "Students"),
                                DetailCard(value: vm.module!.duration, item: "Weeks"),
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
                                  onPressed: () => vm.togglePlanned(context),
                                  child: Center( 
                                    child: Text(
                                      vm.module!.isPlanned ? "- Remove from Plan" : "+ Add to Plan",
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
  final String moduleNr;
  Module? module;
  bool isLoading = true;
  String? errorMessage;
  final UserRepository _userRepo = UserRepository();

  CourseDetailsPageViewmodel(this.moduleNr){
    _loadModule();
  }
  
  Future<void> _loadModule() async{
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try{
      module = await CourseSearchRepo().getModuleByNumber(moduleNr);
      if(module == null){
        errorMessage = "Module with ID $moduleNr not found.";
      }

    } catch (e){
      print("Error loading module: $e");
      errorMessage = "Error loading module: $e";
      module = null;
    } finally{
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePlanned(BuildContext context) async {
    
    if(module == null) return;
    module!.isPlanned = !module!.isPlanned;
    notifyListeners(); 

    final String? userId = context.read<ClientSession>().getUserID();

    if(userId == null) return;

    try {
      // Updating the database
      await _userRepo.togglePlannedModule(userId, moduleNr);
      print("Planned status updated in DB");
    } catch (e) {
      print("DB Error: $e");
      module!.isPlanned = !module!.isPlanned;
      notifyListeners();
      // TODO maybe a status alert error should be displayed
    }
  }

  Future<void> toggleFavorite(BuildContext context) async {
    
    if(module == null) return;
    module!.isFavorite = !module!.isFavorite;
    notifyListeners();

    final String? userId = context.read<ClientSession>().getUserID();

    if(userId == null) return;

    try {
      // Updating the database
      await _userRepo.toggleFavoriteModule(userId, moduleNr);
      print("Favorite status updated in DB");
    } catch (e) {
      print("DB Error: $e");
      module!.isFavorite = !module!.isFavorite;
      notifyListeners();
      // TODO maybe a status alert error should be displayed
    }
  }
}