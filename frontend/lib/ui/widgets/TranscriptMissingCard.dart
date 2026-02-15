import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/theme/colors.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';

class TranscriptMissingCard extends StatelessWidget {
  final VoidCallback onUploadPressed;
  final VoidCallback onSkipPressed;

  const TranscriptMissingCard({
    super.key,
    required this.onUploadPressed,
    required this.onSkipPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.standardWhitebackground, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(100, 10, 10, 10),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // icon
          Container(
            width: 80, 
            height: 80,
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.only(bottom: 24), 
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              'assets/icons/missingTranscript.svg',
              colorFilter: ColorFilter.mode(AppColors.grey, BlendMode.srcIn),
              height: 34,
              width: 34,
            ),
          ),
          
          // Texts part
          Text(
            "No Transcript Uploaded",
            style: textTheme.titleLarge?.copyWith(color: AppColors.textMain, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),

          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              "Upload your transcript to get a personalized academic overview with GPA calculations and course progress tracking.",
              style: textTheme.titleSmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),

          // upload button
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 32),
            child: AdaptiveButton(
              onPressed: onUploadPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  // upload Icon
                  SvgPicture.asset(
                    'assets/icons/upload.svg',
                    colorFilter: ColorFilter.mode(AppColors.standardWhitebackground, BlendMode.srcIn),
                    height: 16,
                    width: 16,
                  ),

                  Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      "Upload Transcript",
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.standardWhitebackground),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // skip button
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 12),
            child: OutlinedButton(
              onPressed: onSkipPressed,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "I don't want to upload / This is my first semester",
                style: textTheme.titleSmall?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // info text
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(top: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text : TextSpan(
                style: textTheme.titleSmall?.copyWith(color: AppColors.textSecondary),
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle, 
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.star,
                        size: 20,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: "You can always upload your transcript later from your profile settings.",
                  ),
                ],
              )
            )
          ),
        ],
      ),
    );
  }
}