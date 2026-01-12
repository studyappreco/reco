import 'package:flutter/material.dart';
import 'package:frontend/theme/colors.dart';


class StatusMessageStyles {

  static BoxDecoration getCardDecoration(bool isError){
    final backgroundColor = isError ? AppColors.redLight : AppColors.greenLight;

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
    );
  }

  static BoxDecoration getIconDecoration(bool isError){
    return BoxDecoration(
      color: isError ? AppColors.red : AppColors.green,
      shape: BoxShape.circle,
    );
  }

  
}
