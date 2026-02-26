import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/Chip.dart';
import 'package:frontend/ui/widgets/CourseCard/CourseCard.dart';

// shows how the course card can be used as an example
class Course{
  final String title;
  final String moduleNr;
  final String credits;
  final List<ChipType> tags;
  final double? rating;
  bool isFavorite;
  bool isPlanned;
  bool isRecommended;

  Course({
    required this.title,
    required this.moduleNr,
    required this.credits,
    required this.tags,
    this.rating,
    this.isFavorite = false,
    this.isPlanned = false,
    this.isRecommended = false,
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
      tags: [
        ChipType("Data Science", Colors.blueAccent),
        ChipType("C++",  Colors.purpleAccent),
        ChipType("Algo", Colors.blueAccent),
        ChipType("Math",  Colors.purpleAccent),
        ChipType("Logic", Colors.blueAccent),
      ],
      rating: 4.8,
      isFavorite: false,
      isPlanned: false,
      isRecommended: false,
    ),
    Course(
      title: "Deep Learning",
      moduleNr: "AI 301",
      credits: "6",
      tags: [
        ChipType("Neutral Networks", Colors.blueAccent),
        ChipType("Python",  Colors.purpleAccent),
        ChipType("PyTorch", Colors.blueAccent),
        ChipType("TensorFlow",  Colors.purpleAccent),
      ],
      rating: null,
      isFavorite: true,
      isPlanned: true,
      isRecommended: true,
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
              isFavorite: course.isFavorite,
              isPlanned: course.isPlanned,
              isRecommended: course.isRecommended,
              onCardTap: () => debugPrint(course.moduleNr),
              onFavoriteTap: () => clickFavorite(index),
              onPlanTap: () => clickPlan(index),
            ),
          );
        },
      ),
    );
  }
}
