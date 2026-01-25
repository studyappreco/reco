import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/StatusMessage/StatusMessageCard.dart';

// I have oriented myself on
// https://blog.stackademic.com/custom-snackbar-toast-in-flutter-9df4ce18bbf6
// https://medium.com/@artzaneg/creating-an-animated-top-snackbar-in-flutter-without-context-ddd0779acb8a

enum SnackAlignment {
  TOP,
  CENTER,
  BOTTOM,
}

class StatusMessage {
  static OverlayEntry? _overlayEntry;
  static Timer? _timer;
  static Timer? _animTimer; 
  static bool _isVisible = false; 

  static OverlayEntry _createOverlayEntry(
      String? title, String? message, bool? isError, SnackAlignment alignment) {
    
    // I will reduce these three options to one after we have selected what we want to use
    Alignment screenPosition;
    switch (alignment){
      case SnackAlignment.TOP:
        screenPosition = Alignment.topCenter;
        break;
      case SnackAlignment.BOTTOM:
        screenPosition = Alignment.bottomCenter;
        break;
      case SnackAlignment.CENTER:
      default:
        screenPosition = Alignment.center;
        break;
    }

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Align(
            alignment: screenPosition,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20.0), 
                child: Material(
                  type: MaterialType.transparency,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.9),
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 400),
                      child: _isVisible
                        ? StatusMessageCard(
                            isError: isError ?? false,
                            title: title ?? "Info",
                            message: message ?? "",
                            onClose: hide,
                          )
                        : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void show({
    String? title,
    String? message,
    bool? isError,
    required BuildContext context,
    required SnackAlignment alignment,
    Duration duration = const Duration(seconds: 4),
  }){
    if(_overlayEntry != null){
      _overlayEntry!.remove();
      _timer?.cancel();
      _animTimer?.cancel();
    }

    _overlayEntry = _createOverlayEntry(title, message, isError, alignment);
    _insertOverlay(context, duration);
  }

  static void hide(){
    _timer?.cancel();
    
    _isVisible = false;
    _overlayEntry?.markNeedsBuild();

    // Waiting for animation and then delete
    _animTimer = Timer( Duration(milliseconds: 500), (){
      if(_overlayEntry != null){
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  static void _insertOverlay(BuildContext context, Duration duration){
    _isVisible = false;
    Navigator.of(context).overlay!.insert(_overlayEntry!);

    // https://api.flutter.dev/flutter/dart-async/Future/Future.delayed.html && https://medium.com/@fozarar5/markneedsbuild-method-flutter-93de6a4a8030
    Future.delayed(Duration(milliseconds: 50), () {
      _isVisible = true;
      _overlayEntry?.markNeedsBuild(); 
    });

    _timer = Timer(duration, () {
      hide();
    });
  }
}