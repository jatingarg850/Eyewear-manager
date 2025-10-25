import 'package:flutter/material.dart';

/// AnimatedCounter widget animates number counting from 0 to target value
/// Supports prefix and suffix (e.g., currency symbols)
/// Uses smooth easing curve for natural animation
class AnimatedCounter extends StatefulWidget {
  final double value;
  final Duration duration;
  final String prefix;
  final String suffix;
  final int decimalPlaces;
  final TextStyle? textStyle;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 1000),
    this.prefix = '',
    this.suffix = '',
    this.decimalPlaces = 0,
    this.textStyle,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If value changed, animate from previous value to new value
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;

      _controller.duration = widget.duration;
      _animation = Tween<double>(
        begin: _previousValue,
        end: widget.value,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );

      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    if (widget.decimalPlaces == 0) {
      return value.toInt().toString();
    } else {
      return value.toStringAsFixed(widget.decimalPlaces);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix}${_formatNumber(_animation.value)}${widget.suffix}',
          style: widget.textStyle,
        );
      },
    );
  }
}
