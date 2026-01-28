
 import '../models/TranscriptDocument.dart';
import '../models/UserTrancript.dart';



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