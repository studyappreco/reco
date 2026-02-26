import 'package:flutter/material.dart';
import 'package:frontend/models/Module.dart';
import 'package:frontend/models/TranscriptDocument.dart';
import 'package:frontend/repos/CourseSearchRepo.dart';
import 'package:frontend/repos/TranscriptRepository.dart';
import 'package:frontend/theme/colors.dart';
import 'package:frontend/ui/utils/auth.dart';
import 'package:frontend/ui/widgets/AdaptiveSearchfield.dart';
import 'package:frontend/utils/RecoLog.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final String userID = context.read<ClientSession>().getUserID() ?? "";

    return ChangeNotifierProvider<FeedbackPageViewmodel>(
      create: (_) => FeedbackPageViewmodel(context.read(), context.read(), userID),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Module Feedback"),
        ),
        backgroundColor: colorScheme.surface,
        body: Consumer<FeedbackPageViewmodel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16.0, bottom: 24.0),
                    child: AdaptiveSearchField(
                      hintText: "Search your modules...",
                      showFilter: false,
                      onChanged: vm.updateSearchQuery,
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [

                        // Awaiting Feedback
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: Theme( // https://stackoverflow.com/questions/49557555/custom-style-or-theme-for-expansion-tile-header-flutter
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            // https://api.flutter.dev/flutter/material/ExpansionTile-class.html
                            child: ExpansionTile(
                              initiallyExpanded: true,
                              tilePadding: EdgeInsets.symmetric(horizontal: 16),
                              title: Center(
                                child: Text(
                                  "Awaiting Feedback",
                                  style: textTheme.titleMedium?.copyWith(color: AppColors.textMain),
                                ),
                              ),
                              childrenPadding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                              children: vm.filteredAwaiting.isEmpty
                                ? [
                                    Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        "There are no modules where you can give feedback",
                                        style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  ]
                                : vm.filteredAwaiting.map((module) {

                                    return Padding(
                                      padding: EdgeInsets.only(top: 12.0),
                                      child: GestureDetector(
                                        onTap: () async {
                                          await context.push('/feedback/course-details', extra: module.moduleNr);
                                          vm.loadData(); 
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFFF9FAFB),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.all(16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.only(right: 16.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        module.title,
                                                        style: textTheme.titleMedium?.copyWith(color: AppColors.textMain),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 4.0),
                                                        child: Text(
                                                          "${module.moduleNr} • ${module.credits} ECTS",
                                                          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.star_border, color: AppColors.star, size: 24),
                                                  Padding(
                                                    padding: EdgeInsets.only(left: 6.0),
                                                    child: Text("---", style: textTheme.titleMedium?.copyWith(color: AppColors.textMain)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                        
                        //  My Feedbacks
                        Padding(
                          padding: EdgeInsets.only(top: 16, bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: AppColors.border, width: 1),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                initiallyExpanded: true,
                                tilePadding: EdgeInsets.symmetric(horizontal: 16),
                                title: Center(
                                  child: Text(
                                    "My Feedbacks",
                                    style: textTheme.titleMedium?.copyWith(color: AppColors.textMain),
                                  ),
                                ),
                                childrenPadding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                children: vm.filteredReviewed.isEmpty
                                  ? [
                                      Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                          "You haven't given any module feedback yet",
                                          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ]
                                  : vm.filteredReviewed.map((module) {
                                      final userFeedback = module.feedbacks.where((f) => f.userId == userID).firstOrNull;

                                      return Padding(
                                        padding: EdgeInsets.only(top: 12.0),
                                        child: GestureDetector(
                                          onTap: () async {
                                            await context.push('/feedback/course-details', extra: module.moduleNr);
                                            vm.loadData(); 
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF9FAFB),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            padding: EdgeInsets.all(16),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(right: 16.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          module.title,
                                                          style: textTheme.titleMedium?.copyWith(color: AppColors.textMain),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.only(top: 4.0),
                                                          child: Text(
                                                            "${module.moduleNr} • ${module.credits} ECTS",
                                                            style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.star, color: AppColors.star, size: 24),
                                                    Padding(
                                                      padding: EdgeInsets.only(left: 6.0),
                                                      child: Text(
                                                        "${userFeedback?.rating.toStringAsFixed(1)}",
                                                        style: textTheme.titleMedium?.copyWith(color: AppColors.textMain),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class FeedbackPageViewmodel extends ChangeNotifier {
  final TranscriptRepository transcriptRepo;
  final CourseSearchRepo courseRepo;
  final String userID;

  bool isLoading = true;

  List<Module> _allAwaiting = [];
  List<Module> _allReviewed = [];

  List<Module> filteredAwaiting = [];
  List<Module> filteredReviewed = [];

  String _searchQuery = "";

  FeedbackPageViewmodel(this.transcriptRepo, this.courseRepo, this.userID) {
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      final transcript = await transcriptRepo.getTranscript(userID: userID);

      Map<String, String> transcriptModules = {};

      if(transcript != null){

        void traverse(TranscriptNode node){
          if(node.courses != null){
            for(var c in node.courses!){
              transcriptModules[c.id] = c.courseName; 
            }
          }
          if(node.children != null){
            for(var child in node.children!){
              traverse(child);
            }
          }
        }

        for(var root in transcript.transcript.children){
          traverse(root);
        }
      }

      if(transcriptModules.isEmpty){
        _allAwaiting = [];
        _allReviewed = [];
        _applyFilter();
        return;
      }

      // First searching  the modules by moduleNr
      List<String> moduleNrs = transcriptModules.keys.toList();
      List<Module> userModules = await courseRepo.getModulesByModuleNrs(moduleNrs, userID);

      // Fallback for PDF uploads: As the official transcript does not contain 
      // module numbers like in Moses, we match these remaining modules by using their names
      // TODO I used Set here because we can currently mark modules that have already been passed as passed again in the database, we should definitely adjust that there after the presentation
      Set<String> foundIds = userModules.map((m) => m.moduleNr).toSet();
      List<String> missingNames = [];

      for(var entry in transcriptModules.entries){
        if(!foundIds.contains(entry.key) && entry.value.isNotEmpty) {
          missingNames.add(entry.value);
        }
      }

      // getting missing modules by title
      if(missingNames.isNotEmpty){
        RecoLog.info("Fallback: Searching ${missingNames.length} missing modules by titel");
        List<Module> fallbackModules = await courseRepo.getModulesByTitles(missingNames, userID);
        userModules.addAll(fallbackModules);
      }

      List<Module> awaiting = [];
      List<Module> reviewed = [];

      // checking if there is already feedback from users for these modules and sorting them into the respective list
      for(var module in userModules){
        final hasReviewed = module.feedbacks.any((f) => f.userId == userID);

        if(hasReviewed){
          reviewed.add(module);
        } else {
          awaiting.add(module);
        }
      }

      _allAwaiting = awaiting;
      _allReviewed = reviewed;
      _applyFilter();

    } catch (e, s) {
      RecoLog.error("Error loading feedback page data", e, s);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  void _applyFilter() {
    if(_searchQuery.isEmpty){
      filteredAwaiting = List.from(_allAwaiting);
      filteredReviewed = List.from(_allReviewed);
    } else {
      final q = _searchQuery.toLowerCase();
      
      bool matches(Module m) => m.title.toLowerCase().contains(q) || m.moduleNr.toLowerCase().contains(q);

      filteredAwaiting = _allAwaiting.where(matches).toList();
      filteredReviewed = _allReviewed.where(matches).toList();
    }
    notifyListeners();
  }
}