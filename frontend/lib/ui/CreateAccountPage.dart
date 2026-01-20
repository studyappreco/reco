
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' show User;
import 'package:frontend/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/ui/SpecifyDegreePage.dart';
import 'package:frontend/ui/utils/auth.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';
import 'package:frontend/ui/widgets/PasswordField.dart';
import 'package:frontend/ui/widgets/ValidatedtextField.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


class CreateAccountForm extends StatefulWidget {
  const CreateAccountForm({super.key});

  @override
  CreateAccountFormState createState() {
    return CreateAccountFormState();
  }
}

class CreateAccountFormState extends State<CreateAccountForm> {

  final _formKey = GlobalKey<FormState>();
  late FocusNode formFocusNode;

  final nameController = TextEditingController();
  final  emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordControllerRepeat = TextEditingController();

  @override
  void initState() {
    super.initState();
    formFocusNode = FocusNode();
  }

  @override
  void dispose() {
    formFocusNode.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordControllerRepeat.dispose();
    super.dispose();
  }

  Future<void> registerNewUser () async {
      Client? client = BackendClient.getBackendClient();
      if (client == null) throw Exception("Backend client could not be initialized");
      Account account = Account(client);

      String userName = nameController.text;
      String userPassword = passwordController.text;
      String userEmail = emailController.text;

      User user = await account.create(
          userId: ID.unique(),
          email: userEmail,
          password: userPassword,
          name: userName,
      );
  }

  String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Name cannot be empty";
    }
    if (value.length < 5) {
      return "Name must exceed 5 characters";
    }

    return null;
  }

  String? passwordValidatorRepeat(String? value) {
    if (value == null || value.isEmpty) {
      return "Repeat Password cannot be empty";
    }
    if (passwordController.text != value) {
      return "Passwords do not match";
    }
    return null;
  }

  Future<void> onContinueClick () async {
    if (_formKey.currentState!.validate()) {
      try {
        await registerNewUser();
        context.go('/register/specify-degree');
      } on Exception catch (e) {
        print(e.toString());
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert'),
              content: Text('Creating'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // closes the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.standardWhitebackground,
      appBar: AppBar(title: const Text("Create your account")),
      body:

      Form(
        key: _formKey,
        child: Stack(
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 350,
                    child: ValidatedTextField(focusNode: null,
                        validator: nameValidator,
                        labelText: "User Name", controller: nameController),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 350,
                    child: ValidatedTextField(focusNode: null,
                        validator: emailValidator,
                        labelText: "example@gmail.com", controller: emailController),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: 350,
                    child: PasswordField(controller: passwordController, label: "Password", hint: "Enter your password")),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 350,
                    child: PasswordField(controller: passwordControllerRepeat, label: "Repeat password", hint: "Repeat your password", validator: passwordValidatorRepeat)),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: .end,
                  crossAxisAlignment: .center,
                  children: [
                    AdaptiveButton(
                      onPressed: onContinueClick,
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(child: Text("Continue"))
                      )
                    ),
                    Row(
                      mainAxisAlignment: .center,
                      children: [
                        Text("Already have an account?"),
                        TextButton(
                          onPressed: () => context.go('/register/sign-in'),
                          child: Text("Sign in")
                        )
                      ],
                    )
                  ],
                )
              )
            )
          ]
        )
      ),
    );
  }
}



