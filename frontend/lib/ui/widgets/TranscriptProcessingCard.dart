import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/theme/colors.dart';

// https://www.geeksforgeeks.org/flutter/flutter-line-progressbar-with-card-widget-using-buttons/
// https://medium.com/@punithsuppar7795/mastering-progress-indicators-in-flutter-build-a-custom-reusable-linearprogressindicator-68d73abf12f0
// https://o7planning.org/13165/flutter-linearprogressindicator
// https://medium.com/@expertappdevs/mastering-flutter-progress-indicators-8606ac1ec788

class TranscriptProcessingCard extends StatefulWidget {
  final bool hasFinished;
  final VoidCallback onAnimationComplete;

  const TranscriptProcessingCard({
    super.key,
    required this.hasFinished,
    required this.onAnimationComplete,
  });

  @override
  State<TranscriptProcessingCard> createState() => _TranscriptProcessingCardState();
}

class _TranscriptProcessingCardState extends State<TranscriptProcessingCard> {

  final int _totalSteps = 4;
  int _currentStepIndex = 0;
  double _progressValue = 0.0;
  Timer? _simulationTimer;
  bool _isFastForwarding = false;

  final int _totalExpectedDurationSec = 120; // assumed time until completion (2 min)
  late final double _progressIncrementPerTick;

  @override
  void initState() {
    super.initState();
    _progressIncrementPerTick = 1.0 / (_totalExpectedDurationSec * 10); //  * 10 so that we update the progress 10 times every second to make it look good
    _startSimulation();
  }

  @override
  void didUpdateWidget(TranscriptProcessingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.hasFinished && !oldWidget.hasFinished && !_isFastForwarding) {
      _triggerFastFinish();
    }
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _startSimulation() {
    _simulationTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {  // progress is updated every 100 milliseconds, we can also change that if desired
      if(_isFastForwarding) return;

      setState(() {
        _progressValue += _progressIncrementPerTick;
        // stop at 95% in step index 3 if not yet finished
        if(_progressValue > 0.95 && !widget.hasFinished){
           _progressValue = 0.95;
           _currentStepIndex = 3; 
        } else {
          if(_progressValue < 0.25){
            _currentStepIndex = 0;
          }
          else if(_progressValue < 0.50){
            _currentStepIndex = 1;
          }
          else if(_progressValue < 0.70){
            _currentStepIndex = 2;
          }
          else{
            _currentStepIndex = 3;
          }
        }
      });
    });
  }

  void _triggerFastFinish() async {
    _isFastForwarding = true;
    _simulationTimer?.cancel();

    // https://stackoverflow.com/questions/55502528/flutter-multiple-async-methods-for-parrallel-execution

    // progress bar fill animation
    // we can speed up/slow down the animation here when the response is ready.
    Future<void> animateBar() async {
      while(_progressValue < 1.0){
        if(!mounted) return;
        setState(() {
          _progressValue += 0.01;
          if(_progressValue > 1.0) _progressValue = 1.0;
        });
        await Future.delayed(Duration(milliseconds: 10)); 
      }
    }

    // steps animation without step 4
    Future<void> animateSteps() async {
      for(int i = _currentStepIndex; i < _totalSteps; i++){
        if(!mounted) return;
        setState(() {
          _currentStepIndex = i;
        });
        await Future.delayed(const Duration(milliseconds: 150)); 
      }
    }

    // https://api.flutter.dev/flutter/dart-async/Future/wait.html
    await Future.wait([animateBar(), animateSteps()]);

    // Steps animation last one to make it look better
    if(mounted){
      setState(() {
        _currentStepIndex = _totalSteps;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      widget.onAnimationComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.standardWhitebackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(100, 10, 10, 10),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // icon
          Container(
            margin: EdgeInsets.only(bottom: 24), 
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/transcriptProcessing.svg',
                      colorFilter: ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn),
                      height: 40,
                      width: 40,
                    ),
                  ),
                ),
                
                // the little green icon
                if(_currentStepIndex >= _totalSteps)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color(0xFF00C950),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.standardWhitebackground, width: 3.0),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/successIcon.svg',
                        colorFilter: ColorFilter.mode(AppColors.standardWhitebackground, BlendMode.srcIn),
                        height: 14,
                        width: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          Text(
            "Processing Your Transcript",
            style: textTheme.titleLarge?.copyWith(color: AppColors.textMain, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              "We're analyzing your academic data. Your overview will be ready shortly.",
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),

          // loading bar
          // https://stackoverflow.com/questions/57534160/how-to-add-a-border-corner-radius-to-a-linearprogressindicator-in-flutter
          Padding(
            padding: EdgeInsets.only(top: 32, bottom: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progressValue,
                backgroundColor: AppColors.greyLight,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                minHeight: 6,
              ),
            ),
          ),

          // the individual steps
          Column(
            children: [
              _buildStepCard(0, "Analyzing transcript", textTheme),
              _buildStepCard(1, "Extracting course data", textTheme),
              _buildStepCard(2, "Calculating GPA & ECTS", textTheme),
              _buildStepCard(3, "Finalizing overview", textTheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(int index, String title, TextTheme textTheme) {
    bool isCompleted = index < _currentStepIndex;
    bool isActive = index == _currentStepIndex;

    // https://docs.flutter.dev/cookbook/animation/animated-container
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: isActive ? 12.0 : 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isCompleted 
            ? const Color(0xFFE8F5E9)   // if completed
            : isActive 
                ? const Color(0xFFEFF6FF) // if active
                : const Color(0xFFF9FAFB), // if awaiting

        border: Border.all(
          color: isCompleted 
              ? const Color(0xFFB9F8CF) // if completed
              : isActive 
                  ? const Color(0xFFBEDBFF) // if active
                  : const Color(0xFFEAEBEF), // if awaiting
        ),
      ),
      
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // setting the right icon
          if(isCompleted)
            Container(
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Color(0xFF00C950),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/icons/successIcon.svg',
                colorFilter: ColorFilter.mode(AppColors.standardWhitebackground, BlendMode.srcIn),
                height: 14,
                width: 14,
              ),
            )
          else if (isActive)
            Container(
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFF2B7FFF),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/icons/transcriptProcessing.svg',
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                height: 18,
                width: 18,
              ),
            )
          else
            Container(
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Color(0xFFE3E6E8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.schedule,
                color: Color(0xFF4A5568),
                size: 14,
              ),
            ),

          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: textTheme.bodyMedium!.copyWith(
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isCompleted || isActive
                    ? AppColors.textMain
                    : AppColors.textSecondary,
              ),
              child: Text(title),
            ),
          ),

          // Loading circuit
          if (isActive)
            Container(
              margin: EdgeInsets.only(left: 12),
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2979FF)),
              ),
            ),
        ],
      ),
    );
  }
}