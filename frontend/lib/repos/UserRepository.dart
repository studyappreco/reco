import 'package:frontend/models/Module.dart';
import 'package:frontend/service/MongoService.dart';
import 'package:frontend/repos/TranscriptRepository.dart';

class UserRepository {
  final MongoService _mongoService = MongoService();
  final TranscriptRepository _transcriptRepo = TranscriptRepository();

  Future<void> togglePlannedModule(String userID, String moduleNr, bool isCurrent) async {
    String category = isCurrent ? 'current' : 'next';
    await _mongoService.toggleModuleState(userID, moduleNr, 'planned_modules', category: category);
  }

  Future<void> removePlannedModule(String userID, String moduleNr) async {
    await _mongoService.removePlannedModule(userID, moduleNr);
  }

  Future<Map<String, List<String>>> getPlannedModulesStruct(String userID) async {
    return await _mongoService.getPlannedModulesStruct(userID);
  }
  
  Future<List<String>> getAllPlannedModuleNrs(String userID) async {
    return await _mongoService.getAllPlannedModuleNrs(userID);
  }
  
  Future<void> toggleFavoriteModule(String userID, String moduleNr) async {
    await _mongoService.toggleModuleState(userID, moduleNr, 'favorited_modules');
  }

  Future<List<String>> getFavoriteModuleNrs(String userID) async {
    return await _mongoService.getFavoriteModuleNrs(userID);
  }

  Future<void> updateInterests(String userID, List<String> newInterests) async {
    await _mongoService.updateUserInterests(userID, newInterests);
  }

  Future<List<String>> getInterests(String userID) async {
    return await _mongoService.getUserInterests(userID);
  }

  Future<bool> markModuleAsCompleted({
    required String userID,
    required Module module,
    required double grade,
    required String categoryId,
    required String examDate,
  }) async {
    
    // trying to save it in the transcript
    bool success = await _transcriptRepo.addCompletedCourseToTranscript(
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
}