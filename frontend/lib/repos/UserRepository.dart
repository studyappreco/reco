import 'package:frontend/models/Module.dart';
import 'package:frontend/models/UserDetails.dart';
import 'package:frontend/service/MongoService.dart';
import 'package:frontend/repos/TranscriptRepository.dart';
import 'package:frontend/service/OpenAIService.dart';

class UserRepository {
  final MongoService mongoService;
  final TranscriptRepository transcriptRepo;
  final OpenAIService openAIService;

  UserRepository({required this.mongoService, required this.transcriptRepo, required this.openAIService});


  Future<void> togglePlannedModule(String userID, String moduleNr, bool isCurrent) async {
    String category = isCurrent ? 'current' : 'next';
    await mongoService.toggleModuleState(userID, moduleNr, 'planned_modules', category: category);
  }

  Future<void> removePlannedModule(String userID, String moduleNr) async {
    await mongoService.removePlannedModule(userID, moduleNr);
  }

  Future<Map<String, List<String>>> getPlannedModulesStruct(String userID) async {
    return await mongoService.getPlannedModulesStruct(userID);
  }
  
  Future<List<String>> getAllPlannedModuleNrs(String userID) async {
    return await mongoService.getAllPlannedModuleNrs(userID);
  }
  
  Future<void> toggleFavoriteModule(String userID, String moduleNr) async {
    await mongoService.toggleModuleState(userID, moduleNr, 'favorited_modules');
  }

  Future<List<String>> getFavoriteModuleNrs(String userID) async {
    return await mongoService.getFavoriteModuleNrs(userID);
  }

  Future<void> updateInterests(String userID, List<String> newInterests) async {
    await mongoService.updateUserInterests(userID, newInterests);
  }

  Future<void> createUserDetails(String userID, String username) async {
    await mongoService.createUserDetails(userID, username);
  }

  Future<void> setProgramLiteral(String userId, String literal) async {
    await mongoService.setProgramLiteral(userId, literal);
  }

  Future<void> setUserEmbedding(String userId, List<String> interests, String programLiteral) async {
    var embedding = await openAIService.embedUserdetails(interests, programLiteral);
    if (embedding == null) {
      return;
    }
    await mongoService.setUserEmbedding(userId, embedding);
  }


  Future<List<String>> getInterests(String userID) async {
    return await mongoService.getUserInterests(userID);
  }

  Future<String?> getUsername(String userID) async {
    return await mongoService.getUsername(userID);
  }

  Future<UserDetails?> getUserDetails(String userID) async {
    return await mongoService.getUserDetails(userID);
  }

  Future<bool> markModuleAsCompleted({
    required String userID,
    required Module module,
    required double grade,
    required String categoryId,
    required String examDate,
  }) async {
    
    // trying to save it in the transcript
    bool success = await transcriptRepo.addCompletedCourseToTranscript(
      userID: userID,
      courseName: module.title,
      moduleNr: module.moduleNr,
      grade: grade,
      ects: int.parse(module.credits),
      targetCategoryName: categoryId,
      examDate: examDate,
    );

    // if that was successful, delete it from the Planner
    if(success){
      await removePlannedModule(userID, module.moduleNr);
    }
    return success;
  }

  Future<bool> submitFeedback({required String moduleNr, required String userId, required int rating, required String feedbackText}) async {
    return await mongoService.submitFeedback(moduleNr, userId, rating, feedbackText);
  }

  Future<bool> deleteFeedback(String moduleNr, String userId) async {
    return await mongoService.deleteFeedback(moduleNr, userId);
  }

}
