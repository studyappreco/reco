import 'package:frontend/models/TranscriptDocument.dart';

// Collection type for MongoDB
class UserTranscript {
  final String userID;
  final String programLiteral;
  final TranscriptDocument transcript;

  UserTranscript({
    required this.userID,
    required this.programLiteral,
    required this.transcript,
  });

  factory UserTranscript.fromJson(Map<String, dynamic> json) {
    return UserTranscript(
      programLiteral: json['programLiteral'],
      userID: json['userID'] as String,
      transcript: TranscriptDocument.fromJson(json['transcript'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'programLiteral': programLiteral,
      'transcript': transcript.toJson(),
    };
  }
}