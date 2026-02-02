import 'package:frontend/repos/transcriptUtils.dart';

class ISMTranscript extends Transcript {

  @override
  int programCredits = 120;

  // important: have to match with the prompt
  @override
  Map<String, int> creditsForCategories = {
    "information_systems" : 30,
    "computer_science" : 24,
    "business_and_economics" : 24,
    "free_electives" : 12
  };

  // important: have to match with the prompt
  @override
  Map<String, String> categoriesForDashboard = {
    "information_systems" : "Information Systems",
    "computer_science" : "Computer Science",
    "business_and_economics" : "Business and Economics",
    "free_electives" : "Free Electives"
  };
}
