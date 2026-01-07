import 'package:flutter/material.dart';
import 'package:frontend/ui/course_intake_method_page.dart';

void main() {
  runApp(const RecoApp());
}

class RecoApp extends StatelessWidget {
  const RecoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reco',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CourseIntakeMethodPage(),
    );
  }
}
