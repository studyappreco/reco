
import 'package:frontend/models/UserTrancript.dart';
import 'package:frontend/models/TranscriptDocument.dart';
import 'package:frontend/repos/transcriptUtils.dart';

class CSBTranscript {

  static int programEcts = 180;

  // important: have to match with the prompt
  static Map<String, int> ectsForCategories = {
    "compulsory_electives" : 135,
    "compulsory_modules" : 30,
    "free_electives": 18
  };

  // important: have to match with the prompt
  static Map<String, String> categoriesForDashboard = {
    "free_electives" : "Free Electives",
    "compulsory_electives" : "Compulsory Electives",
    "compulsory_modules" : "Compulsory Modules"
  };

  static List<OverviewCategory> getOverviewCategories(UserTranscript ismTranscript) {
    List<OverviewCategory> dashBoardcategories = [];

    categoriesForDashboard.forEach((key, val) {
      TranscriptNode? found = findNodeByName(key, ismTranscript);
      if (found != null) {
        int earnedEcts = found.courses?.fold<int>(0, (sum, c) => sum + c.ects) ?? 0;
        int requiredEcts = ectsForCategories[key]!;
        double progress = requiredEcts > 0 ? (earnedEcts / requiredEcts).clamp(0.0, 1.0) : 0.0;
        dashBoardcategories.add(OverviewCategory(
          name: val,
          progress: progress,
          categoryEcts: requiredEcts,
          courses: found.courses,
        ));
      }
    });
    return dashBoardcategories;
  }


  static DashboardDTO createDashboardDTO(UserTranscript ismTranscript) {
    final gpa = calculateGPA(ismTranscript);
    final categories = getOverviewCategories(ismTranscript);
    final earnedECTS = calculateTotalEarnedECTS(ismTranscript);

    return DashboardDTO(
      programECTS: programEcts,
      earnedECTS: earnedECTS,
      gpa: gpa,
      categories: categories,
    );
  }
}
