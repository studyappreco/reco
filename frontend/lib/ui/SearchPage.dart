import 'package:flutter/material.dart';
import 'package:frontend/theme/colors.dart'; 
import 'package:frontend/ui/widgets/AdaptiveSearchfield.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';
import 'package:frontend/ui/widgets/CourseCard/CourseCard.dart';
import 'package:frontend/ui/widgets/StatusMessage/StatusMessage.dart';
import 'package:frontend/models/Module.dart';
import 'package:frontend/repos/CourseSearchRepo.dart';


// Enum for the possible sorting options
enum SortOption { bestMatch, ratingHigh, ratingCount, ectsHigh, ectsLow }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final CourseSearchRepo _repository = CourseSearchRepo();
  List<Module> _allModules = [];      
  List<Module> _filteredModules = []; 
  bool _isLoading = true;

  String _searchQuery = "";
  SortOption _selectedSort = SortOption.bestMatch; 
  Set<String> _selectedExamTypes = {}; 
  RangeValues _ectsRange = RangeValues(0, 15); 
  RangeValues _ratingRange = RangeValues(0, 5);

  final List<String> _allExamTypes = ["Written Exam", "Oral Exam", "Portfolio Exam", "Term Paper", "Presentation", "Internship", "No Exam"];

  @override
  void initState(){
    super.initState();
    _loadData(false);
  }

  // Load data (also for refresh)
  Future<void> _loadData(bool force) async {
    try {
      List<Module> modules = await _repository.fetchModules(forceRefresh: force);
      
      if(mounted){
        setState(() {
          _allModules = modules;
          _filteredModules = modules; 
          _isLoading = false;
          _applyFilters(); 
        });
      }
    } catch (e) {
      print("ERROR: $e");
      
      if(mounted){
        StatusMessage.show(
            context: context,
            alignment: SnackAlignment.CENTER,
            title: "Oops! Something went wrong!",
            message: "$e",
            isError: true,
            duration: Duration(seconds: 8),
        );
        setState(() {
          _allModules = [];
          _filteredModules = [];
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters(){
    setState(() {
      _filteredModules = _repository.filterModules(
        query: _searchQuery,
        selectedExamTypes: _selectedExamTypes,
        ectsRange: _ectsRange,
        ratingRange: _ratingRange,
        sortOption: _selectedSort,
      );
    });
  }

  // Filter UI design
  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8, minChildSize: 0.5, maxChildSize: 0.95, expand: false,
        builder: (context, scrollController){
          return StatefulBuilder( 
            builder: (context, setModalState){
              return Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Filter & Sort", 
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                          ),
                          // Reset Button
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                _selectedSort = SortOption.bestMatch;
                                _selectedExamTypes.clear();
                                _ectsRange = RangeValues(0, 15); 
                                _ratingRange = RangeValues(0, 5); 
                              });
                              _applyFilters();
                            },
                            child: Text(
                              "Reset", 
                              style: TextStyle(color: AppColors.primaryBlue)
                            ),
                          )
                        ],
                      ),
                    ),
                    Divider(),
                    
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          // Show Sort Options
                          Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 8.0),
                            child: Text(
                              "Sort by", 
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 24.0),
                            child: Wrap(
                              spacing: 8,
                              children: [
                                ChoiceChip(
                                  label: Text("Best Match"),
                                  selected: _selectedSort == SortOption.bestMatch,
                                  onSelected: (bool selected) {
                                    if(selected) { setModalState(() => _selectedSort = SortOption.bestMatch); _applyFilters(); }
                                  },
                                ),
                                ChoiceChip(
                                  label: Text("Highest Rated"),
                                  selected: _selectedSort == SortOption.ratingHigh,
                                  onSelected: (bool selected) {
                                    if(selected) { setModalState(() => _selectedSort = SortOption.ratingHigh); _applyFilters(); }
                                  },
                                ),
                                ChoiceChip(
                                  label: Text("Most Rated"),
                                  selected: _selectedSort == SortOption.ratingCount,
                                  onSelected: (bool selected) {
                                    if(selected) { setModalState(() => _selectedSort = SortOption.ratingCount); _applyFilters(); }
                                  },
                                ),
                                ChoiceChip(
                                  label: Text("ECTS (High to Low)"),
                                  selected: _selectedSort == SortOption.ectsHigh,
                                  onSelected: (bool selected) {
                                    if(selected) { setModalState(() => _selectedSort = SortOption.ectsHigh); _applyFilters(); }
                                  },
                                ),
                                ChoiceChip(
                                  label: Text("ECTS (Low to High)"),
                                  selected: _selectedSort == SortOption.ectsLow,
                                  onSelected: (bool selected) {
                                    if(selected) { setModalState(() => _selectedSort = SortOption.ectsLow); _applyFilters(); }
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Show the possible exam type selection
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "Examination Type", 
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 24.0),
                            child: Wrap(
                              spacing: 8,
                              children: _allExamTypes.map((type) {
                                final isSelected = _selectedExamTypes.contains(type);
                                return FilterChip(
                                  label: Text(type),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setModalState(() {
                                      if (selected) {
                                        _selectedExamTypes.add(type);
                                      } else {
                                        _selectedExamTypes.remove(type);
                                      }
                                    });
                                    _applyFilters();
                                  },
                                );
                              }).toList(),
                            ),
                          ),

                          // ECTS Slider
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "ECTS Points", 
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)
                                ),
                                Text(
                                  "${_ectsRange.start.round()} - ${_ectsRange.end.round()}", 
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 24.0),
                            child: RangeSlider(
                              values: _ectsRange, min: 0, max: 15, divisions: 15, 
                              activeColor: AppColors.primaryBlue,
                              labels: RangeLabels(_ectsRange.start.round().toString(), _ectsRange.end.round().toString()),
                              onChanged: (values) { setModalState(() => _ectsRange = values); _applyFilters(); },
                            ),
                          ),

                          // Rating Slider
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Rating (Stars)", 
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.star, size: 16, color: AppColors.star),
                                    Padding(
                                      padding: EdgeInsets.only(left: 4.0),
                                      child: Text(
                                        "${_ratingRange.start.toStringAsFixed(1)} - ${_ratingRange.end.toStringAsFixed(1)}", 
                                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          RangeSlider(
                            values: _ratingRange, min: 0, max: 5, divisions: 10, 
                            activeColor: AppColors.star, 
                            labels: RangeLabels(_ratingRange.start.toStringAsFixed(1), _ratingRange.end.toStringAsFixed(1)),
                            onChanged: (values) { setModalState(() => _ratingRange = values); _applyFilters(); },
                          ),
                        ],
                      ),
                    ),

                    // Apply Button
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: AdaptiveButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Show Results"),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Discover Modules")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: AdaptiveSearchField(
                onChanged: (text) {
                  _searchQuery = text;
                  _applyFilters();
                },
                showFilter: true,
                onFilterTap: _openFilterSheet,
              ),
            ),
            
            if (!_isLoading && _selectedSort == SortOption.bestMatch && _filteredModules.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text(
                  "Recommended for You",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ),

            Expanded(
              child: _isLoading 
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator( 
                    onRefresh: () => _loadData(true), 
                    color: AppColors.primaryBlue,
                    
                    child: _filteredModules.isEmpty
                      ? ListView(
                          // https://api.flutter.dev/flutter/material/RefreshIndicator-class.html
                          physics: const AlwaysScrollableScrollPhysics(), 
                          children: [
                            Center(
                              child: Text(
                                "No modules found.\nPull down to refresh.", 
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textSecondary)
                              )
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(), 
                          itemCount: _filteredModules.length, // TODO Do we want to display all of them or a specific number? 
                          itemBuilder: (context, index) {
                            final module = _filteredModules[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.0), 
                              child: CourseCard(
                                title: module.title,
                                moduleNr: module.moduleNr,
                                credits: module.credits,
                                category: module.examType, 
                                matchBasis: module.matchBasis,
                                matchPercentage: module.matchPercentage,
                                rating: module.rating,
                                tags: module.tags,
                                isFavorite: module.isFavorite,
                                isPlanned: module.isPlanned,
                                onCardTap: () {},
                                onFavoriteTap: () => setState(() => module.isFavorite = !module.isFavorite),
                                onPlanTap: () => setState(() => module.isPlanned = !module.isPlanned),
                              ),
                            );
                          },
                        ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}