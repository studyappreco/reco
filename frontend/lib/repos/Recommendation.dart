
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/repos/CourseSearchRepo.dart';
import 'package:frontend/repos/UserRepository.dart';
import '../models/Module.dart';
import '../models/TranscriptDocument.dart';
import '../models/UserTrancript.dart';
import '../service/MongoService.dart';
import '../service/OpenAIService.dart';
import 'package:frontend/utils/RecoLog.dart';


class Recommendation {

  final OpenAIService _openAIService;
  final MongoService _mongoService;
  final CourseSearchRepo _courserepo;
  final UserRepository _userRepo;

  Recommendation({
    OpenAIService? openAIService,
    MongoService? mongoService,
  })  : _openAIService = openAIService ?? OpenAIService(dotenv.env['OPENAI_API_KEY'] ?? ""),
        _mongoService = mongoService ?? MongoService(),
        _courserepo = CourseSearchRepo(),
      _userRepo = UserRepository();

  Future<List<Module>?> candicate_generation (String userID) async {
     var transcript = await _mongoService.getTranscript(userID);
     var userDetails = await _userRepo.getUserDetails(userID);
     if (userDetails == null) {
       return null;
     }
     var allCoursesinStupo = await _courserepo.getAllCoursesForStupo(userDetails.programLiteral, userID);
     RecoLog.info("Found ${allCoursesinStupo.length} courses in Stupo");
     if (transcript == null) {
       RecoLog.info("Transcript came out empty");
       RecoLog.info("Found ${allCoursesinStupo.length} courses in Stupo");
       return allCoursesinStupo;
     }
     var all_courses_in_transcript = getAllTranscriptcourses(transcript);
     // TODO : add fuzzy search here..... how do we handle english and german names on the transcript?
     var filter_based_on_transcript = allCoursesinStupo.where((x) => !all_courses_in_transcript.any((y) => y.courseName == x.title));
     RecoLog.info("Found ${filter_based_on_transcript.length} candidates");
     // TODO: filter out all courses that are able to take based on the
     return filter_based_on_transcript.toList();
  }

  Future<List<Module>?> candidate_ranking() async {
    // each user should have one embedding: this embedding contains the
    //

  }

  List<TranscriptCourse> getAllTranscriptcourses(UserTranscript userTranscript) {
    var res = <TranscriptCourse>[];
    void traverseNode(TranscriptNode node) {
      if (node.courses != null) {
        for (final course in node.courses!) {
          res.add(course);
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