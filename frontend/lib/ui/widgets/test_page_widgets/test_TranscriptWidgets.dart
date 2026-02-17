import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/AdaptiveButton.dart'; 
import 'package:frontend/ui/widgets/TranscriptMissingCard.dart'; 
import 'package:frontend/ui/widgets/TranscriptProcessingCard.dart'; 

class TranscriptProcessingTestScreen extends StatefulWidget {
  const TranscriptProcessingTestScreen({super.key});

  @override
  State<TranscriptProcessingTestScreen> createState() => _TranscriptProcessingTestScreenState();
}

enum TestState { missing, processing, result }

class _TranscriptProcessingTestScreenState extends State<TranscriptProcessingTestScreen> {
  
  // controls the displayed elements
  TestState _currentState = TestState.missing;
  bool _cardHasFinished = false; 

  void _switchToMissing() {
    setState(() {
      _currentState = TestState.missing;
    });
  }

  void _switchToProcessing() {
    setState(() {
      _currentState = TestState.processing;
      _cardHasFinished = false;
    });
  }

  void _triggerFinish() {
    if (_currentState == TestState.processing) {
      setState(() {
        _cardHasFinished = true; 
      });
    } else {
      setState(() {
        _currentState = TestState.result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text("Transcript Processing Flow Test")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            
            // simulation buttons 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _switchToMissing,
                  child: Text("Missing"),
                ),
                ElevatedButton(
                  onPressed: _switchToProcessing,
                  child: Text("Processing"),
                ),
                ElevatedButton(
                  onPressed: _triggerFinish,
                  child: Text("Finish"),
                ),
              ],
            ),

            const SizedBox(height: 40),

            _buildCurrentContent(textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentContent(TextTheme textTheme) {
    switch (_currentState) {
      
      case TestState.missing:
        return TranscriptMissingCard(
          onUploadPressed: () {
            print("Upload -> Processing");
            _switchToProcessing();
          },
          onSkipPressed: () => print("Skip"),
        );

      case TestState.processing:
        return TranscriptProcessingCard(
          hasFinished: _cardHasFinished,
          onAnimationComplete: () {
            setState(() {
              _currentState = TestState.result;
            });
          },
        );

      case TestState.result:
        return AdaptiveButton(
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text("Current GPA", style: textTheme.titleSmall?.copyWith(color: Colors.white)),
                    ),
                    Text("2.3", style: textTheme.headlineMedium?.copyWith(color: Colors.white)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text("Current ECTS", style: textTheme.titleSmall?.copyWith(color: Colors.white)),
                    ),
                    Text("85", style: textTheme.headlineMedium?.copyWith(color: Colors.white)),
                  ],
                ),
              ],
            ),
          );
    }
  }
}