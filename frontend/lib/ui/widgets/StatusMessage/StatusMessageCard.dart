import 'package:flutter/material.dart';
import 'package:frontend/theme/colors.dart';
import 'StatusMessageCard_style.dart';

class StatusMessageCard extends StatelessWidget {
  final bool isError;
  final String title;
  final String message;
  final VoidCallback? onClose;

  const StatusMessageCard({
    super.key,
    required this.isError,
    required this.title,
    required this.message,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final iconData = isError ? Icons.priority_high : Icons.check;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: StatusMessageStyles.getCardDecoration(isError),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          
          Container(
            margin: EdgeInsets.only(right: 18), 
            padding: EdgeInsets.all(4),
            decoration: StatusMessageStyles.getIconDecoration(isError),
            child: Icon(
              iconData,
              color: Colors.white,
              size: 16,
            ),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(title, style: textTheme.titleMedium?.copyWith(color: AppColors.textMain)),
                ),
                // Text
                Text(message, style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),

          // Close Button
          if(onClose != null)
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: GestureDetector(
                onTap: onClose,
                child: Icon(Icons.close, color: AppColors.grey, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}