import 'package:flutter/material.dart';

// main colors
const Color background = Color(0xFFF9FAFB);
const Color white = Color(0xFFFFFFFF);
const Color primaryBlue = Color(0xFF155DFC);
const Color primaryBlueLight = Color(0xFFDBEAFE);

// Navigation
const Color iconInactive = Color(0xFF99A1AF);
const Color iconActive = Color(0xFF155DFC);

// Tags & Akzente
const Color matchGreen = Color(0xFFDCFCE7);
const Color matchGreenText = Color(0xFF166534);
const Color starYellow = Color(0xFFFACC15);
//etc..

// The individual colors for the bars in the main page
const Color barBlue = Color(0xFF3B82F6);
const Color barPurple = Color(0xFFA855F7);
const Color barGreen = Color(0xFF22C55E);
const Color barOrange = Color(0xFFF97316);

// Consider the list for targeted access via index TODO: how do we choose the color choice? Maybe just have lots of colors in the list and then choose index 0 to n for each bar statically => always the same when opening if the order remains the same
const List<Color> progressColors = [
  barBlue,
  barPurple,
  barGreen,
  barOrange,
];