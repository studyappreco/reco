import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/TranscriptDocument.dart';

const _ismPrompt = '''
Extract all completed exams from this transcript into a structured format.

Rules:
- German and English transcripts share the same structure (different column names)
- ECTS: Only include courses with 3-12 ECTS
- Grades: Only include grades between 0.0 and 5.0
- Dates: Format is dd.MM.yyyy

Structure:
- Group courses by their categories (e.g., "Core Studies", "Elective Modules", "Compulsary Electives")
- Preserve the hierarchy: Category > Domain > Subdomain > Course

In the ISM Master you have compulsary electives and free electives as main categories. compulsary electives can be further subdivided into 
"Information systems", "computer science", "business and economics". "computer science" can be further subdivided into "Distributed systems and networks" and "Data and software engineering"
''';

String getProgramPrompt(String programLiteral) {
  return switch (programLiteral) {
    'ISM' => _ismPrompt,
    _ => throw ArgumentError('Unknown program: $programLiteral'),
  };
}

class OpenAIService {
  final String apiKey;

  OpenAIService(this.apiKey);

  Future<TranscriptDocument> parseTranscriptPdf(File pdfFile, String programLiteral) async {
    final bytes = await pdfFile.readAsBytes();
    final base64Pdf = base64Encode(bytes);

    //resembles the transcript type in JSON schema
    // TODO: augement the course (leaf) data
    final jsonSchema =  {
      "\$schema": "http://json-schema.org/draft-07/schema#",
      "title": "TranscriptDocument",
      "type": "object",
      "required": ["children"],
      "additionalProperties": false,
      "properties": {
        "children": {
          "type": "array",
          "items": {
            "\$ref": "#/\$defs/TranscriptNode"
          }
        }
      },
      "\$defs": {
        "TranscriptNode": {
          "type": "object",
          "required": ["name", "courses", "children"],
          "additionalProperties": false,
          "properties": {
            "name": {
              "type": "string"
            },
            "courses": {
              "type": ["array", "null"],
              "items": {
                "\$ref": "#/\$defs/TranscriptCourse"
              }
            },
            "children": {
              "type": ["array", "null"],
              "items": {
                "\$ref": "#/\$defs/TranscriptNode"
              }
            }
          }
        },
        "TranscriptCourse": {
          "type": "object",
          "required": ["id", "name", "ects", "grade"],
          "additionalProperties": false,
          "properties": {
            "id": {
              "type": "string"
            },
            "name": {
              "type": "string"
            },
            "ects": {
              "type": "number"
            },
            "grade": {
              "type": "number"
            }
          }
        }
      }
    };
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/responses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "gpt-5",
        "input": [
          {
            "role": "user",
            "content": [
              {
                "type": "input_file",
                "filename": "transcript.pdf",
                "file_data": "data:application/pdf;base64,$base64Pdf"
              },
              {
                "type": "input_text",
                "text": getProgramPrompt(programLiteral)
              }
            ]
          }
        ],
        "text": {
          "format": {
            "type": "json_schema",
            "name": "transcript_document",
            "strict": true,
            "schema": jsonSchema
          }
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('OpenAI API error: ${response.body}');
    }

    final data = jsonDecode(response.body);
    debugPrint('OpenAI response: ${response.body}');
    final output = data['output'] as List?;
    if (output == null || output.isEmpty) {
      throw Exception('No output in response: ${response.body}');
    }
    final messageItem = output.firstWhere(
      (item) => item['type'] == 'message',
      orElse: () => null,
    );
    if (messageItem == null) {
      throw Exception('No message in output: ${response.body}');
    }

    final content = messageItem['content'] as List?;
    if (content == null || content.isEmpty) {
      throw Exception('No content in message: ${response.body}');
    }

    final outputText = content[0]['text'] as String?;
    if (outputText == null) {
      throw Exception('No text in content: ${response.body}');
    }

    final transcriptJson = jsonDecode(outputText);
    return TranscriptDocument.fromJson(transcriptJson);
  }
}
