import 'package:frontend/repos/transcriptUtils.dart';

class CSBTranscript extends Transcript {

  @override
  int program_ects = 180;

  // important: have to match with the prompt
  @override
  Map<String, int> ects_for_categories = {
    "compulsory_electives" : 51,
    "compulsory_modules" : 102,
    "free_electives": 15
  };

  // important: have to match with the prompt
  @override
  Map<String, String> categories_for_dashboard = {
    "free_electives" : "Free Electives",
    "compulsory_electives" : "Compulsory Electives",
    "compulsory_modules" : "Compulsory Modules"
  };
}