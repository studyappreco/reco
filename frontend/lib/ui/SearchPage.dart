import 'package:flutter/material.dart';
import 'package:frontend/theme/colors.dart'; 
import 'package:frontend/ui/widgets/AdaptiveSearchfield.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';
import 'package:frontend/ui/widgets/CourseCard/CourseCard.dart';
import 'package:frontend/ui/widgets/StatusMessage/StatusMessage.dart';
import 'package:frontend/models/Module.dart';
import 'package:frontend/repos/CourseSearchRepo.dart';
import 'package:go_router/go_router.dart';


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

  Set<String> _selectedTags = {}; 
  String _tagSearchQuery = "";    
  List<String> _allTags = []; // TODO change when we have the tags for the interest selection page, We currently create the list based on the tags received from the DB with the modul information

  Set<String> _selectedTerms = {};
  final List<String> _availableTerms = ["Winter Term", "Summer Term"];

  Set<String> _selectedLanguages = {};
  final List<String> _availableLanguages = ["German", "English"];

  final List<String> _allExamTypes = ["Written Exam", "Oral Exam", "Portfolio Exam", "Homework", "Presentation", "Internship", "No Exam"];

  @override
  void initState(){
    super.initState();
    _loadData(false);
  }

  // Load data (also for refresh)
  Future<void> _loadData(bool force) async {
    try {
      List<Module> modules = await _repository.fetchModules(forceRefresh: force);
      
      // Extract tags from the data
      Set<String> extractedTags = {};
      for(var module in modules){
        for(var tagObj in module.tags){
          if(tagObj.label.isNotEmpty){
            extractedTags.add(tagObj.label);
          }
        }
      }
      // sort the tags
      List<String> sortedTags = extractedTags.toList()..sort();

      if(mounted){
        setState(() {
          _allModules = modules;
          _allTags = sortedTags; 
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
        selectedTags: _selectedTags, 
        selectedTerms: _selectedTerms, 
        selectedLanguages: _selectedLanguages,
      );
    });
  }

  // Filter UI design
  void _openFilterSheet() {
    _tagSearchQuery = "";

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
              
              // creates the list of tags to be displayed
              final visibleTags = _allTags.where((tag) {
                final matchesSearch = tag.toLowerCase().contains(_tagSearchQuery.toLowerCase()); // display the unselected ones
                final isSelected = _selectedTags.contains(tag); // display the selected
                return matchesSearch || isSelected;
              }).toList();

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
                                _selectedTags.clear(); 
                                _selectedTerms.clear();
                                _selectedLanguages.clear();
                                _tagSearchQuery = "";
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
                              runSpacing: 8, 
                              children: [
                                ChoiceChip(
                                  label: Text("Best Match"),
                                  selected: _selectedSort == SortOption.bestMatch,
                                  selectedColor: AppColors.primaryBlueLight,
                                  checkmarkColor: AppColors.primaryBlue,
                                  onSelected: (bool selected) {
                                    if(selected) { setModalState(() => _selectedSort = SortOption.bestMatch); _applyFilters(); }
                                  },
                                ),
                                ChoiceChip(
                                  label: Text("Highest Rated"),
                                  selected: _selectedSort == SortOption.ratingHigh,
                                  selectedColor: AppColors.primaryBlueLight,
                                  checkmarkColor: AppColors.primaryBlue,
                                  onSelected: (bool selected) {
                                    if(selected) { setModalState(() => _selectedSort = SortOption.ratingHigh); _applyFilters(); }
                                  },
                                ),
                                ChoiceChip(
                                  label: Text("Most Rated"),
                                  selected: _selectedSort == SortOption.ratingCount,
                                  selectedColor: AppColors.primaryBlueLight,
                                  checkmarkColor: AppColors.primaryBlue,
                                  onSelected: (bool selected) {
                                    if(selected) { setModalState(() => _selectedSort = SortOption.ratingCount); _applyFilters(); }
                                  },
                                ),
                                ChoiceChip(
                                  label: Text("ECTS (High to Low)"),
                                  selected: _selectedSort == SortOption.ectsHigh,
                                  selectedColor: AppColors.primaryBlueLight,
                                  checkmarkColor: AppColors.primaryBlue,
                                  onSelected: (bool selected) {
                                    if(selected) { setModalState(() => _selectedSort = SortOption.ectsHigh); _applyFilters(); }
                                  },
                                ),
                                ChoiceChip(
                                  label: Text("ECTS (Low to High)"),
                                  selected: _selectedSort == SortOption.ectsLow,
                                  selectedColor: AppColors.primaryBlueLight,
                                  checkmarkColor: AppColors.primaryBlue,
                                  onSelected: (bool selected) {
                                    if(selected) { setModalState(() => _selectedSort = SortOption.ectsLow); _applyFilters(); }
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Term Filter
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text("Term", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 24.0),
                            child: Wrap(
                              spacing: 8,
                              children: _availableTerms.map((term) {
                                final isSelected = _selectedTerms.contains(term);
                                return FilterChip(
                                  label: Text(term),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryBlueLight,
                                  checkmarkColor: AppColors.primaryBlue,
                                  onSelected: (selected) {
                                    setModalState(() {
                                      selected ? _selectedTerms.add(term) : _selectedTerms.remove(term);
                                    });
                                    _applyFilters();
                                  },
                                );
                              }).toList(),
                            ),
                          ),

                          // Languages Filter
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text("Language", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 24.0),
                            child: Wrap(
                              spacing: 8,
                              children: _availableLanguages.map((lang) {
                                final isSelected = _selectedLanguages.contains(lang);
                                return FilterChip(
                                  label: Text(lang),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryBlueLight,
                                  checkmarkColor: AppColors.primaryBlue,
                                  onSelected: (selected) {
                                    setModalState(() {
                                      selected ? _selectedLanguages.add(lang) : _selectedLanguages.remove(lang);
                                    });
                                    _applyFilters();
                                  },
                                );
                              }).toList(),
                            ),
                          ),

                          // Tags Section
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text("Tags", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          ),
                          
                          // Suchfeld für Tags
                          Padding(
                            padding: EdgeInsets.only(bottom: 12.0), 
                            child: AdaptiveSearchField(
                              hintText: "Search tags...", 
                              showFilter: false, 
                              onChanged: (val) {
                                setModalState(() {
                                  _tagSearchQuery = val;
                                });
                              },
                            ),
                          ),
                          
                          // Tags Liste
                          Padding(
                            padding: EdgeInsets.only(bottom: 24.0),
                            child: SizedBox(
                              height: 45, 
                              child: visibleTags.isEmpty 
                                ? Center(child: Text("No tags found", style: TextStyle(color: Colors.grey)))
                                : ListView.separated(
                                    scrollDirection: Axis.horizontal, 
                                    itemCount: visibleTags.length,
                                    separatorBuilder: (context, index) => SizedBox(width: 8),
                                    itemBuilder: (context, index) {
                                      final tag = visibleTags[index];
                                      final isSelected = _selectedTags.contains(tag);
                                      return FilterChip(
                                        label: Text(tag),
                                        selected: isSelected,
                                        selectedColor: AppColors.primaryBlueLight,
                                        checkmarkColor: AppColors.primaryBlue,
                                        onSelected: (selected) {
                                          setModalState(() {
                                            if (selected) {
                                              _selectedTags.add(tag);
                                            } else {
                                              _selectedTags.remove(tag);
                                            }
                                          });
                                        },
                                      );
                                    },
                                  ),
                            ),
                          ),

                          // Exam Type
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text("Examination Type", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
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
                                  selectedColor: AppColors.primaryBlueLight,
                                  checkmarkColor: AppColors.primaryBlue,
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
                          onPressed: () {
                            _applyFilters();
                            Navigator.pop(context);
                          },
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
                hintText: "Search modules", 
                onChanged: (text) {
                  _searchQuery = text;
                  _applyFilters();
                },
                showFilter: true,
                onFilterTap: _openFilterSheet,
              ),
            ),
            
            // If tags have been selected, they will be displayed
            if (_selectedTags.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0, left: 4.0),
                child: Text(
                  "Selected Tags:",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ),
              
              Container(
                height: 40,
                margin: EdgeInsets.only(bottom: 12),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedTags.length,
                  separatorBuilder: (_,_) => SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final tag = _selectedTags.elementAt(index);
                    return Chip(
                      label: Text(tag, style: Theme.of(context).textTheme.labelMedium),
                      backgroundColor: AppColors.primaryBlueLight,
                      deleteIcon: Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _selectedTags.remove(tag);
                          _applyFilters();
                        });
                      },
                    );
                  },
                ),
              ),
            ],

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
                                category: "Still Missing", 
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