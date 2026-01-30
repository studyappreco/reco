import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/theme/colors.dart';

class AdaptiveSearchField extends StatelessWidget{
  final Function(String) onChanged;
  final bool showFilter;
  final VoidCallback? onFilterTap;
  final String hintText;

  const AdaptiveSearchField({
    super.key,
    required this.onChanged,
    this.showFilter = false,
    this.onFilterTap,
    this.hintText = "Search modules",
  });

  @override
  Widget build(BuildContext context){
    final filterIcon = SvgPicture.asset(
      'assets/icons/filter.svg',
      colorFilter: ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
      width: 24,
      height: 24,
    );

    if(Platform.isIOS){
      return Row(
        children: [
          Expanded(
            child: CupertinoSearchTextField(
              onChanged: onChanged,
              placeholder: hintText,
            ),
          ),
          if(showFilter)
            Padding(
              padding: EdgeInsets.only(left: 12, right: 4),
              child: GestureDetector(
                onTap: onFilterTap,
                child: filterIcon,
              ),
            ),
        ],
      );
    }
    else{
      return TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(Icons.search), 
          suffixIcon: showFilter
              ? IconButton(
                  icon: filterIcon,
                  onPressed: onFilterTap,
                )
              : null,
        ),
      );
    }
  }
}