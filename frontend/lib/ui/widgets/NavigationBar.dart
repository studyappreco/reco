import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/theme/colors.dart';

// https://api.flutter.dev/flutter/material/NavigationBar-class.html

class NavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;

  const NavBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      
      destinations: [
        NavigationDestination(
          icon: SvgPicture.asset(
            'assets/icons/home.svg',
            colorFilter: ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
            ),

          selectedIcon: SvgPicture.asset(
              'assets/icons/home.svg',
              colorFilter: ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn),
            ),
          label: 'Home',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(
            'assets/icons/search.svg',
            colorFilter: ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
            ),

          selectedIcon: SvgPicture.asset(
              'assets/icons/search.svg',
              colorFilter: ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn),
            ),
          label: 'Search',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(
            'assets/icons/book-open.svg',
            colorFilter: ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
            ),
          
          selectedIcon: SvgPicture.asset(
              'assets/icons/book-open.svg',
              colorFilter: ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn),
            ),
          
          label: 'Planner',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border, color: AppColors.textSecondary),
          selectedIcon: Icon(Icons.favorite_border, color: AppColors.primaryBlue),
          label: 'Favorites',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(
            'assets/icons/speech-bubble.svg',
            colorFilter: ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
            ),

          selectedIcon: SvgPicture.asset(
              'assets/icons/speech-bubble.svg',
              colorFilter: ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn),
            ),
          label: 'Feedback',
        ),
        NavigationDestination(
          icon: Icon(Icons.construction, color: AppColors.textSecondary),

          selectedIcon: Icon(Icons.construction, color: AppColors.primaryBlue),
          label: 'Demo',
        ),
      ],
    );
  }
}