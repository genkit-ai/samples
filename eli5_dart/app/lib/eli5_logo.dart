import 'package:flutter/material.dart';
import 'package:eli5_flutter/theme.dart';

class Eli5Logo extends StatefulWidget {
  final double fontSize;
  final bool animate;

  const Eli5Logo({super.key, this.fontSize = 120, this.animate = true});

  @override
  State<Eli5Logo> createState() => _Eli5LogoState();
}

class _Eli5LogoState extends State<Eli5Logo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'ELI5 - Explain Like I\'m 5',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final shift = widget.animate ? _controller.value * 0.5 : 0.0;
          return ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                ...Eli5Theme.gradientColors,
                Eli5Theme.gradientColors.first,
              ],
              stops: [0.0 + shift, 0.5 + shift, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: child,
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ELI',
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '5',
              style: TextStyle(
                fontSize: widget.fontSize * 1.08,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 8.0,
                    color: Eli5Theme.gradientColors.first.withAlpha(77),
                    offset: const Offset(4.0, 4.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
