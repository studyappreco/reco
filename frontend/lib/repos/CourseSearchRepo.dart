import 'package:flutter/material.dart';
import 'package:frontend/models/Module.dart';
import 'package:frontend/service/MongoService.dart';
import 'package:frontend/ui/SearchPage.dart';
import 'package:frontend/utils/logger.dart';

class CourseSearchRepo {
  final MongoService _mongoService = MongoService();
  static List<Module> _allModules = [];

  Future<Module?> getModuleByNumber(String moduleNr, String userID) async {
    // First check all modules to see if we already have the module in our list => saves database calls
    if(_allModules.isNotEmpty){
      try {
        final moduleFromCache = _allModules.firstWhere((m) => m.moduleNr == moduleNr);
        Log.info("Module $moduleNr found in cache");
        return moduleFromCache;
      } catch (e) {
        Log.info("Module $moduleNr not in cache. Fetching from DB...");
      }
    }
    
    // database search for the module
    try {
      // getting the module and the list of planned and favorite modules
      final jsonmodule = await _mongoService.getModuleByNumber(moduleNr);
      final favorites = await _mongoService.getFavoriteModuleNrs(userID);
      final planned = await _mongoService.getPlannedModuleNrs(userID);

      if(jsonmodule == null) {
        Log.warning("Module $moduleNr not found in Database");
        return null;
      }

      return Module.fromMap(
        jsonmodule, 
        userFavorites: favorites, 
        userPlanned: planned
      );

    } catch (e, s) {
      Log.error("Repository Error fetching module $moduleNr", e, s);
      rethrow; 
    }
  }

  // Load data (only if necessary or forced)
  Future<List<Module>> fetchModules({bool forceRefresh = false, required String userID}) async {
    if (_allModules.isNotEmpty && !forceRefresh) {
      return _allModules;
    }

    Log.info("Loading modules from DB");

    try {

      // we're getting all the modules and the list of planned and favorite modules
      final List<Map<String, dynamic>> jsonmodules = await _mongoService.getAllModules();
      final List<String> favorites = await _mongoService.getFavoriteModuleNrs(userID);
      final List<String> planned = await _mongoService.getPlannedModuleNrs(userID);

      // now creating the module objects with the information
      _allModules = jsonmodules.map((json) {
        return Module.fromMap(
          json,
          userFavorites: favorites,
          userPlanned: planned
        );
      }).toList();

      Log.info("Modules loaded: ${_allModules.length}");

    } catch (e, s) {
      Log.error("Error inside fetchModules", e, s);
      rethrow; 
    }

    return _allModules;
  }

  // Filter & Sort (https://www.geeksforgeeks.org/flutter/flutter-filter-a-list-using-some-condition/)
  List<Module> filterModules({
    required String query, 
    required Set<String> selectedExamTypes, 
    required RangeValues ectsRange, 
    required RangeValues ratingRange, 
    required SortOption sortOption,
    required Set<String> selectedTags,
    required Set<String> selectedTerms,
    required Set<String> selectedLanguages,
  }){
    var filteredList = _allModules.where((m){
      // Text search
      final matchesText = query.isEmpty || 
                          m.title.toLowerCase().contains(query.toLowerCase()) ||
                          m.moduleNr.toLowerCase().contains(query.toLowerCase());

      // Exam Type
      bool matchesExamType = true;
      if(selectedExamTypes.isNotEmpty){
        matchesExamType = false; 
        final dbExamType = m.examType.toLowerCase();
        // check if one of the selected exam types is included
        // if yes then matchesExamType = true and break 
        // I tried to do it in such a way that it remains stable and functional for further changes in the database
        for(var selected in selectedExamTypes){
          if(selected == "Written Exam"){
            if(dbExamType.contains("written") || dbExamType.contains("schriftlich") || dbExamType.contains("schriftlich")) matchesExamType = true;
          } 
          else if (selected == "Oral Exam") {
            if(dbExamType.contains("oral") || dbExamType.contains("mündlich")) matchesExamType = true;
          }
          else if (selected == "Portfolio Exam") {
            if(dbExamType.contains("portfolio")) matchesExamType = true;
          }
          else if (selected == "Homework") {
            if(dbExamType.contains("Homework") || dbExamType.contains("hausarbeit")) matchesExamType = true;
          }
          else if (selected == "Presentation") {
            if(dbExamType.contains("presentation") || dbExamType.contains("referat")) matchesExamType = true;
          }
          else if (selected == "Internship") {
            if(dbExamType.contains("internship") || dbExamType.contains("praktikum")) matchesExamType = true;
          }
          else if (selected == "No Exam") {
            if(dbExamType.contains("no exam") || dbExamType.contains("keine prüfung")) matchesExamType = true;
          }
          if (matchesExamType) break;
        }
      }
      
      // ECTS
      int moduleCredits = int.tryParse(m.credits) ?? 0;
      final matchesEcts = moduleCredits >= ectsRange.start && moduleCredits <= ectsRange.end;
      
      // Rating
      double moduleRating = m.rating ?? 0.0;
      final matchesRating = moduleRating >= ratingRange.start && moduleRating <= ratingRange.end;

      // Tags
      final matchesTags = selectedTags.isEmpty || selectedTags.every((selectedTag) => m.tags.any((moduleTag) => moduleTag.label == selectedTag));

      // Term
      bool matchesTerm = true;
      if(selectedTerms.isNotEmpty){
        final termLower = m.term.toLowerCase(); 
        bool wantsWinter = selectedTerms.contains("Winter Term");
        bool wantsSummer = selectedTerms.contains("Summer Term");

        if(wantsWinter && wantsSummer){
          matchesTerm = termLower.contains("wise") && termLower.contains("sose");
        } else if (wantsWinter) {
          matchesTerm = termLower.contains("wise");
        } else if (wantsSummer) {
          matchesTerm = termLower.contains("sose");
        }
      }

      // Language
      bool matchesLanguage = true;
      if(selectedLanguages.isNotEmpty){
        final langLower = m.language.toLowerCase(); 
        bool isGerman = langLower.contains("deu") || langLower.contains("ger");
        bool isEnglish = langLower.contains("eng");

        bool wantsGerman = selectedLanguages.contains("German");
        bool wantsEnglish = selectedLanguages.contains("English");

        if(wantsGerman && wantsEnglish){
           matchesLanguage = isGerman || isEnglish; 
        } else if (wantsGerman) {
           matchesLanguage = isGerman;
        } else if (wantsEnglish) {
           matchesLanguage = isEnglish;
        }
      }

      return matchesText && matchesExamType && matchesEcts && matchesRating && matchesTags && matchesTerm && matchesLanguage;
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
