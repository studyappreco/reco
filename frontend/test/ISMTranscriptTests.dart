import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/UserTrancript.dart';
import 'package:frontend/models/TranscriptDocument.dart';
import 'package:frontend/repos/ISMTranscript.dart';
import 'package:frontend/repos/transcriptUtils.dart';

final UserTranscript transcriptWithCourses = UserTranscript(
  userID: 'test-user-1',
  programLiteral: 'ISM',
  transcript: TranscriptDocument(
    children: [
      TranscriptNode(
        name: 'compulsory_electives',
        courses: [],
        children: [
          TranscriptNode(
            name: 'information_systems',
            courses: [
              TranscriptCourse(id: 'is-1', courseName: 'Database Systems', ects: 6, grade: 1.3, examDate: '15.02.2024'),
              TranscriptCourse(id: 'is-2', courseName: 'Business Process Management', ects: 6, grade: 2.0, examDate: '20.02.2024'),
            ],
          ),
          TranscriptNode(
            name: 'computer_science',
            courses: [
              TranscriptCourse(id: 'cs-1', courseName: 'Algorithms', ects: 6, grade: 1.0, examDate: '10.01.2024'),
              TranscriptCourse(id: 'cs-2', courseName: 'Data Structures', ects: 6, grade: 1.3, examDate: '12.01.2024'),
            ],
          ),
          TranscriptNode(
            name: 'business_and_economics',
            courses: [
              TranscriptCourse(id: 'be-1', courseName: 'Microeconomics', ects: 6, grade: 2.3, examDate: '05.03.2024'),
              TranscriptCourse(id: 'be-2', courseName: 'Corporate Strategy', ects: 6, grade: 1.7, examDate: '08.03.2024'),
            ],
          ),
        ],
      ),
      TranscriptNode(name: 'free_electives', courses: [TranscriptCourse(courseName: "Math modeling", ects: 6, grade: 1.7, id: "37838", examDate: '22.04.2024')], children: []),
    ],
  ),
);

final UserTranscript emptyTranscript = UserTranscript(
  userID: 'test-user-2',
  programLiteral: 'ISM',
  transcript: TranscriptDocument(
    children: [
      TranscriptNode(name: 'compulsory_electives', courses: [], children: []),
      TranscriptNode(name: 'free_electives', courses: [], children: []),
    ],
  ),
);

void main() {
  group('ISMTranscript.calculateGPA', () {
    test('returns weighted average for transcript with courses', () {
      final gpa = calculateGPA(transcriptWithCourses);
      expect(gpa, isNotNull);
      expect(gpa, closeTo(1.61, 0.06));
    });

    test('returns null for empty transcript', () {
      final gpa = calculateGPA(emptyTranscript);
      expect(gpa, isNull);
    });
  });

  group('ISMTranscript.getOverviewCategories', () {
    test('returns categories with correct progress', () {
      final categories = ISMTranscript.getOverviewCategories(transcriptWithCourses);
      print(categories);
      expect(categories.length, 4);

      // Compulsory Electives: 36 earned ECTS
      final inf_systems = categories.firstWhere((c) => c.name == 'Information systems');
      final inf_Ects = inf_systems.courses?.fold(0, (sum, c) => sum + c.ects) ?? 0;
      expect(inf_Ects, 12);
      expect(inf_systems.courses?.length, 2);

      // Free Electives: 6 earned / 12 required = 0.5
      final feCategory = categories.firstWhere((c) => c.name == 'Free Electives');
      final feEarnedEcts = feCategory.courses?.fold(0, (sum, c) => sum + c.ects) ?? 0;
      expect(feEarnedEcts, 6);
      expect(feCategory.progress, closeTo(0.5, 0.01));
    });

    test('returns categories with zero progress for empty transcript', () {
      final categories = ISMTranscript.getOverviewCategories(emptyTranscript);

      for (final category in categories) {
        final earnedEcts = category.courses?.fold(0, (sum, c) => sum + c.ects) ?? 0;
        expect(earnedEcts, 0);
        expect(category.progress, 0.0);
      }
    });
  });
}
