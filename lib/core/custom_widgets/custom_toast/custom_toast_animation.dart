import 'package:flutter/material.dart';

class CustomOffsetAnimation extends StatefulWidget {
  final AnimationController controller;
  final Widget child;

  const CustomOffsetAnimation({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<CustomOffsetAnimation> createState() => _CustomOffsetAnimationState();
}

class _CustomOffsetAnimationState extends State<CustomOffsetAnimation> {
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _offsetAnimation =
        Tween<Offset>(
          begin: const Offset(0, -1.5),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(
            parent: widget.controller,
            curve: Curves.bounceOut,
            reverseCurve: Curves.bounceIn,
          ),
        );
    _fadeAnimation = CurvedAnimation(
      parent: widget.controller,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
    );
  }
}
