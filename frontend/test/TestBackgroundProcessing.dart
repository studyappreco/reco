import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/repos/TranscriptRepository.dart';
import 'package:frontend/service/MongoService.dart';
import 'package:frontend/service/OpenAIService.dart';


String getTranscriptPath(String filename) {
  return '${Directory.current.path}/lib/transcripts/$filename';
}

void main() async {
  final openAIService = OpenAIService();
  final mongoService = MongoService();
  final transcriptRepo = TranscriptRepository(openAIService: openAIService, mongoService: mongoService);
  await dotenv.load(fileName: ".env");

  group('TranscriptProcessor state changes', () {

    test('notifies listeners when state changes to processing', () async {
      final processor = TranscriptProcessor(repository: transcriptRepo);
      final states = <TranscriptProcessingState>[];

      processor.addListener(() {
        states.add(processor.state);
      });

      var userID = "test-user-notify";
      var programLiteral = "ISM_M";
      final pdfFile = File(getTranscriptPath('transcript_ISM_master.pdf'));

      // Start processing (don't await yet)
      final future = processor.processTranscript(
        pdfFile: pdfFile,
        userID: userID,
        programLiteral: programLiteral,
      );

      // First notification should be 'processing'
      expect(states.first, TranscriptProcessingState.processing);
      expect(processor.isProcessing, true);

      // Wait for completion
      await future;

      // Should have at least 2 notifications: processing -> completed/failed
      expect(states.length, greaterThanOrEqualTo(2));
      expect(
        states.last,
        anyOf(TranscriptProcessingState.completed, TranscriptProcessingState.failed),
      );
      expect(processor.isProcessing, false);

      // Cleanup
      await transcriptRepo.deleteTranscript(userID);
    });
  });

  group('Parse ISM transcript', () {
    test('processes transcript and updates state', () async {
      debugPrint("starting on ISM test");
      final processor = TranscriptProcessor(repository: transcriptRepo);

      var userID = "test-user";
      var programLiteral = "ISM_M";
      final pdfFile = File(getTranscriptPath('transcript_ISM_master.pdf'));

      var trans = await transcriptRepo.getTranscript(userID: userID, forceRefresh: false);
      if (trans == null) {
        // process the transcript
        await processor.processTranscript(
          pdfFile: pdfFile,
          userID: userID,
          programLiteral: programLiteral,
        );

        // Verify state changed
        expect(
          processor.state,
          anyOf(TranscriptProcessingState.completed, TranscriptProcessingState.failed),
        );
      }
      await transcriptRepo.deleteTranscript(userID);
    });
  });
}
