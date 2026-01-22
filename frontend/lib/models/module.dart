import 'package:mongo_dart/mongo_dart.dart';
import 'package:frontend/ui/widgets/Chip.dart';

// Model representing a university module
// It combines official data (from Moses), recommendation metrics and user-specific states
// Note: Fields not yet available in the database use static placeholders for now
class Module {
  final String id;
  final String title;
  final String moduleNr;
  final String credits;
  final String examType;
  final String? matchBasis;
  final int matchPercentage;
  final double? rating;
  final int ratingCount;
  final List<ChipType> tags;
  bool isFavorite;
  bool isPlanned;
  final String? learnContent;
  final String? learnResult;

  Module({
    required this.id,
    required this.title,
    required this.moduleNr,
    required this.credits,
    required this.examType,
    this.matchBasis,
    required this.matchPercentage,
    this.rating,
    this.ratingCount = 0,
    required this.tags,
    this.isFavorite = false,
    this.isPlanned = false,
    this.learnContent,
    this.learnResult,
  });

  factory Module.fromMap(Map<String, dynamic> map) {
    return Module(
      id: (map['_id'] as ObjectId).oid,

      // Official Data (e.g. retrieved from Moses)
      title: map['title'] ?? "No Title",
      moduleNr: map['number']?.toString() ?? "N/A",
      credits: map['ects']?.toString() ?? "0",
      learnContent: map['learn_content'],
      learnResult: map['learn_result'],
      examType: "Not specified",  // Static placeholder
      tags: [], // Static placeholder
      
      // Data from the recommendation system
      matchPercentage: 0, // Static placeholder
      matchBasis: null, // Static placeholder

      // Community Ratings (Future Work)
      rating: null, // Static placeholder
      ratingCount: 0, // Static placeholder

      // account-specific data
      isFavorite: false, // Static placeholder
      isPlanned: false, // Static placeholder
    );
  }
}