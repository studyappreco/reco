import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AdaptiveSearchField extends StatelessWidget{
  final Function(String) onChanged;

  const AdaptiveSearchField({
    super.key,
    required this.onChanged
  });

  @override
  Widget build(BuildContext context){
    if(Platform.isIOS){
      return CupertinoSearchTextField(
        onChanged: onChanged,
        placeholder: 'Search modules',
      );
    }
    else{
      return TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search modules',
          prefixIcon: Icon(Icons.search), 
        ),
      );
    }
  }
}