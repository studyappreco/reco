import 'package:frontend/repos/CourseSearchRepo.dart';
import 'package:frontend/repos/UserRepository.dart';
import '../models/Module.dart';
import '../models/TranscriptDocument.dart';
import '../models/UserTrancript.dart';
import '../service/MongoService.dart';
import '../service/OpenAIService.dart';
import 'package:frontend/utils/RecoLog.dart';

class Recommendation {
  final OpenAIService openAIService;
  final MongoService mongoService;
  final CourseSearchRepo courseRepo;
  final UserRepository userRepo;

  Recommendation({
    required this.openAIService,
    required this.mongoService,
    required this.courseRepo,
    required this.userRepo
  });

  Future<List<String>?> candicate_generation(String userID) async {
    var transcript = await mongoService.getTranscript(userID);
    var userDetails = await userRepo.getUserDetails(userID);
    if (userDetails == null || transcript == null) {
      return null;
    }
    var allCourseIds = await courseRepo.getAllCoursesForStupo(
      userDetails.programLiteral,
      userID,
    );
    RecoLog.info("Starting with ${allCourseIds.length} courses in Stupo");
    var examNames = getAllTranscriptcourses(transcript);
    RecoLog.info("Found ${examNames.length} exams in transcript");
    var takenCourseIds = await mongoService.fuzzyMatchExamNames(examNames);
    RecoLog.info("Matched ${takenCourseIds.length} courses as already taken");
    var candidates = allCourseIds
        .where((id) => !takenCourseIds.contains(id))
        .toList();
    RecoLog.info("After filtering taken: ${candidates.length} candidates");
    candidates = checkCategoriesSpace(candidates);
    RecoLog.info("After category filter: ${candidates.length} candidates");

    return candidates;
  }

  Future<List<String>?> candidate_ranking(
    String userID,
    List<String> candidateIds,
    List<double> embedding,
  ) async {
    var vectorRanked = await mongoService.vectorSearchCourses(
      queryVector: embedding,
      candidateModules: candidateIds,
      limit: 10,
    );
    RecoLog.info("Vector search returned ${vectorRanked.length} candidates");
    var userDetails = await userRepo.getUserDetails(userID);
    var transcript = await mongoService.getTranscript(userID);
    if (userDetails == null || transcript == null) {
      return null;
    }
    var examNames = getAllTranscriptcourses(transcript);
    var interests = userDetails.interests;
    var modules = await courseRepo.getModulesByModuleNrs(vectorRanked, userID);
    RecoLog.info("Fetched ${modules.length} modules for ranking prompt");
    var rankedModuleNrs = await openAIService.candidateRankingPromptExecution(
      examNames,
      interests,
      modules,
      10,
    );

    if (rankedModuleNrs == null || rankedModuleNrs.isEmpty) {
      RecoLog.warning("LLM ranking returned null or empty");
      return vectorRanked;
    }
    await mongoService.updateRankedCandidates(userID, rankedModuleNrs);
    RecoLog.info("Stored ${rankedModuleNrs.length} ranked candidates for user");

    return rankedModuleNrs;
  }

  List<String> checkCategoriesSpace(List<String> input) {
    return input;
  }

  List<String> getAllTranscriptcourses(UserTranscript userTranscript) {
    var res = <String>[];
    void traverseNode(TranscriptNode node) {
      if (node.courses != null) {
        for (final course in node.courses!) {
          res.add(course.courseName);
        }
      }
      if (node.children != null) {
        for (final child in node.children!) {
          traverseNode(child);
        }
      }
    }

    for (final node in userTranscript.transcript.children) {
      traverseNode(node);
    }
    RecoLog.info("Found ${res.length} courses in transcript");
    return res;
  }
}
