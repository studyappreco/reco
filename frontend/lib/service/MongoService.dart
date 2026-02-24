import 'dart:async';
import 'package:frontend/models/TranscriptDocument.dart';
import 'package:frontend/models/UserDetails.dart';
import 'package:frontend/models/UserTrancript.dart';
import 'package:frontend/ui/utils/auth.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:frontend/utils/RecoLog.dart';

import '../models/Module.dart';

const VECTOR_INDEX_NAME = "vector_index_including_filter";
const SEARCH_INDEX_Name = "course_search_index";

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

  Future<void> uploadTranscript(UserTranscript transcript) async {
    final db = await _getDb();
    final collection = db.collection(_transcriptsCollection);

    await collection.insertOne(transcript.toJson());
  }

  Future<void> updateTranscript(
    String userID,
    TranscriptDocument transcript,
  ) async {
    final db = await _getDb();
    final collection = db.collection(_transcriptsCollection);

    await collection.update(
      where.eq('userID', userID),
      modify.set('transcript', transcript.toJson()),
    );
  }

  Future<void> deleteTranscript(String userID) async {
    final db = await _getDb();
    final collection = db.collection(_transcriptsCollection);

    await collection.deleteOne(where.eq('userID', userID));
  }

  Future<List<Map<String, dynamic>>> getAllModules() async {
    try {
      final db = await _getDb();
      final collection = db.collection(_coursesCollection);

      final List<Map<String, dynamic>> jsonList = await collection
          .find()
          .toList();

      RecoLog.info("Loaded ${jsonList.length} courses from DB");

      return jsonList;
    } catch (e, s) {
      RecoLog.error("Error loading modules from DB", e, s);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getModuleByNumber(String moduleNr) async {
    try {
      final db = await _getDb();
      final collection = db.collection(_coursesCollection);
      final queryParam = int.tryParse(moduleNr) ?? moduleNr;

      final doc = await collection.findOne(where.eq('number', queryParam));

      if (doc == null) {
        RecoLog.warning("Module search: Module '$moduleNr' not found in DB");
        return null;
      }

      return doc;
    } catch (e, s) {
      RecoLog.error("Error loading module $moduleNr", e, s);
      return null;
    }
  }

  Future<UserDetails?> getUserDetails(String userID) async {
    try {
      final db = await _getDb();
      final collection = db.collection(_userDetailsCollection);
      final user = await collection.findOne(where.eq('userID', userID));
      if (user == null) {
        return null;
      }
      return UserDetails.fromJson(user);
    } catch (e, s) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getModulesByModuleNrs(
    List<String> moduleNrs,
  ) async {
    if (moduleNrs.isEmpty) return [];

    try {
      final db = await _getDb();
      final collection = db.collection(_coursesCollection);

      final List<dynamic> queryParams = [];
      for (var nr in moduleNrs) {
        queryParams.add(int.tryParse(nr) ?? nr);
      }

      final List<Map<String, dynamic>> jsonList = await collection
          .find(where.oneFrom('number', queryParams))
          .toList();

      RecoLog.info("Loaded ${jsonList.length} modules from DB");
      return jsonList;
    } catch (e, s) {
      RecoLog.error("Error loading modules from DB", e, s);
      rethrow;
    }
  }

  // updates the status (planned/favorite) by adding or removing the module
  Future<void> toggleModuleState(
    String userID,
    String moduleNr,
    String fieldName, {
    String? category,
  }) async {
    if (fieldName != 'planned_modules' && fieldName != 'favorited_modules') {
      throw Exception(
        "Invalid fieldName: '$fieldName'. Must be 'planned_modules' or 'favorited_modules'.",
      );
    }

    try {
      final db = await _getDb();
      final collection = db.collection(_userDetailsCollection);

      // searching user
      final user = await collection.findOne(where.eq('userID', userID));

      // if user does not yet exist (should not happen)
      // TODO Remove this after it is done during the creation of the new account
      if (user == null) {
        RecoLog.warning(
          "User details for $userID not found! Creating new entry.",
        );

        var initialData = {
          'userID': userID,
          'username': 'Student',
          'interests': [],
          'favorited_modules': [],
          'planned_modules': {'current': [], 'next': []},
        };

        if (fieldName == 'favorited_modules') {
          initialData['favorited_modules'] = [moduleNr];
        } else if (fieldName == 'planned_modules' && category != null) {
          (initialData['planned_modules'] as Map)[category] = [moduleNr];
        }

        await collection.insert(initialData);
        return;
      }

      if (fieldName == 'favorited_modules') {
        List<String> currentList = List<String>.from(
          user['favorited_modules'] ?? [],
        );
        if (currentList.contains(moduleNr)) {
          currentList.remove(moduleNr);
        } else {
          currentList.add(moduleNr);
        }
        await collection.update(
          where.eq('userID', userID),
          modify.set(fieldName, currentList),
        );
      } else if (fieldName == 'planned_modules' && category != null) {
        Map<String, dynamic> planned = user['planned_modules'];
        List<String> targetList = List<String>.from(planned[category] ?? []);

        if (targetList.contains(moduleNr)) {
          targetList.remove(moduleNr);
        } else {
          targetList.add(moduleNr);
          // if it is in the other category, it must be removed so that the user cannot specify it as current and next
          String othercategory = (category == 'current') ? 'next' : 'current';
          List<String> otherList = List<String>.from(
            planned[othercategory] ?? [],
          );
          if (otherList.contains(moduleNr)) {
            otherList.remove(moduleNr);
            planned[othercategory] = otherList;
          }
        }

        planned[category] = targetList;

        await collection.update(
          where.eq('userID', userID),
          modify.set(fieldName, planned),
        );
      }
    } catch (e, s) {
      RecoLog.error(
        "Error toggling module state ($fieldName) for user $userID",
        e,
        s,
      );
      rethrow;
    }
  }

  Future<void> updateUserInterests(
    String userID,
    List<String> newInterests,
  ) async {
    try {
      final db = await _getDb();
      final collection = db.collection(_userDetailsCollection);
      await collection.update(
        where.eq('userID', userID),
        modify.set('interests', newInterests),
      );
    } catch (e, s) {
      RecoLog.error("Error updating interests for user $userID", e, s);
      rethrow;
    }
  }

  Future<void> createUserDetails(String userID, String username) async {
    try {
      final db = await _getDb();
      final collection = db.collection(_userDetailsCollection);

      await collection.update(
        where.eq('userID', userID),
        modify
            .setOnInsert('userID', userID)
            .setOnInsert('username', username)
            .setOnInsert('interests', [])
            .setOnInsert('planned_modules', {'current': [], 'next': []})
            .setOnInsert('favorited_modules', [])
            .setOnInsert('programLiteral', ""),
        upsert: true,
      );
    } catch (e, s) {
      RecoLog.error("Error creating user details for user $userID", e, s);
      rethrow;
    }
  }

  Future<void> setProgramLiteral(String userID, String literal) async {
    try {
      final db = await _getDb();
      final collection = db.collection(_userDetailsCollection);

      await collection.update(
        where.eq('userID', userID),
        modify.set('programLiteral', literal),
        upsert: true,
      );
    } catch (e, s) {
      RecoLog.error("Error setting program literal for user $userID", e, s);
      rethrow;
    }
  }

  Future<Map<String, List<String>>> getPlannedModulesStruct(
    String userID,
  ) async {
    try {
      final db = await _getDb();
      final doc = await db
          .collection(_userDetailsCollection)
          .findOne(where.eq('userID', userID));

      if (doc == null || doc['planned_modules'] == null) {
        return {'current': [], 'next': []};
      }

      final planned = doc['planned_modules'] as Map<String, dynamic>;
      return {
        'current': List<String>.from(planned['current']),
        'next': List<String>.from(planned['next']),
      };
    } catch (e, s) {
      RecoLog.error("Error fetching planned structure", e, s);
      return {'current': [], 'next': []};
    }
  }

  Future<List<String>> getAllPlannedModuleNrs(String userID) async {
    final planned = await getPlannedModulesStruct(userID);
    return [...planned['current']!, ...planned['next']!];
  }

  // Getter for favorites
  Future<List<String>> getFavoriteModuleNrs(String userID) async {
    try {
      final db = await _getDb();
      final doc = await db
          .collection(_userDetailsCollection)
          .findOne(where.eq('userID', userID));
      if (doc == null) return [];
      return List<String>.from(doc['favorited_modules'] ?? []);
    } catch (e, s) {
      RecoLog.error("Error fetching favorites", e, s);
      return [];
    }
  }

  // Getter for interests
  Future<List<String>> getUserInterests(String userID) async {
    try {
      final db = await _getDb();
      final doc = await db
          .collection(_userDetailsCollection)
          .findOne(where.eq('userID', userID));
      if (doc == null) return [];
      return List<String>.from(doc['interests'] ?? []);
    } catch (e, s) {
      RecoLog.error("Error fetching interests", e, s);
      return [];
    }
  }

  Future<String?> getUsername(String userID) async {
    try {
      final db = await _getDb();
      final doc = await db
          .collection(_userDetailsCollection)
          .findOne(where.eq('userID', userID));
      if (doc == null) return null;
      return doc['username'] as String?;
    } catch (e, s) {
      RecoLog.error("Error fetching username for user $userID", e, s);
      return null;
    }
  }

  Future<List<String>?> getRecommendedModules(String userID) async {
    try {
      final db = await _getDb();
      final doc = await db
          .collection(_userDetailsCollection)
          .findOne(where.eq('userID', userID));
      if (doc == null) return null;
      return doc['recommended_modules'] as List<String>;
    } catch (e, s) {
      RecoLog.error("Error fetching username for user $userID", e, s);
      return null;
    }
  }

  Future<void> removePlannedModule(String userID, String moduleNr) async {
    try {
      final db = await _getDb();
      final collection = db.collection(_userDetailsCollection);
      final user = await collection.findOne(where.eq('userID', userID));

      if (user == null || user['planned_modules'] == null) return;

      Map<String, dynamic> planned = user['planned_modules'];

      List<String> current = List<String>.from(planned['current']);
      List<String> next = List<String>.from(planned['next']);

      current.remove(moduleNr);
      next.remove(moduleNr);

      planned['current'] = current;
      planned['next'] = next;

      await collection.update(
        where.eq('userID', userID),
        modify.set('planned_modules', planned),
      );
    } catch (e, s) {
      RecoLog.error("Error removing planned module", e, s);
    }
  }

  Future<List<String>> vectorSearchCourses({
    required List<double> queryVector,
    required List<String> candidateModules,
    int limit = 10,
  }) async {
    final db = await _getDb();
    final collection = db.collection(_coursesCollection);

    //Convert string module IDs to integers (as stored in DB)
    final intModuleIds = candidateModules
        .map((id) => int.tryParse(id))
        .whereType<int>()
        .toList();

    final pipeline = [
      {
        '\$vectorSearch': {
          'index': VECTOR_INDEX_NAME,
          'filter': {
            "number": {"\$in": intModuleIds},
          },
          'path': 'embedding',
          'queryVector': queryVector,
          'limit': limit,
          'exact': true,
        },
      },
      {
        '\$project': {'number': 1, '_id': 0},
      },
    ];

    final results = await collection.aggregateToStream(pipeline).toList();
    return results.map((doc) => doc['number'].toString()).toList();
  }

  Future<List<String>> fuzzyMatchExamNames(List<String> examNames) async {
    if (examNames.isEmpty) return [];

    final db = await _getDb();
    final collection = db.collection(_coursesCollection);
    final matchedModuleNrs = <String>[];

    for (var examName in examNames) {
      final pipeline = [
        {
          "\$search": {
            "index": SEARCH_INDEX_Name,
            "text": {"path": "title", "query": examName},
          },
        },
        {'\$limit': 1},
        {
          '\$project': {'number': 1, '_id': 0},
        },
      ];

      final results = await collection.aggregateToStream(pipeline).toList();
      if (results.isNotEmpty) {
        matchedModuleNrs.add(results.first['number'].toString());
      }
    }
    RecoLog.info(matchedModuleNrs.toString());
    return matchedModuleNrs;
  }

  Future<void> updateRankedCandidates(
    String userID,
    List<String> rankedCandidates,
  ) async {
    try {
      final db = await _getDb();
      final collection = db.collection(_userDetailsCollection);
      await collection.update(
        where.eq('userID', userID),
        modify.set('recommended_modules', rankedCandidates),
      );
    } catch (e, s) {
      RecoLog.error("Error updating ranked candidates for user $userID", e, s);
      rethrow;
    }
  }

  Future<List<Module>> getModulesById(
    List<String> recommendedModuleNrs,
    String userID,
  ) async {
    if (recommendedModuleNrs.isEmpty) return [];

    final db = await _getDb();
    final collection = db.collection(_coursesCollection);

    final List<dynamic> queryParams = recommendedModuleNrs
        .map((nr) => int.tryParse(nr) ?? nr)
        .toList();

    final jsonList = await collection
        .find(where.oneFrom('number', queryParams))
        .toList();

    final favorites = await getFavoriteModuleNrs(userID);
    final planned = await getAllPlannedModuleNrs(userID);

    return jsonList
        .map(
          (json) => Module.fromMap(
            json,
            userFavorites: favorites,
            userPlanned: planned,
          ),
        )
        .toList();
  }
}
