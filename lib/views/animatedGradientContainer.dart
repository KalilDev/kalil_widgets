import 'package:flutter/material.dart';

import 'oldGradient.dart' as old;

class AnimatedGradientContainer extends StatefulWidget {
  const AnimatedGradientContainer({
    Key key,
    @required this.isEnabled,
    @required this.child,
    @required this.colors,
    this.height,
    this.width,
    this.trueValues = const [0.6, 1.0],
    this.falseValues = const [0.0, 0.4],
    Duration duration,
  }) : this.duration = (duration != null) ? duration : const Duration(milliseconds: 600),
       super(key: key);

  final bool isEnabled;
  final Widget child;
  final List<Color> colors;
  final double height;
  final double width;
  final List<double> trueValues;
  final List<double> falseValues;
  final Duration duration;

  @override
  _AnimatedGradientContainerState createState() =>
      _AnimatedGradientContainerState();
}

class _AnimatedGradientContainerState extends State<AnimatedGradientContainer>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<old.LinearGradient> _animation;

  bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
        vsync: this, duration: widget.duration);
    Animation curved =
        new CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _animation = new LinearGradientTween(
        begin: old.LinearGradient(
                colors: widget.colors, stops: widget.falseValues),
            end:
            old.LinearGradient(colors: widget.colors, stops: widget.trueValues))
        .animate(curved);
    _controller.value = widget.isEnabled ? 1.0 : 0.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Animation curved =
    new CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _animation = new LinearGradientTween(
        begin: old.LinearGradient(
            colors: widget.colors, stops: widget.falseValues),
        end:
        old.LinearGradient(colors: widget.colors, stops: widget.trueValues))
        .animate(curved);
    if (_isEnabled != widget.isEnabled) {
      widget.isEnabled ? _controller.forward() : _controller.reverse();
      _isEnabled = widget.isEnabled;
    }
    return LayoutBuilder(
      builder: (context, constrains) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            height: widget.height,
            width: widget.width,
            decoration: old.BoxDecoration(
              gradient: _animation.value,
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}

class LinearGradientTween extends Tween<old.LinearGradient> {
  /// Provide a begin and end Gradient. To fade between.
  LinearGradientTween({
    old.LinearGradient begin,
    old.LinearGradient end,
  }) : super(begin: begin, end: end);

  @override
  old.LinearGradient lerp(double t) => old.LinearGradient.lerp(begin, end, t);
}