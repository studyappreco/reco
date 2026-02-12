import 'package:frontend/repos/transcriptUtils.dart';

class CSMTranscript extends Transcript {

  @override
  int get programCredits => 120;

  // important: have to match with the prompt
  @override
  Map<String, int> get creditsForCategories => const {
    "data_and_software_engineering": 18,
    "embedded_systems_and_computer_architectures": 18,
    "foundations_of_computing": 18,
    "cognitive_systems": 18,
    "digital_media_and_human_computer_interaction": 18,
    "distributed_systems_and_networks": 18,
    "free_electives": 12
  };

  // important: have to match with the prompt
  @override
  Map<String, String> get categoriesForDashboard => const {
    "data_and_software_engineering": "Data and Software Engineering",
    "embedded_systems_and_computer_architectures": "Embedded Systems and Computer Architectures",
    "foundations_of_computing": "Foundations of Computing",
    "cognitive_systems": "Cognitive Systems",
    "digital_media_and_human_computer_interaction": "Digital Media and Human-Computer Interaction",
    "distributed_systems_and_networks": "Distributed Systems and Networks",
    "free_electives": "Free Electives"
  };
}
