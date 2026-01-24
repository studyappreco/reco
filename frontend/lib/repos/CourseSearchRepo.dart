import 'package:flutter/material.dart';
import 'package:frontend/models/Module.dart';
import 'package:frontend/service/MongoService.dart';
import 'package:frontend/ui/SearchPage.dart';

class CourseSearchRepo {
  final MongoService _mongoService = MongoService();
  List<Module> _allModules = [];

  // Load data (only if necessary or forced)
  Future<List<Module>> fetchModules({bool forceRefresh = false}) async {
    if (_allModules.isEmpty || forceRefresh){
      _allModules = await _mongoService.getAllModules();
    }
    return _allModules;
  }

  // Filter & Sort (https://www.geeksforgeeks.org/flutter/flutter-filter-a-list-using-some-condition/)
  List<Module> filterModules({required String query, required Set<String> selectedExamTypes, required RangeValues ectsRange, required RangeValues ratingRange, required SortOption sortOption}){
    var filteredList = _allModules.where((m){
      // Text search
      final matchesText = query.isEmpty || 
                          m.title.toLowerCase().contains(query.toLowerCase()) ||
                          m.moduleNr.toLowerCase().contains(query.toLowerCase());

      // Exam Type
      final matchesExamType = selectedExamTypes.isEmpty || selectedExamTypes.contains(m.examType);
      
      // ECTS
      int moduleCredits = int.tryParse(m.credits) ?? 0;
      final matchesEcts = moduleCredits >= ectsRange.start && moduleCredits <= ectsRange.end;
      
      // Rating
      double moduleRating = m.rating ?? 0.0;
      final matchesRating = moduleRating >= ratingRange.start && moduleRating <= ratingRange.end;

      return matchesText && matchesExamType && matchesEcts && matchesRating;
    }).toList();

    // Sorting Logic (https://stackoverflow.com/questions/53547997/sort-a-list-of-objects-in-flutter-dart-by-property-value)
    switch (sortOption) {
      case SortOption.bestMatch:
        filteredList.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage)); 
        break;
      case SortOption.ratingHigh:
        filteredList.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case SortOption.ratingCount:
        filteredList.sort((a, b) => b.ratingCount.compareTo(a.ratingCount));
        break;
      case SortOption.ectsHigh:
        filteredList.sort((a, b) => int.parse(b.credits).compareTo(int.parse(a.credits)));
        break;
      case SortOption.ectsLow:
        filteredList.sort((a, b) => int.parse(a.credits).compareTo(int.parse(b.credits)));
        break;
    }

    return filteredList;
  }
}