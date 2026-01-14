
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/PasswordField.dart';
import 'package:frontend/ui/widgets/ValidatedtextField.dart';
import 'package:frontend/ui/utils/auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart';

class SingInPageForm extends StatefulWidget {
  const SingInPageForm({super.key});

  @override
  SignInPageState createState() {
    return SignInPageState();
  }
}

class SignInPageState extends State<SingInPageForm> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser () async {
    Client? client = BackendClient.getBackendClient();
    if (client == null) throw Exception("Backend client could not be initialized");
    Account account = Account(client);

    String userPassword = passwordController.text;
    String userEmail = emailController.text;

    Session session = await account.createEmailPasswordSession(email: userEmail, password: userPassword);
    print(session.toString());
    context.read<ClientSession>().setUserSession(session);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.standardWhitebackground,
      appBar: AppBar(title: const Text("Welcome, Sign in tp Reco")),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                ],
              ),
            )
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
                    onPressed: loginUser, 
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text("Sign In"),
                      )
                    )
                  ),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: Text("Create Account")
                  )
                ],
              )
            )
          )
        ],
      ),
    );
  }
}