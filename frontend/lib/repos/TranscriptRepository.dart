import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/TranscriptDocument.dart';
import 'package:frontend/models/UserTrancript.dart';
import 'package:frontend/service/MongoService.dart';
import 'package:frontend/service/OpenAIService.dart';
import 'package:frontend/utils/logger.dart';

class TranscriptRepository {
  final OpenAIService _openAIService;
  final MongoService _mongoService;

  TranscriptRepository({
    OpenAIService? openAIService,
    MongoService? mongoService,
  })  : _openAIService = openAIService ?? OpenAIService(dotenv.env['OPENAI_API_KEY'] ?? ""),
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

  Future<bool?> hasTranscript(String userID) async {
    try {
      return await _mongoService.transcriptExists(userID);
    } on Exception catch (e) {
      debugPrint('Failed to check transcript existence: $e');
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

  Future<bool> addCompletedCourseToTranscript({
    required String userID,
    required String courseName,
    required String moduleNr,
    required double grade,
    required int ects,
    required String targetCategoryName,
    required String examDate,
  }) async {
    try {
      UserTranscript? userTranscript = await _mongoService.getTranscript(userID);
      // TODO proposal: even if the user has not uploaded a transcript, the empty list should already be in the database so that there are no problems here
      if(userTranscript == null){
        Log.warning("UserTranscript is null");
        return false;
      }

      bool added = false;
      
      // I've used the logic from transcriptUtil.dart in calculateTotalEarnedECTS() here
      void traverseAndAdd(TranscriptNode node){
        if(added)return;

        if(node.name == targetCategoryName){
          node.courses ??= [];
          node.courses!.add(TranscriptCourse(
            id: moduleNr,
            courseName: courseName,
            ects: ects,
            grade: grade,
            examDate: examDate,
          ));
          added = true;
        } else {
          if(node.children != null){
            for(var child in node.children!){
              traverseAndAdd(child);
            }
          }
        }
      }

      for(var rootNode in userTranscript.transcript.children){
        traverseAndAdd(rootNode);
      }

      if(added){
        await _mongoService.updateTranscript(userID, userTranscript.transcript);
        Log.info("Added $courseName to transcript under $targetCategoryName");
        return true;
      } else {
        Log.warning("Category ID '$targetCategoryName' not found in transcript tree");
        return false;
      }

    } catch (e, s) {
      Log.error("Failed to add course to transcript", e, s);
      return false;
    }
  }
}