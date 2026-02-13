class UserDetails {
  final String userID;
  final String username;
  final String programLiteral;
  final List<String> interests;
  final List<String> plannedModuleNrs;
  final List<String> favoritedModuleNrs;

  UserDetails({
    required this.userID,
    required this.programLiteral,
    required this.username,
    required this.interests,
    required this.plannedModuleNrs,
    required this.favoritedModuleNrs,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      userID: json['userID'] ?? '',
      username: json['username'] ?? '',
      programLiteral: json['programLiteral'] ?? "ISM", // TODO: change
      interests: List<String>.from(json['interests'] ?? []),
      plannedModuleNrs: List<String>.from(json['planned_modules'] ?? []),
      favoritedModuleNrs: List<String>.from(json['favorited_modules'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'username': username,
      'interests': interests,
      'planned_modules': plannedModuleNrs,
      'programLiteral' : programLiteral,
      'favorited_modules': favoritedModuleNrs,
    };
  }
}