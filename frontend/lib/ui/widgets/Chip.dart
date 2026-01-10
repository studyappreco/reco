import 'package:flutter/material.dart';

class ChipType {
  final String label;
  final Color color;

  ChipType(this.label, this.color);
}

class ChipWidget extends StatelessWidget {
  final String label;
  final Color color;

  const ChipWidget({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: color.withAlpha(50),
      ),
      child: Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: color)
      ),
    );
  }
}