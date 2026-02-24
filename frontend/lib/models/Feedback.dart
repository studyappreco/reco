import 'package:mongo_dart/mongo_dart.dart';

class ModuleFeedback {
  final String id;
  final String userId;
  final String feedbackText;
  final int rating;
  final String createdAt;

  ModuleFeedback({
    required this.id,
    required this.userId,
    required this.feedbackText,
    required this.rating,
    this.createdAt = "",
  });

  factory ModuleFeedback.fromMap(Map<String, dynamic> map) {
    return ModuleFeedback(
      id: map['_id'] is ObjectId ? (map['_id'] as ObjectId).oid : map['_id'].toString(),
      userId: map['userId'] ?? "Anonymous",
      feedbackText: map['feedbackText'] ?? "",
      rating: map['rating'] is int ? map['rating'] : int.tryParse(map['rating']?.toString() ?? "0") ?? 0,
      createdAt: map['created_at'] ?? "",
    );
  }
}