import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/TranscriptDocument.dart';
import 'package:frontend/models/UserTrancript.dart';
import 'package:frontend/service/MongoService.dart';
import 'package:frontend/service/OpenAIService.dart';

class TranscriptRepository {
  final OpenAIService _openAIService;
  final MongoService _mongoService;

  TranscriptRepository({
    OpenAIService? openAIService,
    MongoService? mongoService,
  })  : _openAIService = openAIService ?? OpenAIService(dotenv.env['OPENAI_API_KEY']!),
        _mongoService = mongoService ?? MongoService();


  Future<TranscriptDocument?> uploadAndParseTranscript({
    required File pdfFile,
    required String userID,
    required String programLiteral,
  }) async {
    try {
      // Parse the PDF using OpenAI
      final transcript = await _openAIService.parseTranscriptPdf(pdfFile, programLiteral);
      if (transcript != null) {
        // Store in MongoDB
        await _mongoService.uploadTranscript(userID, transcript, programLiteral);
        return transcript;
      }

      return null;
    } on ArgumentError catch (e) {
      debugPrint('Invalid program literal: $e');
      return null;
    } on FormatException catch (e) {
      debugPrint('Failed to parse OpenAI response: $e');
      return null;
    } on Exception catch (e) {
      debugPrint('Failed to upload/parse transcript: $e');
      return null;
    }
  }

  Future<UserTranscript?> getTranscript(String userID) async {
    try {
      return await _mongoService.getTranscript(userID);
    } on Exception catch (e) {
      debugPrint('Failed to get transcript: $e');
      return null;
    }
  }

  Future<bool> deleteTranscript(String userID) async {
    try {
      await _mongoService.deleteTranscript(userID);
      return true;
    } on Exception catch (e) {
      debugPrint('Failed to delete transcript: $e');
      return false;
    }
  }
}

// for background processing
enum TranscriptProcessingState {
  idle,
  processing,
  completed,
  failed,
}

class TranscriptProcessor extends ChangeNotifier {
  final TranscriptRepository _repository;

  TranscriptProcessingState _state = TranscriptProcessingState.idle;
  String? _errorMessage;

  TranscriptProcessor({TranscriptRepository? repository})
      : _repository = repository ?? TranscriptRepository();

  TranscriptProcessingState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isProcessing => _state == TranscriptProcessingState.processing;

  Future<void> processTranscript({
    required File pdfFile,
    required String userID,
    required String programLiteral,
  }) async {
    _state = TranscriptProcessingState.processing;
    _errorMessage = null;
    notifyListeners();

    try {
      final transcript = await _repository.uploadAndParseTranscript(
        pdfFile: pdfFile,
        userID: userID,
        programLiteral: programLiteral,
      );

      if (transcript != null) {
        _state = TranscriptProcessingState.completed;
      } else {
        _state = TranscriptProcessingState.failed;
        _errorMessage = 'Failed to parse transcript';
      }
    } catch (e) {
      _state = TranscriptProcessingState.failed;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }
}
