import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/ui/InterestSelectionPage.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';

class SpecifyDegreePage extends StatefulWidget {
  const SpecifyDegreePage({super.key});

  @override
  State<SpecifyDegreePage> createState() => _SpecifyDegreePageState();
}

class _SpecifyDegreePageState extends State<SpecifyDegreePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Specify your degree"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: DropdownMenuDegree(
                    selectives: const [
                      DropdownMenuEntry(value: "Bachelor", label: "Bachelor's degree"),
                      DropdownMenuEntry(value: "Master", label: "Master's degree")
                    ],
                    menuLabel: "Degree Type",
                    initialSelection: "",
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: DropdownMenuDegree(
                    selectives: const [
                      DropdownMenuEntry(value: "Information Systems Management", label: "Information Systems Management")
                    ],
                    menuLabel: "Field of Study",
                    initialSelection: "",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(25),
        child: AdaptiveButton(child: Text("Continue"), onPressed: () =>
            context.go('/register/specify-degree/interests')
        )
        ),
      );
  }
}

class DropdownMenuDegree extends StatefulWidget {
  const DropdownMenuDegree({
    super.key,
    required this.selectives,
    required this.menuLabel,
    required this.initialSelection,
  });

  final String initialSelection;
  final String menuLabel;
  final List<DropdownMenuEntry<String>> selectives;

  @override
  State<DropdownMenuDegree> createState() => _DropdownMenuDegreeState();
}

class _DropdownMenuDegreeState extends State<DropdownMenuDegree> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    final initialSelection = widget.initialSelection;
    final entries = widget.selectives;
    final label = widget.menuLabel;

    return DropdownMenu<String>(
      width: 350,
      initialSelection: initialSelection,
      requestFocusOnTap: true,
      label: Text(label),
      onSelected: (String? degreeType) {
        setState(() {
          selected = degreeType;
        });
      },
      dropdownMenuEntries: entries,
    );
  }
}
