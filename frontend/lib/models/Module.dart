import 'package:frontend/theme/colors.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:frontend/ui/widgets/Chip.dart';

// Model representing a university module
// It combines official data (from Moses), recommendation metrics and user-specific states
class Module {
  final String id;
  final String url;
  final String title;
  final String moduleNr;
  final String credits;
  final String examType;
  final String responsible;
  final String language;
  final String term;
  final int? version;
  
  final Map<String, dynamic> paths;
  final double? rating;
  final int ratingCount;
  final List<ChipType> tags;

  bool isFavorite;
  bool isPlanned;
  bool isRecommended;

  final String? learnContent;
  final String? learnResult;
  final String? courseSummary;

  final String passRate;
  final int students;
  final String duration;

  Module({
    required this.id,
    required this.url,
    required this.title,
    required this.moduleNr,
    required this.credits,
    required this.examType,
    this.responsible = "Unknown",
    this.language = "Unknown",
    this.term = "",
    this.paths = const <String, dynamic>{},
    this.version,
   this.isRecommended = false,
    this.rating,
    this.ratingCount = 0,
    required this.tags,
    this.isFavorite = false,
    this.isPlanned = false,
    this.learnContent,
    this.learnResult,
    this.courseSummary,
    this.passRate = "-",
    this.students = 0,
    this.duration = "-",
  });

  factory Module.fromMap(
    Map<String, dynamic> map, {
    required List<String> userFavorites,
    required List<String> userPlanned,
  }) {
    
    List<ChipType> parsedTags = [];
    if(map['keywords'] != null){
      parsedTags = (map['keywords'] as List).map((tag){
        return ChipType(tag.toString(), AppColors.primaryBlue);}).toList();
    }

    String moduleNr = map['number']?.toString() ?? "N/A";

    return Module(
      id: (map['_id'] as ObjectId).oid,

      // Official Data from Moses
      url: map['url'] ?? '',
      title: map['title'] ?? "No Title",
      moduleNr: moduleNr,
      credits: map['credits']?.toString() ?? "0",
      examType: map['exam_type'] ?? "Not specified",
      
      responsible: map['responsible'] ?? "N/A",
      language: map['language'] ?? "N/A",
      term: map['term'] ?? "",

      paths: map['paths'] is Map<String, dynamic>
          ? map['paths'] as Map<String, dynamic>
          : <String, dynamic>{},

      learnContent: map['learn_content'],
      learnResult: map['learn_outcomes'],
      courseSummary : map['course_summary'],

      tags: parsedTags,

      passRate: "X%", // Static placeholder
      students: 0,     // Static placeholder
      duration: "X",  // Static placeholder

      // Community Ratings (Future Work)
      rating: null, // Static placeholder
      ratingCount: 0, // Static placeholder

      // account-specific data
      isFavorite: userFavorites.contains(moduleNr),
      isPlanned: userPlanned.contains(moduleNr),
      isRecommended: map['is_recommended'] ?? false,
    );
  }
}
