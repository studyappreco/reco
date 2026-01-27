import 'dart:async';
import 'package:frontend/models/TranscriptDocument.dart';
import 'package:frontend/models/UserTrancript.dart';
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

  Future<List<Map<String, dynamic>>> recommendCourses({
    required String interestQuery,
    required String freeText,
    int limit = 5,
  }) async {
    final trimmedInterests = interestQuery.trim();
    final trimmedFreeText = '';
    if (trimmedInterests.isEmpty && trimmedFreeText.isEmpty) {
      return [];
    }

    final db = await _getDb();
    final collection = db.collection(_coursesCollection);
    /*
    final pipeline = [
      {
        r'$search': {
          'index': 'course_recommendation',
          'compound': {
            'should': [
              {
        'text': {
          'query': trimmedInterests,
          'path': ['title', 'learn_content', 'learn_result'],
          'score': {
            'boost': {'value': 3}
          }
        }
      },
      {
        'text': {
          'query': trimmedFreeText,
          'path': ['learn_content', 'learn_result'],
          'score': {
            'boost': {'value': 1}
          }
        }
      }

            ],
            'minimumShouldMatch': 1,
          },
        },
      },
      {
        r'$project': {
          'number': 1,
          'title': 1,
          'ects': 1,
          'score': {r'$meta': 'searchScore'},
        },
      },
      {r'$limit': limit},
    ];
  */
  final pipeline = [
      {
        r'$search': {
          'index': 'course_recommendation',
          'compound': {
            'should': [
              {
        'text': {
          'query': trimmedInterests + trimmedFreeText,
          'path': ['title', 'learn_content', 'learn_result'],
          'score': {
            'boost': {'value': 3}
          }
        }
      },
        ],
            'minimumShouldMatch': 1,
          },
        },
      },
      {
        r'$project': {
          'number': 1,
          'title': 1,
          'ects': 1,
          'score': {r'$meta': 'searchScore'},
        },
      },
      {r'$limit': limit},
    ];

    final results = await collection
        .aggregateToStream(pipeline.cast<Map<String, Object>>())
        .toList();
    return results.cast<Map<String, dynamic>>();
  }
}
