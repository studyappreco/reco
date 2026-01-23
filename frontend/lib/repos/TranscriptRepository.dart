import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/TranscriptDocument.dart';
import 'package:frontend/models/UserTrancript.dart';
import 'package:frontend/service/MongoService.dart';
import 'package:frontend/service/OpenAIService.dart';

sealed class TranscriptResult<T> {}

class TranscriptSuccess<T> extends TranscriptResult<T> {
  final T data;
  TranscriptSuccess(this.data);
}

class TranscriptError<T> extends TranscriptResult<T> {
  final String message;
  final Object? error;
  TranscriptError(this.message, [this.error]);
}

class TranscriptRepository {
  final OpenAIService _openAIService;
  final MongoService _mongoService;

  TranscriptRepository({
    OpenAIService? openAIService,
    MongoService? mongoService,
  })  : _openAIService = openAIService ?? OpenAIService(dotenv.env['OPENAI_API_KEY']!),
        _mongoService = mongoService ?? MongoService();


  Future<TranscriptResult<TranscriptDocument>> uploadAndParseTranscript({
    required File pdfFile,
    required String userID,
    required String programLiteral,
  }) async {
    try {
      // Parse the PDF using OpenAI
      final transcript = await _openAIService.parseTranscriptPdf(pdfFile, programLiteral);

      // Store in MongoDB
      await _mongoService.uploadTranscript(userID, transcript);

      return TranscriptSuccess(transcript);
    } on ArgumentError catch (e) {
      debugPrint('Invalid program literal: $e');
      return TranscriptError('Unsupported program: ${e.message}', e);
    } on FormatException catch (e) {
      debugPrint('Failed to parse OpenAI response: $e');
      return TranscriptError('Failed to parse transcript data', e);
    } on Exception catch (e) {
      debugPrint('Failed to upload/parse transcript: $e');
      return TranscriptError('Failed to process transcript', e);
    }
  }

  Future<TranscriptResult<UserTranscript>> getTranscript(String userID) async {
    try {
      final userTranscript = await _mongoService.getTranscript(userID);

      if (userTranscript == null) {
        return TranscriptError('No transcript found for user');
      }

      return TranscriptSuccess(userTranscript);
    } on Exception catch (e) {
      debugPrint('Failed to get transcript: $e');
      return TranscriptError('Failed to retrieve transcript', e);
    }
  }

  Future<TranscriptResult<bool>> hasTranscript(String userID) async {
    try {
      final exists = await _mongoService.transcriptExists(userID);
      return TranscriptSuccess(exists);
    } on Exception catch (e) {
      debugPrint('Failed to check transcript existence: $e');
      return TranscriptError('Failed to check transcript', e);
    }
  }

  Future<TranscriptResult<void>> deleteTranscript(String userID) async {
    try {
      await _mongoService.deleteTranscript(userID);
      return TranscriptSuccess(null);
    } on Exception catch (e) {
      debugPrint('Failed to delete transcript: $e');
      return TranscriptError('Failed to delete transcript', e);
    }
  }
}