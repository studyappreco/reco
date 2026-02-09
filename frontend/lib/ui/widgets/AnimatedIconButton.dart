import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

import 'package:frontend/theme/colors.dart';

// 
// https://www.youtube.com/watch?v=WuXus0RlWrU
//
// https://api.flutter.dev/flutter/animation/Curves-class.html

class AnimatedIconButton extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;
  
  final IconData? icon;
  final IconData? selectedIcon;
  
  final String? svgAsset;
  final String? selectedSvgAsset;

  final Color activeColor;
  final Color activeBackgroundColor;
  final Color inactiveColor;
  

  const AnimatedIconButton({
    super.key,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.selectedIcon,
    this.svgAsset,
    this.selectedSvgAsset,
    required this.activeColor,
    required this.activeBackgroundColor,
    required this.inactiveColor,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

// https://api.flutter.dev/flutter/widgets/SingleTickerProviderStateMixin-mixin.html
class _AnimatedIconButtonState extends State<AnimatedIconButton> with SingleTickerProviderStateMixin {
  
  // https://api.flutter.dev/flutter/animation/AnimationController-class.html
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideUpAnimation;    // for the add +1 animation
  late Animation<Offset> _slideDownAnimation;  // for the remove -1 animation
  late Animation<double> _fadeAnimation;
  late Animation<double> _sparksAnimation;

  bool _isAdding = false; 

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // https://api.flutter.dev/flutter/animation/Tween-class.html
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_controller);

    _slideUpAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.8),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _slideDownAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 0.8),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInQuad));

    // https://api.flutter.dev/flutter/animation/TweenSequence-class.html
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 50),
    ]).animate(_controller);

    _sparksAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isAdding = !widget.isSelected;
      _updateScaleAnimation(!widget.isSelected); 
    });

    _controller.reset();
    _controller.forward();
    
    widget.onTap();
  }

  // is for the “pump” effect (scaling) of the button when clicked
  void _updateScaleAnimation(bool isAdding){
    // animation logic is that it gets bigger on add, shrinks on remove
    if(isAdding){
      // https://api.flutter.dev/flutter/animation/TweenSequence-class.html
      _scaleAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 20),
        TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.2).chain(CurveTween(curve: Curves.easeOutBack)), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 30),
      ]).animate(_controller);
    } else {
      _scaleAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 40),
        TweenSequenceItem(tween: Tween(begin: 0.9, end: 0.9), weight: 20),
        TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 40),
      ]).animate(_controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double iconSize = 20.0;
    const double totalSize = 32.0; // includes icon and circle size
    const double explosionAreaSize = totalSize * 3.5; // includes invisible space for the particle animation
    const double explosionOffset = -(explosionAreaSize - totalSize) / 2; // calculating the negative start position (top-left) to center the explosion area over the button

    final Color backgroundColor = widget.isSelected 
        ? widget.activeBackgroundColor 
        : AppColors.greyLight;

    final Color iconColor = widget.isSelected 
        ? widget.activeColor 
        : widget.inactiveColor;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        width: totalSize,
        height: totalSize,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none, 
          children: [
            // animating ParticlePainter
            if(_isAdding)
              Positioned(
                left: explosionOffset,
                top: explosionOffset,
                // https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    // https://api.flutter.dev/flutter/widgets/CustomPaint-class.html
                    return CustomPaint(
                      size: Size(explosionAreaSize, explosionAreaSize),
                      painter: ParticlePainter(
                        progress: _sparksAnimation.value,
                        color: widget.activeColor,
                        visibility: _fadeAnimation.value,
                      ),
                    );
                  }
                ),
              ),

            // button and Icon animation
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: totalSize,
                    height: totalSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: backgroundColor,
                      border: Border.all(
                        color: widget.isSelected ? widget.activeColor : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                    child: _buildIconContent(iconColor, iconSize),
                  ),
                );
              }
            ),

            // +1 / -1 text animation
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                if(_controller.isDismissed || _controller.isCompleted) return const SizedBox();

                final String text = _isAdding ? "+1" : "-1";
                final Offset offset = _isAdding ? _slideUpAnimation.value : _slideDownAnimation.value;
                
                return Transform.translate(
                  offset: Offset(0, offset.dy * 5),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContent(Color color, double size) {
    if(widget.svgAsset != null){
      final String icon = widget.isSelected ? (widget.selectedSvgAsset ?? widget.svgAsset!) : widget.svgAsset!;
          
      return SvgPicture.asset(
        icon,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        alignment: Alignment.center,
      );
    }
    
    return Icon(
      widget.isSelected ? (widget.selectedIcon ?? widget.icon) : widget.icon,
      color: color,
      size: size,
    );
  }
}

// Renders a particle burst effect expanding from the center
// https://api.flutter.dev/flutter/rendering/CustomPainter-class.html
class ParticlePainter extends CustomPainter {
  final double progress; // 0.0 = start (center), 1.0 = end
  final Color color;
  final double visibility;

  ParticlePainter({required this.progress, required this.color, required this.visibility});

  @override
  void paint(Canvas canvas, Size size) {
    
    // do nothing if it's invisible
    if(visibility <= 0) return;
    
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
      
    final double center = size.width / 2;
    final double maxExplosionRadius = size.width * 0.45; 
    
    // calculating current position 
    // progress is 0.0  -> radius is in 0 (center)
    // progress is 1.0 -> Radius is 45% outside
    final double currentRadius = maxExplosionRadius * progress;

    // drawing 16 points (we can change that here if we want more or less)
    const int particleCount = 16;

    // loop for each point to calculate the position, size, etc.
    for(int i = 0; i < particleCount; i++){
      // dividing the full circle (2 * Pi) by the number of particles
      // and multiply by i so that each point gets its own angle
      final double angle = (2 * math.pi / particleCount) * i;
      
      // calculating the position (x, y) 
      // cos(winkel) * radius = X-Position von der Mitte
      // sin(winkel) * radius = Y-Position von der Mitte
      final double dx = center + math.cos(angle) * currentRadius;
      final double dy = center + math.sin(angle) * currentRadius;
      
      // calculating size of the point
      // (1.0 - progress) ensures that it becomes smaller the further it is
      // at the end (progress = 1.0), the size is 0
      final double dotSize = 4.0 * (1.0 - progress); 
      
      // drawing a circle at position (dx, dy) with radius dotSize
      canvas.drawCircle(Offset(dx, dy), dotSize, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}