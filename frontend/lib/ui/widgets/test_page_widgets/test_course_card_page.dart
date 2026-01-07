import 'package:flutter/material.dart';
import '../course_card/course_card.dart'; 

// shows how the course card can be used as an example
class Course{
  final String title;
  final String moduleNr;
  final String credits;
  final List<String> tags;
  final double? rating;
  final int matchPercentage;
  bool isFavorite;
  bool isPlanned;

  Course({
    required this.title,
    required this.moduleNr,
    required this.credits,
    required this.tags,
    this.rating,
    required this.matchPercentage,
    this.isFavorite = false,
    this.isPlanned = false,
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
      tags: ["Data Science", "C++", "Algo", "Math", "Logic"],
      rating: 4.8,
      matchPercentage: 95,
      isFavorite: false,
      isPlanned: false,
    ),
    Course(
      title: "Deep Learning",
      moduleNr: "AI 301",
      credits: "6",
      tags: ["Neural Networks", "Python", "PyTorch", "TensorFlow"],
      rating: null,
      matchPercentage: 45,
      isFavorite: true,
      isPlanned: true,
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
              tags: course.tags,
              rating: course.rating,
              matchPercentage: course.matchPercentage,
              isFavorite: course.isFavorite,
              isPlanned: course.isPlanned, 
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