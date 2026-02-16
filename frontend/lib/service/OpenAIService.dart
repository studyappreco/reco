import 'dart:convert';
import 'dart:io';
import 'package:frontend/models/TranscriptDocument.dart';
import 'package:frontend/utils/RecoLog.dart';
import '../models/Module.dart';
import 'package:frontend/service/prompts.dart';
import 'package:frontend/ui/utils/mapping.dart';
import 'package:dart_openai/dart_openai.dart';

const EMBEDDING_MODEL = "text-embedding-3-small";
const TRANSCRIPT_PARSING_SYSTEM_PROMPT =
    "You are an expert at converting university transcripts into structured tree based JSON formats.";

final jsonSchema = {
  "\$schema": "http://json-schema.org/draft-07/schema#",
  "title": "TranscriptDocument",
  "type": "object",
  "required": ["children"],
  "additionalProperties": false,
  "properties": {
    "children": {
      "type": "array",
      "items": {"\$ref": "#/\$defs/TranscriptNode"},
    },
  },
  "\$defs": {
    "TranscriptNode": {
      "type": "object",
      "required": ["name", "courses", "children"],
      "additionalProperties": false,
      "properties": {
        "name": {"type": "string"},
        "courses": {
          "type": ["array", "null"],
          "items": {"\$ref": "#/\$defs/TranscriptCourse"},
        },
        "children": {
          "type": ["array", "null"],
          "items": {"\$ref": "#/\$defs/TranscriptNode"},
        },
      },
    },
    "TranscriptCourse": {
      "type": "object",
      "required": ["id", "name", "ects", "grade", "examDate"],
      "additionalProperties": false,
      "properties": {
        "id": {"type": "string"},
        "name": {"type": "string"},
        "ects": {"type": "number"},
        "grade": {"type": "number"},
        "examDate": {"type": "string"},
      },
    },
  },
};

class OpenAIService {
  OpenAIService();

  Future<List<Module>?> KnnQueryForCourses(String userID) async {
    return null;
  }

  Future<List<double>?> embedUserdetails(
    List<String> interests,
    String programLiteral,
  ) async {
    String? fullProgramName = getFullProgramName(programLiteral);
    if (fullProgramName == null) {
      return null;
    }
    String embedString = getUserdetailsEmbeddingPrompt(
      interests,
      fullProgramName,
    );
    OpenAIEmbeddingsModel embedding = await OpenAI.instance.embedding.create(
      model: EMBEDDING_MODEL,
      input: embedString,
    );

    return embedding.data.first.embeddings;
  }

  /// Returns null if the model refused, returned null (invalid input), or an error occurred
  Future<TranscriptDocument?> parseTranscriptPdf(
    File pdfFile,
    String programLiteral,
  ) async {
    final bytes = await pdfFile.readAsBytes();
    final base64Pdf = base64Encode(bytes);

    final response = await OpenAI.instance.responses.create(
      model: "gpt-5",
      input: [
        {"role": "system", "content": TRANSCRIPT_PARSING_SYSTEM_PROMPT},
        {
          "role": "user",
          "content": [
            {
              "type": "input_file",
              "filename": "transcript.pdf",
              "file_data": "data:application/pdf;base64,$base64Pdf",
            },
            {"type": "input_text", "text": getProgramPrompt(programLiteral)},
          ],
        },
      ],
      text: {
        "format": {
          "type": "json_schema",
          "name": "transcript_document",
          "strict": true,
          "schema": jsonSchema,
        },
      },
    );

    if (response.status != OpenAiResponseStatus.completed) {
      RecoLog.error("Transcript parsing request came back not completed");
      return null;
    }

    // Extract text from response: output[0].content[0].text
    final outputText = (response.output as List?)
        ?.firstWhere((item) => item['type'] == 'message', orElse: () => null)
        ?['content']?[0]?['text'] as String?;

    if (outputText == null) return null;

    return TranscriptDocument.fromJson(jsonDecode(outputText));
  }
}
