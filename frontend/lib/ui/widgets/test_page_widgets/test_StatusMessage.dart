import 'package:flutter/material.dart';
import '../StatusMessage/StatusMessage.dart';


// Shows how to use StatusMessage with success and error variants
class TestStatusMessage extends StatelessWidget {
  const TestStatusMessage({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: Text("Status Message")),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              

              ElevatedButton(
                  onPressed: () {
                    // That's how you should use it
                    StatusMessage.show(
                        context: context,
                        alignment: SnackAlignment.TOP,
                        title: "Success!",
                        message: "Your transcript has been recorded.",
                        isError: false,
                        duration: Duration(seconds: 8), // New: You can now specify how long the message should be displayed, If nothing is specified, 4 seconds is always displayed
                    );
                  },
                  child: Text("Top Success")),
              
              ElevatedButton(
                  onPressed: () {
                    StatusMessage.show(
                        context: context,
                        alignment: SnackAlignment.CENTER,
                        title: "Success!",
                        message: "Your transcript has been recorded.",
                        isError: false);
                  },
                  child: Text("Center Success")),

              ElevatedButton(
                  onPressed: () {
                    StatusMessage.show(
                        context: context,
                        alignment: SnackAlignment.BOTTOM,
                        title: "Success!",
                        message: "Your transcript has been recorded.",
                        isError: false);
                  },
                  child: Text("Bottom Success")),



              ElevatedButton(
                  onPressed: () {
                    StatusMessage.show(
                        context: context,
                        alignment: SnackAlignment.TOP,
                        title: "Oops! Something went wrong. ",
                        message: "Please retry entering the transcript.",
                        isError: true);
                  },
                  child: Text("Top Error")),
              
              ElevatedButton(
                  onPressed: () {
                    StatusMessage.show(
                        context: context,
                        alignment: SnackAlignment.CENTER,
                        title: "Oops! Something went wrong. ",
                        message: "Please retry entering the transcript.",
                        isError: true);
                  },
                  child: Text("Center Error")),

              ElevatedButton(
                  onPressed: () {
                    StatusMessage.show(
                        context: context,
                        alignment: SnackAlignment.BOTTOM,
                        title: "Oops! Something went wrong. ",
                        message: "Please retry entering the transcript.",
                        isError: true);
                  },
                  child: Text("Bottom Error")),

            ],
          ),
        ),
      ),
    );
  }
}
