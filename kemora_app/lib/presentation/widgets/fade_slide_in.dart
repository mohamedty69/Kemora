import 'package:flutter/material.dart';

class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int delayMs;
  final int durationMs;
  final Offset beginOffset;
  final Curve curve;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.durationMs = 500,
    this.beginOffset = const Offset(0, 0.05),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);
    
    // Slight upward slide
    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(curvedAnimation);

    if (widget.delayMs == 0) {
      _startAnimation();
    } else {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) {
          _startAnimation();
        }
      });
    }
  }

  void _startAnimation() {
    setState(() {
      _isStarted = true;
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isStarted) {
      return Opacity(opacity: 0, child: widget.child);
    }
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
