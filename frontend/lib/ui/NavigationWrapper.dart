import 'package:flutter/material.dart';
import 'widgets/NavigationBar.dart';
import 'package:go_router/go_router.dart';

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
      _ => 0,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: pages.contains(location) ? NavBar(
        currentIndex: index,
        onDestinationSelected: onTabSelected,
      ) : null,
    );
  }
}
