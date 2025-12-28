import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../adaptive_button.dart';

// Shows how to use AdaptiveButton with two variants that we will definitely use in the future
class TestWidgetButton extends StatelessWidget {
  const TestWidgetButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Theme (will then be globally outsourced if we use the implementation in the PR #26)
      data: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF155DFC),
          brightness: Brightness.light,
          primary: Color(0xFF155DFC),
        ),
        
        textTheme: TextTheme(
          // https://api.flutter.dev/flutter/material/TextTheme-class.html
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
        ),
        
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: Colors.white),
          ),
        ),
      ),
      
      child: CupertinoTheme(
        data: CupertinoThemeData(
          primaryColor: Color(0xFF155DFC),
        ),

        child: Builder(
          builder: (innerContext) {
            final textTheme = Theme.of(innerContext).textTheme;

            return Scaffold(
              appBar: AppBar(title: Text("Adaptive Button")),
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // first Button example
                      AdaptiveButton(
                        onPressed: () => print("Feedback pressed"),
                        child: Text("Submit Feedback"),
                      ),

                      // second Button example
                      Padding(
                        padding:  EdgeInsets.only(top: 40),
                        child: AdaptiveButton(
                          onPressed: () => print("GPA pressed"),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 4.0),
                                    child: Text("Current GPA", style: textTheme.titleSmall),
                                  ),
                                  Text("3.7", style: textTheme.headlineMedium),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 4.0),
                                    child: Text("Total ECTS", style: textTheme.titleSmall),
                                  ),
                                  Text("120", style: textTheme.headlineMedium),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}