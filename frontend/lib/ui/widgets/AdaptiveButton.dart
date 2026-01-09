import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/colors.dart';

class AdaptiveButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const AdaptiveButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if(Platform.isIOS){
      return CupertinoButton.filled(
        onPressed: onPressed,
        child: child,
      );
    }
    else{
      return FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.buttonText,
          disabledBackgroundColor: AppColors.primaryBlueLight,
          disabledForegroundColor: AppColors.buttonText,
        ),
        onPressed: onPressed,
        child: child,
      );
    }
  }
}