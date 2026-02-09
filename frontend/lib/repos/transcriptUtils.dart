import 'package:flutter/foundation.dart';
import 'package:frontend/repos/CSBTranscript.dart';
import 'package:frontend/repos/CSMTranscript.dart';
import 'package:frontend/repos/ISMTranscript.dart';

import '../models/TranscriptDocument.dart';
import '../models/UserTrancript.dart';

abstract class Transcript {
  int get programCredits;

  // important: have to match with the prompt
  Map<String, int> get creditsForCategories;

  // important: have to match with the prompt
  Map<String, String> get categoriesForDashboard;

  List<OverviewCategory> getOverviewCategories(UserTranscript ismTranscript) {
    List<OverviewCategory> dashBoardcategories = [];

    categoriesForDashboard.forEach((key, val) {
      TranscriptNode? found = findNodeByName(key, ismTranscript);
      if (found != null) {
        int earnedEcts = 0;
        List<TranscriptCourse> courses = [];
        void traverseNode(TranscriptNode node) {
          if (node.courses != null) {
            for (final course in node.courses!) {
              earnedEcts += course.ects;
              courses.add(course);
            }
          }
          if (node.children != null) {
            for (final child in node.children!) {
              traverseNode(child);
            }
          }
        }
        traverseNode(found);

        // int earnedEcts = found.courses?.fold<int>(0, (sum, c) => sum + c.ects) ?? 0;
        int requiredEcts = creditsForCategories[key]!;
        if (kDebugMode) {
          debugPrint("$key, $val, $earnedEcts, $requiredEcts");
        }
        double progress = requiredEcts > 0 ? (earnedEcts / requiredEcts).clamp(0.0, 1.0) : 0.0;
        dashBoardcategories.add(OverviewCategory(
          id: key,
          name: val,
          progress: progress,
          requiredCredits: requiredEcts,
          earnedCredits: earnedEcts,
          courses: courses,
        ));
      }
    });
    return dashBoardcategories;
  }


  DashboardDTO createDashboardDTO(UserTranscript transcript) {
    final gpa = calculateGPA(transcript);
    final categories = getOverviewCategories(transcript);
    final earnedECTS = calculateTotalEarnedECTS(transcript);
    final completedCourses = calculateTotalCompletedCourses(transcript);

    return DashboardDTO(
      programCredits: programCredits,
      earnedCredits: earnedECTS,
      completedCoursesCount: completedCourses,
      gpa: gpa,
      categories: categories,
    );
  }
}

DashboardDTO? userTranscriptToDashboardDTO(UserTranscript? userTranscript) {
  if (userTranscript == null) return null;
  switch (userTranscript.programLiteral) {
    case "ISM":
      return ISMTranscript().createDashboardDTO(userTranscript);
    case "CS_B":
      return CSBTranscript().createDashboardDTO(userTranscript);
    case "CS_M":
      return CSMTranscript().createDashboardDTO(userTranscript);
  }
  return null;
}

TranscriptNode? findNodeByName(String name, UserTranscript ismTranscript) {
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

double? calculateGPA(UserTranscript ismTranscript) {
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

   for (final node in ismTranscript.transcript.children) {
     traverseNode(node);
   }

   if (totalEcts == 0) {
     return null;
   }
   return products / totalEcts;
}

int calculateTotalEarnedECTS(UserTranscript ismTranscript) {
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

int calculateTotalCompletedCourses(UserTranscript ismTranscript) {
  int count = 0;
  void traverseNode(TranscriptNode node){
    if(node.courses != null){
      count += node.courses!.length;
    }
    if(node.children != null){
      for(final child in node.children!){
        traverseNode(child);
      }
    }
  }
  for(final node in ismTranscript.transcript.children){
    traverseNode(node);
  }
  return count;
}

class DashboardDTO {
   final int programCredits;
   final int earnedCredits;
   final int completedCoursesCount;
   final double? gpa;
   final List<OverviewCategory> categories;

   DashboardDTO({
     required this.programCredits,
     required this.earnedCredits,
     required this.completedCoursesCount,
     this.gpa,
     required this.categories,
   });
}


class OverviewCategory {
   final String id;
   final String name;
   final double progress;
   final List<TranscriptCourse> courses;
   final int requiredCredits;
   final int earnedCredits;

   OverviewCategory({
     required this.id,
     required this.name,
     required this.progress,
     required this.courses,
     required this.requiredCredits,
     required this.earnedCredits,
   });
}