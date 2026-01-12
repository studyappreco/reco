import 'package:flutter/material.dart';
import 'widgets/NavigationBar.dart';

import 'HomePage.dart'; 
// import 'SearchPage.dart';
// import 'PlannerPage.dart';
// import 'FavoritesPage.dart';
// import 'FeedbackPage.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({Key? key}) : super(key: key);

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(), 
    Center(child: Text("The SearchPage will be added here later")),
    Center(child: Text("The PlannerPage will be added here later.")),
    Center(child: Text("The FavoritesPage will be added here later.")),
    Center(child: Text("The feedback page will be added here later.")),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavBar(
        currentIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
      ),
    );
  }
}