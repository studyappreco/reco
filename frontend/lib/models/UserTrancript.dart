import 'package:frontend/models/TranscriptDocument.dart';

// Collection type for MongoDB
class UserTranscript {
  final String userID;
  final TranscriptDocument transcript;
  final String programLiteral;

  UserTranscript({
    required this.userID,
    required this.transcript,
    required this.programLiteral,
  });

  factory UserTranscript.fromJson(Map<String, dynamic> json) {
    return UserTranscript(
      userID: json['userID'] as String,
      programLiteral: json['programLiteral'],
      transcript: TranscriptDocument.fromJson(json['transcript'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'programLiteral': this.programLiteral,
      'transcript': transcript.toJson(),
    };
  }
}