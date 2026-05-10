import 'dart:math';
import 'package:flutter/material.dart';

class EqualizerAnimation extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final int barCount;
  final double width;
  final double height;

  const EqualizerAnimation({
    Key? key,
    required this.isPlaying,
    this.color = const Color(0xFF1DB954),
    this.barCount = 4,
    this.width = 20,
    this.height = 16,
  }) : super(key: key);

  @override
  _EqualizerAnimationState createState() => _EqualizerAnimationState();
}

class _EqualizerAnimationState extends State<EqualizerAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initControllers();
    if (widget.isPlaying) _startAnimation();
  }

  void _initControllers() {
    _controllers = List.generate(widget.barCount, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 250 + _random.nextInt(350)),
      );
    });
    _animations = _controllers.map((c) {
      return Tween<double>(
        begin: 0.15,
        end: 1.0,
      ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
    }).toList();
  }

  void _startAnimation() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  void _stopAnimation() {
    for (final c in _controllers) {
      if (c.isAnimating) {
        c.animateTo(0.2, duration: const Duration(milliseconds: 300));
      }
    }
  }

  @override
  void didUpdateWidget(EqualizerAnimation old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying != old.isPlaying) {
      widget.isPlaying ? _startAnimation() : _stopAnimation();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barWidth =
        (widget.width - (widget.barCount - 1) * 2) / widget.barCount;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (i) {
          return AnimatedBuilder(
            animation: _animations[i],
            builder: (_, __) => Container(
              width: barWidth,
              height: widget.height * _animations[i].value,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
