import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../AdaptiveSearchfield.dart';

// This is an example of how to use AdaptiveSearchField, based on our Search page in Figma

class SearchScreen extends StatefulWidget{
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>{
  // data source
  final List<String> allModules = [
    "Algorithm (CS 201)",
    "Data Structure (CS 102)",
    "Python Programming (CS 105)",
    "X Seminar (CS 350)",
    "Deep Learning (AI 301)",
    "Machine Learning",
    "Web Development",
    "Business Informatics",
    "Cloud Computing",
    "Cyber Security",
    "Software Engineering",
    "Database Systems"
  ];

  // The list that is actually displayed
  List<String> foundModules = [];

  @override
  void initState(){
    super.initState();
    foundModules = allModules; // Start by showing all modules
  }

  // Filter Logic (must be given to AdaptiveSearchField)
  void _runFilter(String keyword){
    setState(() {
      if(keyword.isEmpty){
        foundModules = allModules;
      }
      else{
        foundModules = allModules.where((module) => module.toLowerCase().contains(keyword.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Discover Modules")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            AdaptiveSearchField(
              onChanged: _runFilter,
            ),
            
            Expanded(
              child: ListView.builder(
                itemCount: foundModules.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(foundModules[index]),
                    onTap: () { print("Selected: ${foundModules[index]}");},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}