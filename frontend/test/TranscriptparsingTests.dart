import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/TranscriptDocument.dart';
import 'package:frontend/models/UserTrancript.dart';
import 'package:frontend/repos/TranscriptRepository.dart';
import 'package:frontend/repos/transcriptUtils.dart';

String getTranscriptPath(String filename) {
  return '${Directory.current.path}/lib/transcripts/$filename';
}

void main() async {
  await dotenv.load(fileName: ".env");
  final repo = TranscriptRepository();

  group('Parse ISM transcript', () {
    test('returns TranscriptDocument and correct ECTS', () async {
      debugPrint("starting on ISM test");
      final pdfFile = File(getTranscriptPath('transcript_ISM_master.pdf'));
      final res = await repo.uploadAndParseTranscript(pdfFile: pdfFile, userID: "test-user", programLiteral: "ISM");

      expect(res, isNotNull);
      expect(res, isA<TranscriptDocument>());
      final transcript = res!;
      debugPrint('ISM Transcript Response:');
      debugPrint(transcript.toJson().toString());

      final userTranscript = UserTranscript(userID: "test-user", programLiteral: "ISM", transcript: transcript);
      final totalEcts = calculateTotalEarnedECTS(userTranscript);
      debugPrint('Total ECTS: $totalEcts');
      expect(totalEcts, 51);
    });
  });

  group('Parse Computer Science Master Transcript', () {
    test('returns TranscriptDocument and correct ECTS', () async {
      debugPrint("starting on CS master test");
      final pdfFile = File(getTranscriptPath('transcript_CS_master.pdf'));
      final res = await repo.uploadAndParseTranscript(pdfFile: pdfFile, userID: "test-user", programLiteral: "CS_M");

      expect(res, isNotNull);
      expect(res, isA<TranscriptDocument>());
      final transcript = res!;
      debugPrint('CS Master Transcript Response:');
      debugPrint(transcript.toJson().toString());

      final userTranscript = UserTranscript(userID: "test-user", programLiteral: "CS_M", transcript: transcript);
      final totalEcts = calculateTotalEarnedECTS(userTranscript);
      debugPrint('Total ECTS: $totalEcts');
      expect(totalEcts, 24);
    });
  });

  group('Parse Computer Science Bachelor Transcript', () {
    test('returns TranscriptDocument and correct ECTS', () async {
      debugPrint("starting on CS bachelor test");
      final pdfFile = File(getTranscriptPath('transcript_CS_bachelor.pdf'));
      final res = await repo.uploadAndParseTranscript(pdfFile: pdfFile, userID: "test-user", programLiteral: "CS_B");

      expect(res, isNotNull);
      expect(res, isA<TranscriptDocument>());
      final transcript = res!;
      debugPrint('CS Bachelor Transcript Response:');
      debugPrint(transcript.toJson().toString());

      final userTranscript = UserTranscript(userID: "test-user", programLiteral: "CS_B", transcript: transcript);
      final totalEcts = calculateTotalEarnedECTS(userTranscript);
      debugPrint('Total ECTS: $totalEcts');
      expect(totalEcts, 123);
    });
  });

  group('Parse wrong user input', () {
    test('returns null for invalid transcript', () async {
      final pdfFile = File(getTranscriptPath('streamr-network-lightpaper.pdf'));
      final res = await repo.uploadAndParseTranscript(pdfFile: pdfFile, userID: "test-user", programLiteral: "CS_B");

      debugPrint('Wrong Input Response:');
      debugPrint(res.toString());

      expect(res, isNull);
    });
  });

  // TODO: add input too large
}
