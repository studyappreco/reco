import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/TranscriptDocument.dart';


const _csMasterPrompt = """
Extract all completed and failed exams from this transcript into a structured format.

Rules:
- German and English transcripts share the same structure (different column names)
- ECTS: Only include courses with 3-12 ECTS
- Grades: Only include grades between 0.0 and 5.0
- Dates: Format is dd.MM.yyyy

Overall structure of the Computer Science (CS) Masters Degree with English | German names is hierarchical:
    - two main categories: "Compulsory Electives" | "Wahlpflicht" and "Free Electives" | "Wahlbereich"
    - "Compulsory Electives" can be further subdivided into:
        - "Data and Software Engineering" | "Data and Software Engineering"
        - "Embedded Systems and Computer Architectures" | "Eingebettete Systeme und Rechnerarchitekturen"
        - "Foundations of Computing" | "Grundlagen der Informatik"
        - "Cognitive Systems" | "Kognitive Systeme"
        - "Digital Media and Human-Computer Interaction" | "Medientechnik und Mensch-Maschine-Interaktion"
        - "Distributed Systems and Networks" | "Verteilte Systeme und Netze"

For the output on how to call the TranscriptNodes per category:
  - "Data and Software Engineering" => "data_and_software_engineering"
  - "Embedded Systems and Computer Architectures" => "embedded_systems_and_computer_architectures"
  - "Foundations of Computing" => "foundations_of_computing"
  - "Cognitive Systems" => "cognitive_systems"
  - "Digital Media and Human-Computer Interaction" => "digital_media_and_human_computer_interaction"
  - "Distributed Systems and Networks" => "distributed_systems_and_networks"
  - "Compulsory Electives" => "compulsory_electives"
  - "Free Electives" => "free_electives"

Even if certain categories that are named above do not appear in the transcript directly include it as a TranscriptNode with an empty array of courses.

If the provided content does not match the CS master transcript rules and structure return null.
""";


const _csBachelorPrompt = """
Extract all completed and failed exams from this transcript into a structured format.

Rules:
- German and English transcripts share the same structure (different column names)
- ECTS: Only include courses with 3-12 ECTS
- Grades: include not only grades between 0.0 and 5.0, there are modules without a grade
- Dates: Format is dd.MM.yyyy
- Exclude entries starting with "Leistungsnachweis: "

Overall structure of the Computer Science (CS) Bachelors Degree with English | German names is hierarchical:
  - three main categories: "Compulsory Modules" | "Pflichtbereich", "Compulsory Electives" | "Wahlpflichtbereich" and "Free Electives" | "Wahlbereich"
  - "Compulsory Modules"
      - can have courses directly and are not further subdivided
  - "Compulsory Electives" can be further subdivided into:
      - "Technical Computer Science" | "Technische Informatik"
      - "Programming Practical" | "Programmierpraktikum"
      - "Theoretical Computer Science" | "Theoretische Informatik"
      - "Computer Science Catalog" | "Katalog Informatik"
  - "Free Electives"
      - can have courses directly and are not further subdivided

For the output on how to call the TranscriptNodes per category:
  - "Compulsory Modules" => "compulsory_modules"
  - "Compulsory Electives" => "compulsory_electives"
  - "Free Electives" => "free_electives"
  - "Technical Computer Science" => "technical_computer_science"
  - "Programming Practical" => "programming_practical"
  - "Theoretical Computer Science" => "theoretical_computer_science"
  - "Computer Science Catalog" => "computer_science_catalog"

If the course is prefixed with "Modulprüfung: "

Even if certain categories that are named above do not appear in the transcript directly include it as a TranscriptNode with an empty array of courses.

Don't confuse "Technical Foundations of Computer Science" | "Technische Grundlagen der Informatik" with "Theoretical Computer Science" | "Theoretische Informatik".
These are two different things. One is under compulsory modules and one under compulsory electives

If the provided content does not match the CS bachelor transcript rules and structure return null.
""";

const _ismPrompt = '''
Extract all completed and failed exams from this transcript into a structured format.

Rules:
- German and English transcripts share the same structure (different column names)
- ECTS: Only include courses with 3-12 ECTS
- Grades: Only include grades between 0.0 and 5.0
- Dates: Format is dd.MM.yyyy

Overall structure of the Information Systems Management (ISM) Masters Degree with English | German names is hierarchical:
    - two main categories: "Compulsory Electives" | "Wahlpflicht" and "Free Electives" | "Wahlbereich"
    - "Compulsory Electives" can be further subdivided into "Information Systems" | "Informationssysteme"  , "Computer Science" | "Informatik" and "Business and Economics" 
    - "Computer Science" can be further subdivided into "Distributed Systems and Networks" and "Data and Software Engineering"

For the output on how to call the TranscriptNodes per category:
  - "Information Systems" => "information_systems"
  - "Computer Science" => "computer_science"
  - "Business and Economics" => "business_and_economics"
  - "Compulsory Electives" => "compulsory_electives"
  -  "Free Electives" => "free_electives"
  
  Even if certain categories that are named above do not appear in the transcript directly include it as a TranscriptNode with an empty array of courses.

  
 If the provided content does not match the ISM transcript rules and structure return null.
''';

String getProgramPrompt(String programLiteral) {
  return switch (programLiteral) {
    'ISM' => _ismPrompt,
    'CS_M' => _csMasterPrompt,
    'CS_B' => _csBachelorPrompt,
    _ => throw ArgumentError('Unknown program: $programLiteral'),
  };
}

class OpenAIService {
  final String apiKey;

  OpenAIService(this.apiKey);

  /// Returns null if the model refused, returned null (invalid input), or an error occurred
  Future<TranscriptDocument?> parseTranscriptPdf(File pdfFile, String programLiteral) async {
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
          "required": ["id", "name", "ects", "grade", "examDate"],
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
            },
            "examDate" : {
              "type" : "string"
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
            "role": "system",
            "content": "You are an expert at converting university transcripts into structured tree based JSON formats."
          },
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
      debugPrint('OpenAI API error: ${response.body}');
      return null;
    }

    final data = jsonDecode(response.body);
    debugPrint('OpenAI response: ${response.body}');

    // Check if the request was refused
    final status = data['status'] as String?;
    if (status == 'incomplete') {
      final reason = data['incomplete_details']?['reason'] as String?;
      debugPrint('Request incomplete: $reason');
      return null;
    }

    // Extract the message from output
    final output = data['output'] as List?;
    final messageItem = output?.firstWhere(
      (item) => item['type'] == 'message',
      orElse: () => null,
    );

    // Extract content
    final content = messageItem?['content'] as List?;
    final firstContent = content?.firstOrNull;
    if (firstContent == null) {
      debugPrint('No content in response');
      return null;
    }

    // Check for refusal
    if (firstContent['type'] == 'refusal') {
      debugPrint('Request was refused: ${firstContent['refusal']}');
      return null;
    }

    // Extract text content
    final outputText = firstContent['text'] as String?;
    if (outputText == null) {
      debugPrint('No text in response');
      return null;
    }

    // Parse JSON - may be null for invalid user input
    final transcriptJson = jsonDecode(outputText);
    if (transcriptJson == null) {
      debugPrint('Model returned null - invalid transcript input');
      return null;
    }

    return TranscriptDocument.fromJson(transcriptJson);
  }
}
