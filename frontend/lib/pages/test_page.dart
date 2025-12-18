import 'package:flutter/material.dart';
import '../constants/colors.dart';

// I have implemented a structural body here that can be used on every page, as it already includes the navigation bar.
// It is only a test for now and can be saved in a separate file later if we want to use it.


// this example shows how to use the body structure
class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  // Variable to save the current tab/window (start is 0 = Home)
  int _selectedIndex = 0;

  // Function that is called when menu buttons are clicked
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    print("Button $index clicked");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BodyStructure( // This is where we use the BodyStructure and give topContent, middleContent and bottomContent
        
        // Enter here what should be displayed at the top
        topContent: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => print("Account"),
            ),
          ],
        ),

        // Enter here what you want to display in the middle
        middleContent: Center(
          child: Text(
            'Aktueller Tab Index: $_selectedIndex',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),

        // Enter here what you want to below (Menü)
        bottomContent: BottomMenu(
          currentIndex: _selectedIndex, 
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

// General structure of the menu
class BottomMenu extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomMenu({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.transparent, // Takes the color from the container
      elevation: 0, // Removes the shadow
      selectedItemColor: iconActive,
      unselectedItemColor: iconInactive,
      currentIndex: currentIndex, // This is where you control what is active.
      onTap: onTap, // Logic for clicks (is handed over from outside)
      
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book_outlined),
          label: 'Planner',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          activeIcon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Feedback',
        ),
      ],
    );
  }
}

// reusable structure for all displays/Windows (whatever you call it)
class BodyStructure extends StatelessWidget {
  // Here we define the placeholders for the content
  final Widget topContent;
  final Widget middleContent;
  final Widget bottomContent;

  final Color topColor = white;
  final Color middleColor = background;
  final Color bottomColor = white;

  const BodyStructure({
    super.key,
    required this.topContent,
    required this.middleContent,
    required this.bottomContent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          
          // Upper part (takes 10% of the display)
          Expanded(
            flex: 1, // change the flex value if you want to give more or less then 10%
            child: Container(
              width: double.infinity,
              color: topColor,
              child: SafeArea(  // more about safearea: https://docs.flutter.dev/ui/adaptive-responsive/safearea-mediaquery 
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  // The external content is inserted here
                  child: Center(child: topContent), 
                ),
              ),
            ),
          ),

          // Middle part (80%)
          Expanded(
            flex: 8, // change the flex value if you want to give more or less then 80%
            child: Container(
              width: double.infinity,
              color: middleColor,
              // The external content is inserted here
              child: middleContent,
            ),
          ),

          // bottom part (10%)
          Expanded(
            flex: 1, // change the flex value if you want to give more or less then 10%
            child: Container(
              width: double.infinity,
              color: bottomColor,
              // The external content is inserted here
              child: bottomContent,
            ),
          ),
        ],
      ),
    );
  }
}