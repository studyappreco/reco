import 'dart:async';
import 'package:frontend/models/TranscriptDocument.dart';
import 'package:frontend/models/UserTrancript.dart';
import 'package:frontend/ui/utils/auth.dart';
import 'package:mongo_dart/mongo_dart.dart' hide Log;
import 'package:frontend/utils/logger.dart';

/*
* After the MVVM pattern:
*
* Service layer inside the data layer(https://docs.flutter.dev/app-architecture/case-study/data-layer).
*
* Use this service to interact with MongoDB and the mongo_dart driver.
* Exceptions are propagated to the Repository layer for handling.
*/
class MongoService {
  static const String _transcriptsCollection = 'transcripts';
  static const String _coursesCollection = 'courses_info';
  static const String _userDetailsCollection = 'user_details';

  Future<Db> _getDb() async {
    final db = await DbCLient.getMongoDBClient();
    if (db == null) {
      throw Exception('Failed to connect to MongoDB');
    }
    return db;
  }

  Future<UserTranscript?> getTranscript(String userID) async {
    final db = await _getDb();
    final collection = db.collection(_transcriptsCollection);

    final doc = await collection.findOne(where.eq('userID', userID));
    if (doc == null) return null;

    return UserTranscript.fromJson(doc);
  }

  Future<void> uploadTranscript(String userID, TranscriptDocument transcript, String programLiteral) async {
    final db = await _getDb();
    final collection = db.collection(_transcriptsCollection);

    final userTranscript = UserTranscript(
      programLiteral: programLiteral,
      userID: userID,
      transcript: transcript,
    );
    await collection.insertOne(
      userTranscript.toJson()
    );
  }

  Future<void> deleteTranscript(String userID) async {
    final db = await _getDb();
    final collection = db.collection(_transcriptsCollection);

    await collection.deleteOne(where.eq('userID', userID));
  }

  Future<bool> transcriptExists(String userID) async {
    final db = await _getDb();
    final collection = db.collection(_transcriptsCollection);

    final count = await collection.count(where.eq('userID', userID));
    return count > 0;
  }

  Future<List<Map<String, dynamic>>> getAllModules() async {
    try {
      final db = await _getDb();
      final collection = db.collection(_coursesCollection);

      final List<Map<String, dynamic>> jsonList = await collection.find().toList();

      Log.info("Loaded ${jsonList.length} courses from DB");

      return jsonList;

    } catch (e, s) {
      Log.error("Error loading modules from DB", e, s);
      rethrow; 
    }
  }

  Future<Map<String, dynamic>?> getModuleByNumber(String moduleNr) async {
    try {
      final db = await _getDb();
      final collection = db.collection(_coursesCollection);
      final queryParam = int.tryParse(moduleNr) ?? moduleNr;

      final doc = await collection.findOne(where.eq('number', queryParam));

      if(doc == null){
        Log.warning("Module search: Module '$moduleNr' not found in DB");
        return null;
      }

      return doc;
    } catch (e, s) {
      Log.error("Error loading module $moduleNr", e, s);
      return null;
    }
  }

  // updates the status (planned/favorite) by adding or removing the module
  Future<void> toggleModuleState(String userID, String moduleNr, String fieldName) async {
    
    if(fieldName != 'planned_modules' && fieldName != 'favorited_modules'){
      throw Exception("Invalid fieldName: '$fieldName'. Must be 'planned_modules' or 'favorited_modules'.");
    }

    try {
      final db = await _getDb();
      final collection = db.collection(_userDetailsCollection);

      // searching user
      final userMap = await collection.findOne(where.eq('userID', userID));

      // if user does not yet exist (should not happen)
      // TODO Remove this after it is done during the creation of the new account
      if(userMap == null){
        Log.warning("User details for $userID not found! Creating new entry.");

        await collection.insert({
          'userID': userID,
          'username': 'Student X', // TODO
          'interests': [],
          'planned_modules': (fieldName == 'planned_modules') ? [moduleNr] : [],
          'favorited_modules': (fieldName == 'favorited_modules') ? [moduleNr] : [],
        });
        return;
      }

      // user exists -> Get list
      List<String> currentList = List<String>.from(userMap[fieldName] ?? []);

      // updating the list
      if (currentList.contains(moduleNr)) {
        currentList.remove(moduleNr);
      } else {
        currentList.add(moduleNr);
      }

      await collection.update(
        where.eq('userID', userID),
        modify.set(fieldName, currentList),
      );

    } catch (e, s) {
      Log.error("Error toggling module state ($fieldName) for user $userID", e, s);
      rethrow;
    }
  }

  Future<void> updateUserInterests(String userID, List<String> newInterests) async {
    // TODO
  }

  // Getter for planned modules
  Future<List<String>> getPlannedModuleNrs(String userID) async {
    try {
      final db = await _getDb();
      final doc = await db.collection(_userDetailsCollection).findOne(where.eq('userID', userID));
      if(doc == null) return [];
      return List<String>.from(doc['planned_modules'] ?? []);
    } catch (e, s) {
      Log.error("Error fetching planned modules", e, s);
      return [];
    }
  }

  // Getter for favorites
  Future<List<String>> getFavoriteModuleNrs(String userID) async {
    try {
      final db = await _getDb();
      final doc = await db.collection(_userDetailsCollection).findOne(where.eq('userID', userID));
      if(doc == null) return [];
      return List<String>.from(doc['favorited_modules'] ?? []);
    } catch (e, s) {
      Log.error("Error fetching favorites", e, s);
      return [];
    }
  }

  // Getter for interests
  Future<List<String>> getUserInterests(String userID) async {
    try {
      final db = await _getDb();
      final doc = await db.collection(_userDetailsCollection).findOne(where.eq('userID', userID));
      if (doc == null) return [];
      return List<String>.from(doc['interests'] ?? []);
    } catch (e, s) {
      Log.error("Error fetching interests", e, s);
      return [];
    }
  }

  Future<String?> getUsername(String userID) async {
    try {
      final db = await _getDb();
      final doc = await db.collection(_userDetailsCollection).findOne(where.eq('userID', userID));
      if (doc == null) return null;
      return doc['username'] as String?;
    } catch (e, s) {
      Log.error("Error fetching username for user $userID", e, s);
      return null;
    }
  }

  Future<void> movePlannedToTranscript(String userID, String moduleNr, double grade) async {
    // TODO:
    // 1. Remove form planned_modules
    // 2. Get Module Details
    // 3. Add to transcript with grade
  }
}
