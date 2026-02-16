import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/theme/colors.dart';
import 'package:frontend/repos/UserRepository.dart';
import 'package:frontend/ui/utils/auth.dart';

class InterestSelectionPage extends StatelessWidget {
  const InterestSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<InterestSelectionViewmodel>(
      create: (_) => InterestSelectionViewmodel(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Please select your areas of Interest in your degree")),
        body: Consumer<InterestSelectionViewmodel>(
          builder: (context, vm, child) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: vm.allInterests.map((interest) {
                final isSelected = vm.selectedInterests.contains(interest);
                return _InterestChip(
                  label: interest,
                  isSelected: isSelected,
                  onTap: () => vm.toggleInterest(interest),
                );
              }).toList(),
            );
          },
        ),
        bottomNavigationBar: Consumer<InterestSelectionViewmodel>(
          builder: (context, vm, child) {
            final enabled = vm.selectedInterests.length >= 3;
            return Padding(
              padding: const EdgeInsets.all(25),
              child: AdaptiveButton(
                onPressed: enabled ? () async {
                  final repo = UserRepository();
                  final session = context.read<ClientSession>();
                  final userId = session.newUser?.$id ?? session.getUserID();
                  if (userId != null) {
                    try {
                      await repo.updateInterests(userId, vm.selectedInterests);
                    } catch (e) {
                      debugPrint('Failed to save interests: $e');
                    }
                  } else {
                    debugPrint('No userId available to save interests');
                  }
                  if (!context.mounted) return;
                  context.go('/register/specify-degree/interests/upload-transcript');
                } : null,
                child: Text("Continue")
              )
            );
          },
        ),
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _InterestChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : AppColors.primaryBlueLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : AppColors.primaryBlueLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? CupertinoColors.white
                : CupertinoColors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class InterestSelectionViewmodel extends ChangeNotifier {
  final List<String> _allInterests = <String>["Machine Learning", "Blockchain", "5G/6G Networks", "Artificial Intelligence", "Probability"];
  final List<String> _selectedInterests = <String>[];

  List<String> get allInterests => _allInterests;
  List<String> get selectedInterests => _selectedInterests;

  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
    notifyListeners();
  }
}

