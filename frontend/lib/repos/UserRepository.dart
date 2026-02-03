import 'package:frontend/service/MongoService.dart';

class UserRepository {
  final MongoService _mongoService = MongoService();

  Future<void> togglePlannedModule(String userID, String moduleNr) async {
    await _mongoService.toggleModuleState(userID, moduleNr, 'planned_modules');
  }

  Future<List<String>> getPlannedModuleNrs(String userID) async {
    return await _mongoService.getPlannedModuleNrs(userID);
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

  Future<void> markModuleAsCompleted(String userID, String moduleNr, double grade) async {
    await _mongoService.movePlannedToTranscript(userID, moduleNr, grade);
  }
}