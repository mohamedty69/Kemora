import 'package:flutter/material.dart';

class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const TapScale({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: Duration(milliseconds: _isPressed ? 120 : 200),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
