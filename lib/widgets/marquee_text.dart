import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double availableWidth;
  final Duration scrollDuration;
  final Duration pauseDuration;
  final CrossAxisAlignment crossAxisAlignment;

  const MarqueeText({
    Key? key,
    required this.text,
    required this.style,
    required this.availableWidth,
    this.scrollDuration = const Duration(seconds: 6),
    this.pauseDuration = const Duration(seconds: 2),
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : super(key: key);

  @override
  _MarqueeTextState createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _textWidth = 0;
  bool _needsScroll = false;
  double _scrollDistance = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(widget.pauseDuration, () {
          if (mounted) _controller.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        Future.delayed(widget.pauseDuration, () {
          if (mounted) _controller.forward();
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureText());
  }

  @override
  void didUpdateWidget(MarqueeText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text || old.style != widget.style) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureText());
    }
  }

  void _measureText() {
    final tp = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final textW = tp.width;
    final available = widget.availableWidth;

    if (textW > available && available > 0) {
      _needsScroll = true;
      _scrollDistance = textW - available;
      _controller.duration = Duration(
        milliseconds:
            (widget.scrollDuration.inMilliseconds * (_scrollDistance / 200))
                .round()
                .clamp(800, 12000),
      );
      _controller.reset();
      Future.delayed(widget.pauseDuration, () {
        if (mounted && _needsScroll) _controller.forward();
      });
    } else {
      _needsScroll = false;
      _controller.reset();
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_needsScroll) {
      return SizedBox(
        width: widget.availableWidth,
        child: Text(
          widget.text,
          style: widget.style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      );
    }

    return ClipRRect(
      child: SizedBox(
        width: widget.availableWidth,
        height: widget.style.fontSize != null
            ? widget.style.fontSize! * 1.4
            : null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final offset = _controller.value * _scrollDistance;
            return Transform.translate(
              offset: Offset(-offset, 0),
              child: child,
            );
          },
          child: Text(
            widget.text,
            style: widget.style,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }
}
