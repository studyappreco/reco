import 'package:flutter/material.dart';
import 'package:frontend/theme/colors.dart'; 

class CourseCardStyles {
  
  // Course Card Style Light Mode
  static final BoxDecoration _lightDecorationCard = BoxDecoration(
    color: AppColors.standardWhitebackground,
    borderRadius: BorderRadius.circular(13),
    border: Border.all(color: Color.fromARGB(50, 0, 0, 0), width: 0.5),
  );

  // Course Card Style Dark Mode (A suggestion of what it could look like; we can change it later if we want to)
  static final BoxDecoration _darkDecorationCard = BoxDecoration(
    color: Color(0xFF2C2C2C),
    borderRadius: BorderRadius.circular(13),
    border: Border.all(color: Color.fromARGB(50, 255, 255, 255), width: 1),
  );

  // This gives the correct style (dark, light) to the course_card.dart based on theme Mode in the main
  static BoxDecoration getCardDecoration({required bool isDarkMode}) {
    return isDarkMode ? _darkDecorationCard : _lightDecorationCard;
  }

  // Match Percentage
  static BoxDecoration getMatchDecoration() {
    return BoxDecoration(
      color: AppColors.greenLight,
      borderRadius: BorderRadius.circular(20),
    );
  }

  // Favourite Icon
  static BoxDecoration getFavoriteDecoration({required bool isActive}) {
    return BoxDecoration(
      color: isActive ? AppColors.pinkLight : AppColors.pinkLight, 
      shape: BoxShape.circle,
      border: isActive 
          ? Border.all(color: AppColors.pink, width: 1)
          : Border.all(color: AppColors.pinkLight, width: 1),
    );
  }

  // add to Planner Icon
  static BoxDecoration getPlanDecoration({required bool isActive}) {
    return BoxDecoration(
      color: AppColors.greyLight,
      shape: BoxShape.circle,
      border: isActive 
          ? Border.all(color: AppColors.grey, width: 1)
          : Border.all(color: AppColors.greyLight, width: 1),
    );
  }
}