
import 'package:frontend/models/UserTrancript.dart';
import 'package:frontend/models/TranscriptDocument.dart';
import 'package:frontend/repos/transcriptUtils.dart';

class CSMTranscript {

  static int programEcts = 120;

  // important: have to match with the prompt
  static Map<String, int> ectsForCategories = {
    "data_and_software_engineering": 18,
    "embedded_systems_and_computer_architectures": 18,
    "foundations_of_computing": 18,
    "cognitive_systems": 18,
    "digital_media_and_human_computer_interaction": 18,
    "distributed_systems_and_networks": 18,
    "free_electives": 12
  };

  // important: have to match with the prompt
  static Map<String, String> categoriesForDashboard = {
    "data_and_software_engineering": "Data and Software Engineering",
    "embedded_systems_and_computer_architectures": "Embedded Systems and Computer Architectures",
    "foundations_of_computing": "Foundations of Computing",
    "cognitive_systems": "Cognitive Systems",
    "digital_media_and_human_computer_interaction": "Digital Media and Human-Computer Interaction",
    "distributed_systems_and_networks": "Distributed Systems and Networks",
    "free_electives": "Free Electives"
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
