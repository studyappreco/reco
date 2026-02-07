import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:frontend/repos/TranscriptRepository.dart';
import 'package:frontend/theme/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/ui/InterestSelectionPage.dart';
import 'package:frontend/ui/PlannerPage.dart';
import 'package:frontend/ui/ReviewCoursesPage.dart';
import 'package:frontend/ui/SpecifyDegreePage.dart';
import 'package:frontend/ui/UploadTranscriptPage.dart';
import 'package:frontend/ui/utils/auth.dart';
import 'package:frontend/repos/TranscriptRepository.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/ui/NavigationWrapper.dart';
import 'package:frontend/ui/CourseDetailsPage.dart';
import 'package:frontend/ui/HomePage.dart';
import 'package:frontend/ui/SignInPage.dart';
import 'package:frontend/ui/SearchPage.dart';
import 'package:frontend/ui/CreateAccountPage.dart';
import 'package:frontend/ui/OnboardingPage.dart';
import 'package:frontend/ui/widgets/test_page_widgets/test_widgetButton.dart';
import 'package:frontend/ui/widgets/test_page_widgets/test_searchfield.dart';
import 'package:frontend/ui/widgets/test_page_widgets/test_course_card_page.dart';
import 'package:frontend/ui/widgets/test_page_widgets/test_StatusMessage.dart';
import 'package:provider/provider.dart';
import 'package:frontend/ui/GiveFeedback.dart';


// Use these instances globally
final clientSession = ClientSession();
final transcriptProcessor = TranscriptProcessor();

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: clientSession),
        ChangeNotifierProvider.value(value: transcriptProcessor),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Reco Demo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // themeMode: ThemeMode.system, // = Switches automatically depending on cell phone settings
      themeMode: ThemeMode.light, //  = Always forces light mode
      routerConfig: router,
    );
  }
}

final router = GoRouter(
  initialLocation: '/home',
  refreshListenable: clientSession,

  redirect: (context, state) {
    final loggedIn = clientSession.isLoggedIn;
    final onAuthFlow = state.uri.path.startsWith('/sign-in') || 
                       state.uri.path.startsWith('/register') ||
                       state.uri.path.startsWith('/onboarding');

    if (!loggedIn && !onAuthFlow) {
      return '/onboarding';
    }

    if (loggedIn && onAuthFlow) {
      return '/home';
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => OnboardingPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => CreateAccountForm(),
      routes: [
        GoRoute(
          path: '/sign-in',
          builder: (context, state) => SignInPageForm(),
        ),
        GoRoute(
          path: 'specify-degree',
          builder: (context, state) => SpecifyDegreePage(),
          routes: [
            GoRoute(
              path: 'interests',
              builder: (context, state) => InterestSelectionPage(),
              routes: [

                GoRoute(
                  path: '/upload-transcript',
                  builder: (context, state) => UploadTranscriptPage(),
                ),
              ]
            ),
          ]
        ),
      ]
    ),

    ShellRoute(
      builder: (context, state, child) {
        return NavigationWrapper(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => HomePage(),
          routes: [
            GoRoute(
              path: 'course-details',
              builder: (context, state) {  // https://stackoverflow.com/questions/72976031/flutter-go-router-how-to-pass-multiple-parameters-to-other-screen
                  final moduleNr = state.extra as String;
                  return CourseDetailsPage(moduleNr: moduleNr);
              },
            ),
          ]
        ),
        GoRoute(
          path: '/review-courses',
          builder: (context, state) => ReviewCoursesPage(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => SearchPage(),
          routes: [
            GoRoute(
              path: 'course-details',
              builder: (context, state) {  // https://stackoverflow.com/questions/72976031/flutter-go-router-how-to-pass-multiple-parameters-to-other-screen
                  final moduleNr = state.extra as String;
                  return CourseDetailsPage(moduleNr: moduleNr);
              },
            ),
          ],
        ),

        GoRoute(
          path: '/planner',
          builder: (context, state) => PlannerPage(),
        ),
        GoRoute(
          path: '/favourites',
          builder: (context, state) => Center(child: Text("The FavouritesPage will be added here later")),
        ),
        GoRoute(
          path: '/feedback',
          builder: (context, state) => const GiveFeedbackPage(),
        ),
        GoRoute(
          path: '/demo',
          builder: (context, state) => MyHomePage(title: "Demo Home Page"),
        ),
      ],
    ),
  ],
);


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPageForm()),
                );
              },
              child: const Text("Sign in Page"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateAccountForm()),
                );
              },
              child: const Text("Create Account"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: const Text("Home Page"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailsPage(
                      moduleNr: "400", 
                    ),
                  ),
                );
              },
              child: const Text("Course Details Page"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadTranscriptPage()),
                );
              },
              child: const Text("Upload transcript"),
            ),
            // shows how to use the adaptive button in TestWidgetButton
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TestWidgetButton()),
                );
              },
              child: const Text("example Adaptive Button"),
            ),

            // shows how to use the adaptive search field in SearchScreen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
              child: const Text("example Search Screen"),
            ),
            
            // shows how to use course card
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TestCourseCardPage()),
                );
              },
              child: const Text("example Course Card"),
            ),

            ElevatedButton(
              onPressed: () async {
                Client? client = BackendClient.getBackendClient();
                if (client == null) {
                  clientSession.clearUserSession();
                  return;
                }
                Account account = Account(client);
                await account.deleteSession(sessionId: 'current');
                clientSession.clearUserSession();
              },
              child: const Text("Logout"),
            ),
            
            // shows how to use course card
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TestStatusMessage()),
                );
              },
              child: const Text("example StatusMessage"),
            ),
            // Test OpenAI transcript parsing
            ElevatedButton(
              onPressed: () async {
                debugPrint("starting");
                final pdfFile = File('/Users/I762666/Documents/private/reco/backend-appwrite/trans.pdf');
                var repo = TranscriptRepository();
                var res = await repo.uploadAndParseTranscript(pdfFile: pdfFile, userID: "schwanz", programLiteral: "ISM");
                if (res != null) {
                  debugPrint(res.toString());
                } else {
                  debugPrint('Error: Failed to parse transcript');
                }
              },
              child: const Text("Parse transcript"),
            ),
            
          ],
        ),
      ),
    );
  }
}
