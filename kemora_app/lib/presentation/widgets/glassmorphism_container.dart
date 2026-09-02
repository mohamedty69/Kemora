import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double blurRadius;
  final BorderRadius? borderRadius;
  final Color color;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;

  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.opacity = 0.7,
    this.blurRadius = 24.0,
    this.borderRadius,
    this.color = Colors.white,
    this.padding,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(20);

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: effectiveRadius,
        border: border,
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
