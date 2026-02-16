import 'package:frontend/models/TranscriptDocument.dart';
import 'package:frontend/models/UserTrancript.dart';
import 'package:frontend/repos/transcriptUtils.dart';

class ISMTranscript extends Transcript {

  @override
  String get literal => "ISM_M";

  @override
  int get programCredits => 120;

  // important: have to match with the prompt
  @override
  Map<String, int> get creditsForCategories => const {
    "information_systems" : 30,
    "computer_science" : 24,
    "business_and_economics" : 24,
    "free_electives" : 12
  };

  // important: have to match with the prompt
  @override
  Map<String, String> get categoriesForDashboard => const {
    "information_systems" : "Information Systems",
    "computer_science" : "Computer Science",
    "business_and_economics" : "Business and Economics",
    "free_electives" : "Free Electives"
  };

  @override
  UserTranscript createEmptyUserTranscript(String userID) {
    return UserTranscript(
      userID: userID,
      transcript: TranscriptDocument(
        children: [
          TranscriptNode(
            name: "compulsory_electives",
            children: [
              TranscriptNode(name: "information_systems"),
              TranscriptNode(name: "computer_science"),
              TranscriptNode(name: "business_and_economics")
            ]
          ),
          TranscriptNode(name: "free_electives")
        ]
      )
    );
  }
}
