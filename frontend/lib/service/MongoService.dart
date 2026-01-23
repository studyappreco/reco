import 'dart:async';
import 'package:frontend/models/TranscriptDocument.dart';
import 'package:frontend/models/UserTrancript.dart';
import 'package:frontend/models/Module.dart';
import 'package:frontend/ui/utils/auth.dart';
import 'package:mongo_dart/mongo_dart.dart';

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
  static const String _coursesCollection = 'courses';

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

  Future<void> uploadTranscript(String userID, TranscriptDocument transcript) async {
    final db = await _getDb();
    final collection = db.collection(_transcriptsCollection);

    final userTranscript = UserTranscript(
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

  Future<List<Module>> getAllModules() async {
    try {
      final db = await _getDb();
      final collection = db.collection(_coursesCollection);

      final List<Map<String, dynamic>> jsonList = await collection.find().toList();

      print("Loaded ${jsonList.length} courses from DB");

      return jsonList.map((json) => Module.fromMap(json)).toList();

    } catch (e) {
      print("Error loading modules: $e");
      rethrow; 
    }
  }
}