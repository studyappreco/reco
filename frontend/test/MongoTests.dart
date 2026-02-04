import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/TranscriptDocument.dart';
import 'package:frontend/repos/CSBTranscript.dart';
import 'package:frontend/repos/CSMTranscript.dart';
import 'package:frontend/repos/ISMTranscript.dart';
import 'package:frontend/service/MongoService.dart';
import 'package:frontend/ui/utils/auth.dart';

void main() {
  group('Test inserting random document to Mongo', () {
    setUpAll(() async {
      await dotenv.load(fileName: '.env');
    });

    tearDownAll(() async {
      final db = await DbCLient.getMongoDBClient();
      await db?.close();
    });

    test('should insert a simple UserTranscript', () async {
      final mongoService = MongoService();

      // Create a simple transcript with one category and one course
      final simpleTranscript = TranscriptDocument(
        children: [
          TranscriptNode(
            name: 'Compulsory Modules',
            courses: [
              TranscriptCourse(
                id: 'CS101',
                courseName: 'Introduction to Programming',
                ects: 6,
                grade: 1.3,
                examDate: '2024-01-15',
              ),
            ],
          ),
        ],
      );

      const testUserId = 'test_user_123';
      const testProgram = 'Computer Science B.Sc.';

      // Upload the transcript
      await mongoService.uploadTranscript(
        testUserId,
        simpleTranscript,
        testProgram,
      );

      // Verify it was inserted by fetching it back
      final retrieved = await mongoService.getTranscript(testUserId);

      expect(retrieved, isNotNull);
      expect(retrieved!.userID, equals(testUserId));
      expect(retrieved.transcript.children.length, equals(1));
      expect(retrieved.transcript.children.first.name, equals('Compulsory Modules'));
      expect(retrieved.transcript.children.first.courses!.first.courseName,
          equals('Introduction to Programming'));

      // Cleanup: delete the test document
      await mongoService.deleteTranscript(testUserId);
    });


    test('test get MainPage DTO CS bachelor' , () async {
      final mongoService = MongoService();
      const testUserId = '6967699402af64b787c3';
      final transcript = await mongoService.getTranscript(testUserId);
      expect(transcript, isNotNull, reason: 'No transcript found for user $testUserId');
      final categories = CSBTranscript().getOverviewCategories(transcript!);

      debugPrint('=== CS Bachelor Overview Categories ===');
      for (final category in categories) {
        debugPrint('Category: ${category.name}');
        debugPrint('  Progress: ${(category.progress * 100).toStringAsFixed(1)}%');
        debugPrint('  Required ECTS: ${category.requiredCredits}');
        debugPrint('  Courses: ${category.courses.length}');
        for (final course in category.courses) {
          debugPrint('    - ${course.courseName} (${course.ects} ECTS, Grade: ${course.grade})');
        }
        debugPrint('');
      }
    });

    test('test get MainPage DTO CS master' , () async {
      final mongoService = MongoService();
      const testUserId = '696fc7786cc80f940621';

      final transcript = await mongoService.getTranscript(testUserId);
      expect(transcript, isNotNull, reason: 'No transcript found for user $testUserId');

      final categories = CSMTranscript().getOverviewCategories(transcript!);

      debugPrint('=== CS Master Overview Categories ===');
      for (final category in categories) {
        debugPrint('Category: ${category.name}');
        debugPrint('  Progress: ${(category.progress * 100).toStringAsFixed(1)}%');
        debugPrint('  Required ECTS: ${category.requiredCredits}');
        debugPrint('  Courses: ${category.courses.length}');
        for (final course in category.courses) {
          debugPrint('    - ${course.courseName} (${course.ects} ECTS, Grade: ${course.grade})');
        }
        debugPrint('');
      }
    });

    test('test get MainPage DTO ISM master' , () async {
      final mongoService = MongoService();
      const testUserId = '695f8904bcac7f16a725';

      final transcript = await mongoService.getTranscript(testUserId);
      expect(transcript, isNotNull, reason: 'No transcript found for user $testUserId');

      final categories = ISMTranscript().getOverviewCategories(transcript!);

      debugPrint('=== ISM Master Overview Categories ===');
      for (final category in categories) {
        debugPrint('Category: ${category.name}');
        debugPrint('  Progress: ${(category.progress * 100).toStringAsFixed(1)}%');
        debugPrint('  Required ECTS: ${category.requiredCredits}');
        debugPrint('  Courses: ${category.courses.length}');
        for (final course in category.courses) {
          debugPrint('    - ${course.courseName} (${course.ects} ECTS, Grade: ${course.grade})');
        }
        debugPrint('');
      }
    });
  });
}
