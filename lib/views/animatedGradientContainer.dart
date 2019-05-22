import 'package:flutter/material.dart';
import 'package:kalil_widgets/constants.dart';
import 'dart:ui';

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
  }) : this.duration = (duration != null) ? duration : Constants.durationAnimationLong,
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
  Animation<LinearGradient> _animation;

  bool _isEnabled;

  List<Color> _oldColors;
  AnimationController _onChangeController;
  Animation<double> _onChangeAnim;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
        vsync: this, duration: widget.duration);
    Animation curved =
        new CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _animation = new LinearGradientTween(
        begin: LinearGradient(
                colors: widget.colors, stops: widget.falseValues),
            end:
            LinearGradient(colors: widget.colors, stops: widget.trueValues))
        .animate(curved);
    _controller.value = widget.isEnabled ? 1.0 : 0.0;

    _oldColors = widget.colors;
    _onChangeController = new AnimationController(vsync: this, duration: widget.duration);
    _onChangeAnim = new CurvedAnimation(parent: _onChangeController, curve: Curves.easeInOut);
    _onChangeController.addListener(() {
      if (_controller.status == AnimationStatus.completed || _controller.status == AnimationStatus.dismissed) _oldColors = widget.colors;
    });
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
        begin: LinearGradient(
            colors: _oldColors, stops: widget.falseValues),
        end:
        LinearGradient(colors: _oldColors, stops: widget.trueValues))
        .animate(curved);
    if (_isEnabled != widget.isEnabled) {
      widget.isEnabled ? _controller.forward() : _controller.reverse();
      _isEnabled = widget.isEnabled;
    }
    if (_oldColors != widget.colors) {
      _onChangeController.value = 0.0;
      _onChangeController.forward();
    }
    return LayoutBuilder(
      builder: (context, constrains) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => AnimatedBuilder(
            animation: _onChangeAnim,
              builder: (context, child) => Container(
              height: widget.height,
              width: widget.width,
              decoration: BoxDecoration(
                gradient: LinearGradientTween(begin: _animation.value, end: LinearGradient(colors: widget.colors, stops: _animation.value.stops)).lerp(_onChangeAnim.value),
              ),
              child: widget.child,
          )
        )
      ),
    );
  }
}

class LinearGradientTween extends Tween<LinearGradient> {
  /// Provide a begin and end Gradient. To fade between.
  LinearGradientTween({
    LinearGradient begin,
    LinearGradient end,
  }) : super(begin: begin, end: end);

  @override
  LinearGradient lerp(double t) {
    assert(t != null);
    if (begin == null && end == null) return null;
    if (begin == null) return end.scale(t);
    if (end == null) return begin.scale(1.0 - t);
    final _ColorsAndStops interpolated =
    _interpolateColorsAndStops(begin.colors, begin.stops, end.colors, end.stops, t);
    return LinearGradient(
      begin: AlignmentGeometry.lerp(begin.begin, end.begin, t),
      end: AlignmentGeometry.lerp(begin.end, end.end, t),
      colors: interpolated.colors,
      stops: interpolated.stops,
      tileMode: t < 0.5
          ? begin.tileMode
          : end.tileMode, // TODO(ianh): interpolate tile mode
    );
  }
}

class _ColorsAndStops {
  _ColorsAndStops(this.colors, this.stops);

  final List<Color> colors;
  final List<double> stops;
}

_ColorsAndStops _interpolateColorsAndStops(List<Color> aColors,
    List<double> aStops, List<Color> bColors, List<double> bStops, double t) {
  assert(aColors.length == bColors.length,
  'Cannot interpolate between two gradients with a different number of colors.');
  assert((aStops == null && aColors.length == 2) ||
      (aStops != null && aStops.length == aColors.length));
  assert((bStops == null && bColors.length == 2) ||
      (bStops != null && bStops.length == bColors.length));
  final List<Color> interpolatedColors = <Color>[];
  for (int i = 0; i < aColors.length; i += 1)
    interpolatedColors.add(Color.lerp(aColors[i], bColors[i], t));
  List<double> interpolatedStops;
  if (aStops != null || bStops != null) {
    aStops ??= const <double>[0.0, 1.0];
    bStops ??= const <double>[0.0, 1.0];
    assert(aStops.length == bStops.length);
    interpolatedStops = <double>[];
    for (int i = 0; i < aStops.length; i += 1)
      interpolatedStops
          .add(lerpDouble(aStops[i], bStops[i], t).clamp(0.0, 1.0));
  }
  return _ColorsAndStops(interpolatedColors, interpolatedStops);
}
