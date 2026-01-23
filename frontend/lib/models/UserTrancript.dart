import 'package:frontend/models/TranscriptDocument.dart';

// Collection type for MongoDB
class UserTranscript {
  final String userID;
  final TranscriptDocument transcript;

  UserTranscript({
    required this.userID,
    required this.transcript,
  });

  factory UserTranscript.fromJson(Map<String, dynamic> json) {
    return UserTranscript(
      userID: json['userID'] as String,
      transcript: TranscriptDocument.fromJson(json['transcript'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'transcript': transcript.toJson(),
    };
  }
}