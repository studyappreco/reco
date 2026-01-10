import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/Chip.dart';
import 'package:frontend/ui/widgets/CourseCard/CourseCard.dart';

// shows how the course card can be used as an example
class Course{
  final String title;
  final String moduleNr;
  final String credits;
  final String category;
  final String? matchBasis;
  final List<ChipType> tags;
  final double? rating;
  final int matchPercentage;
  bool isFavorite;
  bool isPlanned;

  Course({
    required this.title,
    required this.moduleNr,
    required this.credits,
    required this.category,
    required this.tags,
    this.rating,
    required this.matchPercentage,
    this.isFavorite = false,
    this.isPlanned = false,
    this.matchBasis,
  });
}

class TestCourseCardPage extends StatefulWidget{
  const TestCourseCardPage({super.key});

  @override
  State<TestCourseCardPage> createState() => _TestCourseCardPageState();
}

class _TestCourseCardPageState extends State<TestCourseCardPage>{
  final List<Course> courseslist = [
    Course(
      title: "Algorithm and Data Structures",
      moduleNr: "CS 201",
      credits: "6",
      category: "Computer Science",
      tags: [
        ChipType("Data Science", Colors.blueAccent),
        ChipType("C++",  Colors.purpleAccent),
        ChipType("Algo", Colors.blueAccent),
        ChipType("Math",  Colors.purpleAccent),
        ChipType("Logic", Colors.blueAccent),
      ],
      rating: 4.8,
      matchPercentage: 95,
      isFavorite: false,
      isPlanned: false,
      matchBasis: null
    ),
    Course(
      title: "Deep Learning",
      moduleNr: "AI 301",
      credits: "6",
      category: "Computer Science",
      tags: [
        ChipType("Neutral Networks", Colors.blueAccent),
        ChipType("Python",  Colors.purpleAccent),
        ChipType("PyTorch", Colors.blueAccent),
        ChipType("TensorFlow",  Colors.purpleAccent),
      ],
      rating: null,
      matchPercentage: 45,
      isFavorite: true,
      isPlanned: true,
      matchBasis: "interests"
    ),
  ];

  void clickFavorite(int index){
    setState((){
      courseslist[index].isFavorite = !courseslist[index].isFavorite;
    });
  }

  void clickPlan(int index){
    setState(() {
      courseslist[index].isPlanned = !courseslist[index].isPlanned;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Test Course card")),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: courseslist.length,
        itemBuilder: (context, index) {
          final course = courseslist[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 16), 
            child: CourseCard(
              title: course.title,
              moduleNr: course.moduleNr,
              credits: course.credits,
              category: course.category,
              tags: course.tags,
              rating: course.rating,
              matchPercentage: course.matchPercentage,
              isFavorite: course.isFavorite,
              isPlanned: course.isPlanned, 
              matchBasis: course.matchBasis,
              onCardTap: () => print("${course.moduleNr}"),
              onFavoriteTap: () => clickFavorite(index),
              onPlanTap: () => clickPlan(index), 
            ),
          );
        },
      ),
    );
  }
}