import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/models/Module.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';
import 'package:provider/provider.dart';
import 'package:frontend/theme/colors.dart';
import 'package:frontend/ui/widgets/Chip.dart';
import 'package:frontend/ui/widgets/StatusMessage/StatusMessage.dart'; 
import 'package:frontend/ui/widgets/StatusMessage/StatusMessageCard.dart'; 
import 'package:frontend/ui/utils/auth.dart';
import 'package:frontend/ui/widgets/AnimatedIconButton.dart';
import 'package:frontend/repos/CourseSearchRepo.dart';
import 'package:frontend/repos/UserRepository.dart';
import 'package:frontend/utils/RecoLog.dart';
import 'package:go_router/go_router.dart';

class CourseDetailsPage extends StatelessWidget {
  final String moduleNr; 

  const CourseDetailsPage({super.key, required this.moduleNr});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final String userID = context.read<ClientSession>().getUserID() ?? "";

    return ChangeNotifierProvider<CourseDetailsPageViewmodel>(
      create: (_) => CourseDetailsPageViewmodel(context.read(), context.read(), moduleNr, userID),
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
                                      child: vm.module!.isRecommended
                                        ? ChipWidget(label: "Recommended for you", color: Colors.green)
                                        : SizedBox.shrink(),
                                    ),
                                    AnimatedIconButton(
                                      isSelected: vm.module!.isFavorite,
                                      onTap: () => vm.toggleFavorite(context),
                                      icon: Icons.favorite_border,
                                      selectedIcon: Icons.favorite,
                                      activeColor: AppColors.pink,
                                      activeBackgroundColor: AppColors.pinkLight,
                                      inactiveColor: AppColors.pink,
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
                                      vm.module!.isPlanned ? "- Remove from Planner" : "+ Add to Planner",
                                      style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: AdaptiveButton(
                                  onPressed: () => context.push(
                                    '${GoRouterState.of(context).uri.path}/give-feedback',
                                    extra: {
                                      'title': vm.module!.title,
                                      'credits': vm.module!.credits,
                                      'moduleNr': vm.module!.moduleNr,
                                    },
                                  ),
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
  final UserRepository userRepo;
  final CourseSearchRepo courseRepo;
  final String moduleNr;
  final String userID;

  Module? module;
  bool isLoading = true;
  String? errorMessage;

  CourseDetailsPageViewmodel(
    this.userRepo,
    this.courseRepo,
    this.moduleNr,
    this.userID
  ){
    _loadModule();
  }
  
  Future<void> _loadModule() async{
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    // should not be empty
    if(userID.isEmpty){
      RecoLog.error("UserID is empty");
        errorMessage = "UserID is empty";
        isLoading = false;
        notifyListeners();
        return;
    }

    try{
      module = await courseRepo.getModuleByNumber(moduleNr, userID);
      if(module == null){
        RecoLog.warning("Module $moduleNr not found");
        errorMessage = "Module with ID $moduleNr not found.";
      } else {
        RecoLog.info("Module ${module!.title} loaded successfully");
      }

    } catch (e, s){
      RecoLog.error("Error loading module $moduleNr", e, s);
      errorMessage = "Error loading module: $e";
      module = null;
    } finally{
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePlanned(BuildContext context) async {
    
    if(module == null){
      RecoLog.error("Cannot toggle planned. Module is null");
      return;
    }
    if(userID.isEmpty){
      RecoLog.error("Cannot toggle planned. UserID is empty");
      StatusMessage.show(
        context: context,
        alignment: SnackAlignment.CENTER,
        title: "RecoLogin Required",
        message: "You must be RecoLogged in.",
        isError: true,
      );
      return;
    }

    if(module!.isPlanned){
      module!.isPlanned = false;
      notifyListeners(); 
      try {
        await userRepo.removePlannedModule(userID, moduleNr);
        RecoLog.info("Planned status removed from DB");
        

      } catch (e, s) {
        RecoLog.error("DB Error removing plan:", e, s);
        module!.isPlanned = true;
        notifyListeners();
        
        if (!context.mounted) return;
        StatusMessage.show(
          context: context,
          alignment: SnackAlignment.CENTER,
          title: "Error",
          message: "Could not remove from planner",
          isError: true,
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          // https://api.flutter.dev/flutter/material/SimpleDiaRecoLog-class.html
          return SimpleDialog(
            title: Text("Add to Planner"),
            children: [
              SimpleDialogOption(
                padding: EdgeInsets.all(16),
                child: Text("Add to Current Semester"),
                onPressed: () async {
                  Navigator.pop(context);
                  await _savePlanned(context, true);
                },
              ),
              SimpleDialogOption(
                padding: EdgeInsets.all(16),
                child: Text("Add to Next Semester"),
                onPressed: () async {
                  Navigator.pop(context);
                  await _savePlanned(context, false);
                },
              ),
            ],
          );
        }
      );
    }
  }

  Future<void> _savePlanned(BuildContext context, bool isCurrent) async {
    module!.isPlanned = true;
    notifyListeners();
    try {
      await userRepo.togglePlannedModule(userID, moduleNr, isCurrent);
      RecoLog.info("Planned status added to DB (${isCurrent ? 'Current' : 'Next'})");
      

    } catch (e, s) {
       RecoLog.error("DB Error adding plan:", e, s);
       module!.isPlanned = false;
       notifyListeners();
       
       if (!context.mounted) return;
       StatusMessage.show(
        context: context,
        alignment: SnackAlignment.CENTER,
        title: "Error",
        message: "Could not save to planner",
        isError: true,
      );
    }
  }

  Future<void> toggleFavorite(BuildContext context) async {

    if(module == null){
      RecoLog.error("Cannot toggle favorite. Module is null");
      return;
    }
    if(userID.isEmpty){
      StatusMessage.show(
        context: context,
        alignment: SnackAlignment.CENTER,
        title: "RecoLogin Required",
        message: "You must be RecoLogged in.",
        isError: true,
      );
      return;
    }
    module!.isFavorite = !module!.isFavorite;
    notifyListeners();

    try {
      await userRepo.toggleFavoriteModule(userID, moduleNr);
      RecoLog.info("Favorite status updated in DB");
      

    } catch (e, s) {
      RecoLog.error("DB Error:", e, s);
      module!.isFavorite = !module!.isFavorite;
      notifyListeners();
      
      if (!context.mounted) return;
      StatusMessage.show(
        context: context,
        alignment: SnackAlignment.CENTER,
        title: "Error",
        message: "Could not update favorites",
        isError: true,
      );
    }
  }
}