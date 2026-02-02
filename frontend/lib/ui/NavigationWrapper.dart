import 'package:flutter/material.dart';
import 'widgets/NavigationBar.dart';
import 'package:go_router/go_router.dart';
// import 'SearchPage.dart';
// import 'PlannerPage.dart';
// import 'FavoritesPage.dart';
// import 'FeedbackPage.dart';

class NavigationWrapper extends StatelessWidget {
  final Widget child;

  const NavigationWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    final List<String> pages = [
      '/home',
      '/search',
      '/planner',
      '/favourites',
      '/feedback',
      '/demo',
    ];

    void onTabSelected(int index) {
      context.go(pages[index]);
    }

    int index = switch (location) {
      '/home' => 0,
      '/search' => 1,
      '/planner' => 2,
      '/favourites' => 3,
      '/feedback' => 4,
      '/demo' => 5,
      _ => 0,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: NavBar(
        currentIndex: index,
        onDestinationSelected: onTabSelected,
      ),
    );
  }
}
