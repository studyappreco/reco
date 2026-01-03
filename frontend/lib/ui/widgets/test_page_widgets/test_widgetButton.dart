import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../adaptive_button.dart';

// Shows how to use AdaptiveButton with two variants that we will definitely use in the future
class TestWidgetButton extends StatelessWidget {
  const TestWidgetButton({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                padding: EdgeInsets.only(top: 40),
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
                            child: Text("Current GPA", style: textTheme.titleSmall?.copyWith(color: Colors.white)),
                          ),
                          Text("3.7", style: textTheme.headlineMedium?.copyWith(color: Colors.white)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 4.0),
                            child: Text("Total ECTS", style: textTheme.titleSmall?.copyWith(color: Colors.white)),
                          ),
                          Text("120", style: textTheme.headlineMedium?.copyWith(color: Colors.white)),
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
  }
}