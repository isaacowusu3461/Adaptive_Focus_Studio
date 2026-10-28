
import 'package:flutter/material.dart';

class AnimatedFocusIndicator extends StatefulWidget {
  final bool isActive;
  final bool reduceMotion;
  final double size;

  const AnimatedFocusIndicator({
    super.key,
    required this.isActive,
    required this.reduceMotion,
    this.size = 64,
  });

  @override
  State<AnimatedFocusIndicator> createState() =>
      _AnimatedFocusIndicatorState();
}

class _AnimatedFocusIndicatorState
    extends State<AnimatedFocusIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1.06),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 1),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant AnimatedFocusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isActive != widget.isActive ||
        oldWidget.reduceMotion != widget.reduceMotion) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (!widget.isActive || widget.reduceMotion) {
      _controller.stop();
      _controller.value = 0;
      return;
    }

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Semantics(
      label: widget.isActive
          ? 'Focus session is active'
          : 'Focus session is inactive',
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: Icon(
            widget.isActive
                ? Icons.psychology
                : Icons.self_improvement,
            color: color,
            size: widget.size * 0.45,
          ),
        ),
      ),
    );
  }
}
