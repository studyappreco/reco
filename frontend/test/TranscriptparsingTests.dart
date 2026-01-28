import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/TranscriptDocument.dart';
import 'package:frontend/models/UserTrancript.dart';
import 'package:frontend/repos/ISMTranscript.dart';
import 'package:frontend/repos/TranscriptRepository.dart';

String getTranscriptPath(String filename) {
  return '${Directory.current.path}/lib/transcripts/$filename';
}

void main() async {
  await dotenv.load(fileName: ".env");
  final repo = TranscriptRepository();

  group('Parse ISM transcript', () {
    test('returns TranscriptDocument and correct ECTS', () async {
      print("starting on ISM test");
      final pdfFile = File(getTranscriptPath('transcript_ISM_master.pdf'));
      final res = await repo.uploadAndParseTranscript(pdfFile: pdfFile, userID: "test-user", programLiteral: "ISM");

      expect(res, isNotNull);
      expect(res, isA<TranscriptDocument>());
      print('ISM Transcript Response:');
      print(res!.toJson());

      final userTranscript = UserTranscript(userID: "test-user", programLiteral: "ISM", transcript: res!);
      final totalEcts = ISMTranscript.calculateTotalEarnedECTS(userTranscript);
      print('Total ECTS: $totalEcts');
      expect(totalEcts, 51);
    });
  });

  group('Parse Computer Science Master Transcript', () {
    test('returns TranscriptDocument and correct ECTS', () async {
      print("starting on CS master test");
      final pdfFile = File(getTranscriptPath('transcript_CS_master.pdf'));
      final res = await repo.uploadAndParseTranscript(pdfFile: pdfFile, userID: "test-user", programLiteral: "CS_M");

      expect(res, isNotNull);
      expect(res, isA<TranscriptDocument>());
      print('CS Master Transcript Response:');
      print(res!.toJson());

      final userTranscript = UserTranscript(userID: "test-user", programLiteral: "CS_M", transcript: res!);
      final totalEcts = ISMTranscript.calculateTotalEarnedECTS(userTranscript);
      print('Total ECTS: $totalEcts');
      expect(totalEcts, 24);
    });
  });

  group('Parse Computer Science Bachelor Transcript', () {
    test('returns TranscriptDocument and correct ECTS', () async {
      print("starting on CS bachelor test");
      final pdfFile = File(getTranscriptPath('transcript_CS_bachelor.pdf'));
      final res = await repo.uploadAndParseTranscript(pdfFile: pdfFile, userID: "test-user", programLiteral: "CS_B");

      expect(res, isNotNull);
      expect(res, isA<TranscriptDocument>());
      print('CS Bachelor Transcript Response:');
      print(res!.toJson());

      final userTranscript = UserTranscript(userID: "test-user", programLiteral: "CS_B", transcript: res!);
      final totalEcts = ISMTranscript.calculateTotalEarnedECTS(userTranscript);
      print('Total ECTS: $totalEcts');
      expect(totalEcts, 123);
    });
  });

  group('Parse wrong user input', () {
    test('returns null for invalid transcript', () async {
      final pdfFile = File(getTranscriptPath('streamr-network-lightpaper.pdf'));
      final res = await repo.uploadAndParseTranscript(pdfFile: pdfFile, userID: "test-user", programLiteral: "CS_B");

      print('Wrong Input Response:');
      print(res);

      expect(res, isNull);
    });
  });

  // TODO: add input too large
}