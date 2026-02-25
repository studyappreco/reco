import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/models/Module.dart';
import 'package:frontend/repos/CourseSearchRepo.dart';
import 'package:frontend/repos/TranscriptRepository.dart';
import 'package:frontend/repos/UserRepository.dart';
import 'package:frontend/repos/transcriptUtils.dart'; 
import 'package:frontend/ui/utils/auth.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';
import 'package:frontend/ui/widgets/StatusMessage/StatusMessage.dart';
import 'package:frontend/utils/RecoLog.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/theme/colors.dart';

class PlannerPage extends StatelessWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final String userID = context.read<ClientSession>().getUserID() ?? "";

    return ChangeNotifierProvider<PlannerPageViewmodel>(
      create: (_) => PlannerPageViewmodel(context.read(), context.read(), context.read(), userID),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Planner"),
        ),
        backgroundColor: colorScheme.surface,
        body: Consumer<PlannerPageViewmodel>(
          builder: (context, vm, child) {
            if(vm.isLoading){
              return Center(child: CircularProgressIndicator());
            }

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
                          credits: vm.earnedCredits,
                          modules: vm.earnedModulesCount, 
                          onPressed: () => context.push("/review-courses"),
                        ),
                        CreditsButton(
                          title: "Planned Credits",
                          credits: vm.totalPlannedCredits,
                          modules: vm.totalPlannedCount,
                          onPressed: () {},
                        )
                      ]
                    ),
                    SemesterSection(
                      title: "Current Semester",
                      period: "Fall 2024", //TODO
                      credits: vm.plannedCurrentCredits,
                      expanded: true,
                      modules: vm.plannedModulesCurrent,
                      onFinishModule: (mod) => vm.showaddModuleDialog(context, mod),
                      onRemoveModule: (mod) => vm.removeModule(context, mod),
                      addButtonOnTop: true,
                    ),

                    SemesterSection(
                        title: "Next Semester",
                        period: "Spring 2025", //TODO
                        credits: vm.plannedNextCredits,
                        expanded: true,
                        modules: vm.plannedModulesNext,
                        onFinishModule: (mod) => vm.showaddModuleDialog(context, mod),
                        onRemoveModule: (mod) => vm.removeModule(context, mod),
                        showAddButton: false,
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
  final List<Module> modules;
  final Function(Module) onFinishModule;
  final Function(Module) onRemoveModule;
  final bool showAddButton;
  final bool addButtonOnTop;

  const SemesterSection({
    super.key,
    required this.title,
    required this.period,
    required this.credits,
    this.expanded,
    required this.modules,
    required this.onFinishModule,
    required this.onRemoveModule,
    this.showAddButton = true,
    this.addButtonOnTop = false
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
        if (widget.showAddButton && widget.addButtonOnTop)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/search'),
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
          ),
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
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
              if(widget.modules.isNotEmpty)
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
                    children: widget.modules.map((module) {
                      return CourseItem(
                        module: module,
                        onCheck: () => widget.onFinishModule(module),
                        onTrash: () => widget.onRemoveModule(module),
                      );
                    }).toList(),
                  )
                )
              else
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text("No courses planned in this section."),
                ),
              
              if (widget.showAddButton && !widget.addButtonOnTop)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.go('/search'),
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
  final Module module;
  final VoidCallback onCheck;
  final VoidCallback onTrash;

  const CourseItem({
    super.key,
    required this.module,
    required this.onCheck,
    required this.onTrash
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
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    module.title,
                    style: textTheme.bodyLarge?.copyWith(color: AppColors.textMain)
                    ),
                  Text(
                    "${module.moduleNr} • ${module.credits} ECTS",
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)
                    ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: onCheck,
                  icon: SvgPicture.asset('assets/icons/check-button-green.svg'), 
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                    ),
                ),
                IconButton(
                  onPressed: onTrash,
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
  final TranscriptRepository transcriptRepo;
  final UserRepository userRepo;
  final CourseSearchRepo courseRepo;
  final String userID;

  PlannerPageViewmodel(
    this.transcriptRepo,
    this.userRepo,
    this.courseRepo,
    this.userID
  ) {
    _loadData();
  }

  bool isLoading = true;
  int earnedCredits = 0;
  int earnedModulesCount = 0; 
  
  List<Module> plannedModulesCurrent = [];
  List<Module> plannedModulesNext = [];
  
  List<OverviewCategory> availableCategories = []; 

  int get plannedCurrentCredits => _calculateCredits(plannedModulesCurrent);
  int get plannedNextCredits    => _calculateCredits(plannedModulesNext);
  int get totalPlannedCredits   => plannedCurrentCredits + plannedNextCredits;
  int get totalPlannedCount     => plannedModulesCurrent.length + plannedModulesNext.length;

  int _calculateCredits(List<Module> modules){
    int sum = 0;
    for(var module in modules){
      int credits = int.parse(module.credits);
      sum += credits;
    }
    return sum;
  }

  Future<void> _loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      if(userID.isEmpty) return;

      final userTranscript = await transcriptRepo.getTranscript(userID: userID, forceRefresh: false);
      final userDetails = await userRepo.getUserDetails(userID);
      if(userTranscript != null){
        final dashboardDTO = userTranscriptToDashboardDTO(userTranscript, userDetails?.programLiteral);
        if(dashboardDTO != null){
          earnedCredits = dashboardDTO.earnedCredits;
          earnedModulesCount = dashboardDTO.completedCoursesCount;
          availableCategories = dashboardDTO.categories;
        }
      }

      final plannedmodule = await userRepo.getPlannedModulesStruct(userID);
      final currentIDs = plannedmodule['current']!;
      final nextIDs = plannedmodule['next']!;

      final allPlannedIDs = [...currentIDs, ...nextIDs];
      final List<Module> allPlannedModules = await courseRepo.getModulesByModuleNrs(allPlannedIDs, userID);

      plannedModulesCurrent = allPlannedModules.where((m) => currentIDs.contains(m.moduleNr)).toList();
      plannedModulesNext = allPlannedModules.where((m) => nextIDs.contains(m.moduleNr)).toList();

    } catch (e, s) {
      RecoLog.error("Error loading Planner Data", e, s);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeModule(BuildContext context, Module module) async {
    await userRepo.removePlannedModule(userID, module.moduleNr);
    await _loadData(); 
    
    if (!context.mounted) return;
    StatusMessage.show(
      context: context,
      alignment: SnackAlignment.TOP,
      title: "Success",
      message: "Removed from Planner",
      isError: false,
      duration: Duration(seconds: 2),
    );
  }


  void showaddModuleDialog(BuildContext context, Module module) {
    final gradeController = TextEditingController();
    final dateController = TextEditingController();
    dateController.text = "${DateTime.now().day.toString().padLeft(2, '0')}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().year}";

    String? selectedCategoryId = availableCategories.isNotEmpty ? availableCategories.first.id : null;
    String? errorText;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // https://api.flutter.dev/flutter/material/AlertDialog-class.html
            return AlertDialog(
              title: Text("Complete Module"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // small titel text
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text("Enter details for ${module.title}"),
                    ),
                    
                    // Grade Input
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextField(
                        controller: gradeController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: "Grade (1.0 - 5.0)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                    // Exam Date
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: TextField(
                        controller: dateController,
                        readOnly: true, 
                        decoration: InputDecoration(
                          labelText: "Exam Date",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(   // https://api.flutter.dev/flutter/material/showDatePicker.html TODO IOS style add
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if(pickedDate != null){
                            setState(() {
                               dateController.text = "${pickedDate.day.toString().padLeft(2, '0')}.${pickedDate.month.toString().padLeft(2, '0')}.${pickedDate.year}";
                            });
                          }
                        },
                      ),
                    ),
                    
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedCategoryId,
                      decoration: InputDecoration(
                        labelText: "Transcript Category",
                        border: OutlineInputBorder(),
                      ),
                      items: availableCategories.map((cat) {
                        return DropdownMenuItem(
                          value: cat.id, 
                          child: Text(cat.name)
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedCategoryId = val),
                    ),
                    
                    if(errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          errorText!,
                          style: TextStyle(color: AppColors.red, fontSize: 13),
                        ),
                      )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: Text("Cancel")
                ),
                AdaptiveButton(
                  onPressed: () async {
                    final gradeText = gradeController.text.replaceAll(',', '.');
                    final dateText = dateController.text;
                    final grade = double.tryParse(gradeText);

                    if(grade == null || grade < 1.0 || grade > 5.0 || selectedCategoryId == null || dateText.isEmpty){
                      setState(() {
                        errorText = "Please check grade (1.0-5.0), date, and category.";
                      });
                      return; 
                    }
                    
                    Navigator.pop(context); 
                    await _finishModule(context, module, grade, selectedCategoryId!, dateText); 
                  },
                  child: Text("Save to Transcript"),
                )
              ],
            );
          }
        );
      }
    );
  }

  Future<void> _finishModule(BuildContext context, Module module, double grade, String categoryId, String examDate) async {
    isLoading = true;
    notifyListeners();

    bool success = await userRepo.markModuleAsCompleted(
      userID: userID,
      module: module,
      grade: grade,
      categoryId: categoryId,
      examDate: examDate,
    );

    if(success){
      await userRepo.removePlannedModule(userID, module.moduleNr);
      await _loadData();
      
      if (!context.mounted) return;
      StatusMessage.show(
        context: context,
        alignment: SnackAlignment.TOP,
        title: "Success",
        message: "Module Completed & Saved",
        isError: false,
        duration: Duration(seconds: 3),
      );

    } else {
      RecoLog.error("Could not save to transcript");
      isLoading = false;
      notifyListeners();
      
      if (!context.mounted) return;
      StatusMessage.show(
        context: context,
        alignment: SnackAlignment.CENTER,
        title: "Error",
        message: "Could not save to transcript",
        isError: true,
      );
    }
  }
}
