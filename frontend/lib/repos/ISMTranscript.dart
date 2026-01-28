
import 'package:frontend/models/UserTrancript.dart';
import 'package:frontend/models/TranscriptDocument.dart';

class ISMTranscript {

  static int program_ects = 120;

  // important: have to match with the prompt
  static Map<String, int> ects_for_categories = {
    "information_systems" : 30,
    "computer_science" : 24,
    "business_and_economics" : 24,
    "free_electives" : 12
  };
  // important: have to match with the prompt
  static Map<String, String> categories_for_dashboard = {
    "information_systems" : "Information Systems",
    "computer_science" : "Computer Science",
    "business_and_economics" : "Business and Economics",
    "free_electives" : "Free Electives"
  };

  static double? calculateGPA(UserTranscript ismTranscript) {
    double products = 0;
    int totalEcts = 0;

    void traverseNode(TranscriptNode node) {
      if (node.courses != null) {
        for (final course in node.courses!) {
          products += course.ects * course.grade;
          totalEcts += course.ects;
        }
      }
      if (node.children != null) {
        for (final child in node.children!) {
          traverseNode(child);
        }
      }
    }

    // start with the categories
    for (final node in ismTranscript.transcript.children) {
      traverseNode(node);
    }

    // Return null if no course data was found
    if (totalEcts == 0) {
      return null;
    }
    return products / totalEcts;
  }

  static TranscriptNode? findNodeByName(String name, UserTranscript ismTranscript) {
      TranscriptNode? found;

      void traverseNode(TranscriptNode node) {
        if (node.name == name) {
          found = node;
        }
        if (node.children != null) {
          for (final child in node.children!) {
            traverseNode(child);
          }
        }
      }

      for (final node in ismTranscript.transcript.children) {
        traverseNode(node);
      }
      return found;
  }

  static List<OverviewCategory> getOverviewCategories(UserTranscript ismTranscript) {
    List<OverviewCategory> dashBoardcategories = [];

    categories_for_dashboard.forEach((key, val) {
        TranscriptNode? found = findNodeByName(key, ismTranscript);
        if (found != null) {
          int earnedEcts = found.courses?.fold<int>(0, (sum, c) => sum + c.ects) ?? 0;
          int requiredEcts = ects_for_categories[key]!;
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

  static int calculateTotalEarnedECTS(UserTranscript ismTranscript) {
    int totalEcts = 0;

    void traverseNode(TranscriptNode node) {
      if (node.courses != null) {
        for (final course in node.courses!) {
          totalEcts += course.ects;
        }
      }
      if (node.children != null) {
        for (final child in node.children!) {
          traverseNode(child);
        }
      }
    }

    for (final node in ismTranscript.transcript.children) {
      traverseNode(node);
    }

    return totalEcts;
  }

  static DashboardDTO createDashboardDTO(UserTranscript ismTranscript) {
    final gpa = calculateGPA(ismTranscript);
    final categories = getOverviewCategories(ismTranscript);
    final earnedECTS = calculateTotalEarnedECTS(ismTranscript);

    return DashboardDTO(
      programECTS: program_ects,
      earnedECTS: earnedECTS,
      gpa: gpa,
      categories: categories,
    );
  }
}

class DashboardDTO {
  final int programECTS;
  final int earnedECTS;
  final double? gpa;
  final List<OverviewCategory> categories;

  DashboardDTO({
    required this.programECTS,
    required this.earnedECTS,
    this.gpa,
    required this.categories,
  });
}


class OverviewCategory {
  final String name;
  final double progress;
  final List<TranscriptCourse>? courses;
  final int categoryEcts;

  OverviewCategory({
    required this.name,
    required this.progress,
    this.courses,
    required this.categoryEcts,
  });
}