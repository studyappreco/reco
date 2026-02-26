
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' show Session;
import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/PasswordField.dart';
import 'package:frontend/ui/widgets/ValidatedtextField.dart';
import 'package:frontend/ui/utils/auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.standardWhitebackground,
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Image.asset(
              "assets/images/reco_logo_transparent_bg.png",
              fit: BoxFit.contain,
            ),
            CircularProgressIndicator()
          ]
        )
      ),
    );
  }
}
