import 'package:flutter/material.dart';
import 'package:frontend/repos/UserRepository.dart';
import 'package:frontend/ui/utils/auth.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SpecifyDegreePage extends StatefulWidget {
  const SpecifyDegreePage({super.key});

  @override
  State<SpecifyDegreePage> createState() => _SpecifyDegreePageState();
}

class _SpecifyDegreePageState extends State<SpecifyDegreePage> {
  final _formKey = GlobalKey<FormState>();
  final List<_DropdownValue> degreeTypes = [
    _DropdownValue(value: "B", label: "Bachelor's degree"),
    _DropdownValue(value: "M", label: "Master's degree")
  ];
  final List<_DropdownValue> fieldsOfStudy = [
    _DropdownValue(value: "ISM", label: "Information Systems Management"),
    _DropdownValue(value: "CS", label: "Computer Science")
  ];
  String? degreeType;
  String? fieldOfStudy;

  Future<void> onContinue() async {
    final userRepo = UserRepository();
    final clientSession = context.read<ClientSession>();
    final userId = clientSession.newUser?.$id;
    if (userId == null) return;

    final literal = "${fieldOfStudy}_$degreeType";
    await userRepo.setProgramLiteral(userId, literal);
    clientSession.setNewUserLiteral(literal);

    if (!mounted) return;
    context.go('/register/specify-degree/interests');
  }

  @override
  Widget build(BuildContext context) {
    final continueEnabled = degreeType != null && fieldOfStudy != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Specify your degree"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: .spaceBetween,
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 350,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: degreeType,
                        decoration: InputDecoration(
                          labelText: "Degree Type",
                          border: OutlineInputBorder(),
                        ),
                        items: degreeTypes.map((field) {
                          return DropdownMenuItem(
                              value: field.value,
                              child: Text(field.label)
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => degreeType = val ?? ""),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 350,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: fieldOfStudy,
                        decoration: InputDecoration(
                          labelText: "Field of Study",
                          border: OutlineInputBorder(),
                        ),
                        items: fieldsOfStudy.map((field) {
                          return DropdownMenuItem(
                              value: field.value,
                              child: Text(field.label)
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => fieldOfStudy = val ?? ""),
                      ),
                    ),
                  ],
                ),
              )
            )
          ),
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: .end,
                  crossAxisAlignment: .center,
                  children: [
                    AdaptiveButton(
                      onPressed: continueEnabled ? onContinue : null,
                      child: SizedBox(
                          width: double.infinity,
                          child: Center(child: Text("Continue"))
                      )
                    ),
                  ],
                )
              )
            )
          )
        ],
      ),
    );
  }
}

class _DropdownValue {
  final String value;
  final String label;

  const _DropdownValue ({
    required this.value,
    required this.label,
  });
}
