import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../repository/InterestsService.dart';

class InterestSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InterestSelectionViewmodel()..fetchInterests(),
      child: Consumer<InterestSelectionViewmodel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return Center(child: CupertinoActivityIndicator());
          }

          if (vm.errorMessage != null) {
            return Center(child: Text(vm.errorMessage!));
          }

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vm.allInterests.map((interest) {
              final isSelected = vm.selectedInterests.contains(interest);
              return _InterestChip(
                label: interest,
                isSelected: isSelected,
                onClick: () => vm.toggleInterest(interest),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

//class InterestSelectionScreen extends StatelessWidget {
//    @override
// Widget build(BuildContext context) {
//    return CupertinoPageScaffold(
//        backgroundColor: CupertinoColors.inactiveGray,
//        navigationBar: const CupertinoNavigationBar(middle: Text("Select your interests in the field of Study")),
//
//    )

//    )
//  }

//}


class _InterestChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onClick;

  const _InterestChip({
    required this.label,
    required this.isSelected,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoColors.activeBlue
              : CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? CupertinoColors.activeBlue
                : CupertinoColors.systemGrey4,
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
  List<String> _allInterests = <String>[];
  final List<String> selectedInterests = <String>[];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<String> get allInterests => _allInterests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchInterests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allInterests = await InterestsService.fetchInterests();
    } catch (e) {
      _errorMessage = "Could not load interests";
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
    notifyListeners();
  }
}
