import 'package:frontend/models/TranscriptDocument.dart';
import 'package:frontend/models/UserTrancript.dart';
import 'package:frontend/repos/transcriptUtils.dart';

class CSBTranscript extends Transcript {

  @override
  String get literal => "CS_B";

  @override
  int get programCredits => 180;

  // important: have to match with the prompt
  @override
  Map<String, int> get creditsForCategories => const {
    "compulsory_electives" : 51,
    "compulsory_modules" : 102,
    "free_electives": 15
  };

  // important: have to match with the prompt
  @override
  Map<String, String> get categoriesForDashboard => const {
    "free_electives" : "Free Electives",
    "compulsory_electives" : "Compulsory Electives",
    "compulsory_modules" : "Compulsory Modules"
  };

  @override
  UserTranscript createEmptyUserTranscript(String userID) {
    return UserTranscript(
      userID: userID,
      transcript: TranscriptDocument(
        children: [
          TranscriptNode(name: "compulsory_modules"),
          TranscriptNode(
            name: "compulsory_electives",
            children: [
              TranscriptNode(name: "technical_computer_science"),
              TranscriptNode(name: "programming_practical"),
              TranscriptNode(name: "theoretical_computer_science"),
              TranscriptNode(name: "computer_science_catalog")
            ]
          ),
          TranscriptNode(name: "free_electives")
        ]
      )
    );
  }
}
