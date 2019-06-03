import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kalil_widgets/constants.dart';

class AnimatedGradientContainer extends ImplicitlyAnimatedWidget {
  AnimatedGradientContainer({
    Key key,
    @required bool isEnabled,
    this.child,
    @required this.colors,
    double height,
    double width,
    BoxConstraints constraints,
    List<double> trueValues = const <double>[0.6, 1.0],
    List<double> falseValues = const <double>[0.0, 0.4],
    Duration duration,
  }) : values = isEnabled ? trueValues : falseValues,
        constraints =
        (width != null || height != null)
            ? constraints?.tighten(width: width, height: height)
            ?? BoxConstraints.tightFor(width: width, height: height)
            : constraints,
        super(key: key, duration: (duration != null) ? duration : durationAnimationLong);

  final Widget child;
  final List<Color> colors;
  final List<double> values;
  final BoxConstraints constraints;

  @override
  _AnimatedGradientContainerState createState() =>
      _AnimatedGradientContainerState();
}

class _AnimatedGradientContainerState extends AnimatedWidgetBaseState<AnimatedGradientContainer>
    with TickerProviderStateMixin {

  _LinearGradientTween _gradient;
  BoxConstraintsTween _constraints;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _gradient = visitor(_gradient, LinearGradient(colors: widget.colors, stops: widget.values), (dynamic value) => _LinearGradientTween(begin: value));
    _constraints = visitor(_constraints, widget.constraints, (dynamic value) => BoxConstraintsTween(begin: value));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: _constraints?.evaluate(animation),
      decoration: BoxDecoration(
        gradient: _gradient?.evaluate(animation),
      ),
      child: widget.child,
    );
  }
}

class _LinearGradientTween extends Tween<LinearGradient> {
  /// Provide a begin and end Gradient. To fade between.
  _LinearGradientTween({
    LinearGradient begin,
    LinearGradient end,
  }) : super(begin: begin, end: end);

  @override
  LinearGradient lerp(double t) {
    assert(t != null);
    if (begin == null && end == null)
      return null;
    if (begin == null)
      return end.scale(t);
    if (end == null)
      return begin.scale(1.0 - t);
    final _ColorsAndStops interpolated =
    _interpolateColorsAndStops(begin.colors, begin.stops, end.colors, end.stops, t);
    return LinearGradient(
      begin: AlignmentGeometry.lerp(begin.begin, end.begin, t),
      end: AlignmentGeometry.lerp(begin.end, end.end, t),
      colors: interpolated.colors,
      stops: interpolated.stops,
      tileMode: t < 0.5
          ? begin.tileMode
          : end.tileMode,
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
