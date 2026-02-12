import 'package:flutter/material.dart';
import 'package:frontend/models/Module.dart';
import 'package:frontend/repos/CourseSearchRepo.dart';
import 'package:frontend/repos/UserRepository.dart';
import 'package:frontend/theme/colors.dart';
import 'package:frontend/ui/utils/auth.dart';
import 'package:frontend/ui/widgets/AdaptiveSearchfield.dart';
import 'package:frontend/ui/widgets/StatusMessage/StatusMessage.dart';
import 'package:frontend/ui/widgets/Chip.dart';
import 'package:frontend/utils/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final String userID = context.read<ClientSession>().getUserID() ?? "";

    return ChangeNotifierProvider<FavoritesPageViewmodel>(
      create: (_) => FavoritesPageViewmodel(userID),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: AdaptiveSearchField(
            onChanged: (str) {},
          ),
        ),
        backgroundColor: colorScheme.surface,

        body: Consumer<FavoritesPageViewmodel>(
          builder: (context, vm, child) {
            if(vm.isLoading){
              return Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // headline
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.standardWhitebackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "My Favorites",
                          style: textTheme.titleSmall?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ),

                    // Border line like in Figma design
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.standardWhitebackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          // "Add Module" Button
                          Padding(
                            padding: EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => context.go('/search'),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: colorScheme.surfaceContainerHighest,
                                        width: 3
                                      ),
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.textMain,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(13)
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: Text(
                                      "+ Add Module",
                                      style: textTheme.titleMedium?.copyWith(color: AppColors.textMain),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),

                          // List of favorites
                          if(vm.favoriteModules.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("No favorites yet", style: textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)),
                                ],
                              ),
                            )
                          else
                            // https://api.flutter.dev/flutter/widgets/ListView/ListView.separated.html
                            ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: vm.favoriteModules.length,
                              separatorBuilder: (context, index) => SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final module = vm.favoriteModules[index];
                                return _AnimatedCardItem(
                                  key: ValueKey(module.moduleNr),
                                  module: module,
                                  onRemove: () => vm.removeFavorite(context, module),
                                  onTap: () => context.go('/search/course-details', extra: module.moduleNr),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedCardItem extends StatefulWidget {
  final Module module;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _AnimatedCardItem({
    super.key, 
    required this.module,
    required this.onRemove,
    required this.onTap,
  });

  @override
  State<_AnimatedCardItem> createState() => _AnimatedCardItemState();
}

class _AnimatedCardItemState extends State<_AnimatedCardItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
      value: 1.0, 
    );
    
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRemove() async {
    await _controller.reverse().orCancel;
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: FadeTransition(
        opacity: _animation,
        child: _FavoriteModuleCard(
          module: widget.module,
          onTap: widget.onTap,
          onFavoriteTap: _handleRemove,
        ),
      ),
    );
  }
}

class _FavoriteModuleCard extends StatelessWidget {
  final Module module;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const _FavoriteModuleCard({
    required this.module,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // left section (module title etc.)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          module.title,
                          style: textTheme.titleMedium?.copyWith(color: AppColors.textMain)
                        ),
                      ),

                      // nt, ects, rating, match
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [

                          Text(
                            "${module.moduleNr} • ${module.credits} ECTS",
                            style: textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)
                          ),
                          
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: AppColors.star, size: 25),
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  (module.rating != null && module.rating! > 0) ? module.rating.toString() : '-',
                                  style: textTheme.titleMedium?.copyWith(color: AppColors.textMain),
                                ),
                              ),
                            ],
                          ),

                          ChipWidget(label: "${module.matchPercentage}% match", color: Colors.green),
                        ],
                      )
                    ],
                  ),
                ),

                // Heart button
                Padding(
                  padding: EdgeInsets.only(left: 8.0, top: 4.0),
                  child: InkWell(
                    onTap: onFavoriteTap,
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.pinkLight,
                        border: Border.all(
                          color: AppColors.pink,
                          width: 2,
                        ),
                      ),
                      child: Icon(Icons.favorite, color: AppColors.pink, size: 20),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FavoritesPageViewmodel extends ChangeNotifier {
  final String userID;
  final CourseSearchRepo _courseRepo = CourseSearchRepo();
  final UserRepository _userRepo = UserRepository();

  List<Module> favoriteModules = [];
  bool isLoading = true;

  FavoritesPageViewmodel(this.userID) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    isLoading = true;
    notifyListeners();

    if(userID.isEmpty){
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final favoriteIDs = await _userRepo.getFavoriteModuleNrs(userID);
      favoriteModules = await _courseRepo.getModulesByModuleNrs(favoriteIDs, userID);
      Log.info("Loaded ${favoriteModules.length} favorites");
    } catch (e, s) {
      Log.error("Error loading favorites", e, s);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFavorite(BuildContext context, Module module) async {
    final int removedIndex = favoriteModules.indexOf(module);
    
    // UI update
    favoriteModules.remove(module);
    module.isFavorite = false;
    notifyListeners();

    // DB Update
    try {
      await _userRepo.toggleFavoriteModule(userID, module.moduleNr);
    } catch (e, s) {
      Log.error("Error removing favorite", e, s);
      
      // if removal did not work, add the module again
      module.isFavorite = true;
      if(removedIndex != -1){
        favoriteModules.insert(removedIndex, module);
      } else {
        favoriteModules.add(module);
      }
      notifyListeners();

      if(!context.mounted) return;
      StatusMessage.show(
        context: context,
        alignment: SnackAlignment.CENTER,
        title: "Oops! Something went wrong!",
        message: "Could not remove favorite. Please try again.",
        isError: true,
        duration: Duration(seconds: 3),
      );
    }
  }
}