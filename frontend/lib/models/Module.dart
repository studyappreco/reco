import 'package:frontend/theme/colors.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:frontend/ui/widgets/Chip.dart';
import 'package:frontend/models/Feedback.dart';

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
  
  final List<dynamic> assignedDegrees;
   
  final String? matchBasis;
  final int matchPercentage;
  final double? rating;
  final int ratingCount;
  final List<ChipType> tags;

  final List<ModuleFeedback> feedbacks;

  bool isFavorite;
  bool isPlanned;

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
    this.assignedDegrees = const [],
    this.version,
    this.matchBasis,
    required this.matchPercentage,
    this.rating,
    this.ratingCount = 0,
    required this.tags,
    this.feedbacks = const [],
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
        return ChipType(tag.toString(), AppColors.primaryBlue);}).toList();  //TODO The colors should come from DB (future work, is not very important at the moment)
    }

    List<ModuleFeedback> parsedFeedbacks = [];
    if(map['feedbacks'] != null){
      parsedFeedbacks = (map['feedbacks'] as List)
          .map((f) => ModuleFeedback.fromMap(f))
          .toList();
    }

    int calculatedRatingCount = parsedFeedbacks.length;
    double? calculatedRating;
    if(parsedFeedbacks.isNotEmpty){
      double sum = parsedFeedbacks.fold(0, (p, c) => p + c.rating);
      double average = sum / parsedFeedbacks.length;
      
      double base = average.floorToDouble(); 
      double decimals = average - base; 
      
      if(decimals < 0.25){
        calculatedRating = base;
      } else if (decimals >= 0.75) {
        calculatedRating = base + 1.0;
      } else {
        calculatedRating = base + 0.5;
      }
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
      
      assignedDegrees: map['assigned_degrees'] ?? [],

      learnContent: map['learn_content'],
      learnResult: map['learn_outcomes'],
      courseSummary : map['course_summary'],

      tags: parsedTags,

      feedbacks: parsedFeedbacks,

      passRate: "X%", // Static placeholder
      students: 0,     // Static placeholder
      duration: "X",  // Static placeholder

      // Data from the recommendation system
      matchPercentage: 0, // Static placeholder
      matchBasis: null, // Static placeholder

      // Community Ratings
      rating: calculatedRating, 
      ratingCount: calculatedRatingCount,

      // account-specific data
      isFavorite: userFavorites.contains(moduleNr),
      isPlanned: userPlanned.contains(moduleNr),
    );
  }
}
