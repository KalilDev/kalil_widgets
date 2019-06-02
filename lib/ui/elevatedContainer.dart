import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kalil_widgets/constants.dart';

double alpha(double elevation) {
  if (guidelinesDarkElevation.containsKey(elevation)) {
    return guidelinesDarkElevation[elevation.floor()].toDouble();
  } else {
    final List<double> keyList = <double>[];
    for (int i in guidelinesDarkElevation.keys) {
      keyList.add(i.toDouble());
    }
    keyList.add(elevation);
    keyList.sort();
    final double before = keyList[keyList.indexOf(elevation) - 1];
    final double after = keyList[keyList.indexOf(elevation) + 1];
    final double ratio = (elevation - before) / (after - before);

    const double k = -4;
    final double curvedRatio = 1 - math.pow(math.e, k * ratio);
    // Interpolate between the previous and next value with the curve i want
    return guidelinesDarkElevation[keyList[keyList.indexOf(elevation) - 1]] +
        (guidelinesDarkElevation[keyList[keyList.indexOf(elevation) + 1]] -
                guidelinesDarkElevation[
                    keyList[keyList.indexOf(elevation) - 1]]) *
            curvedRatio;
  }
}

Color materialCompliantElevation(
    {Color bg, Brightness brightness, double elevation}) {
  if (brightness == Brightness.dark) {
    return Color.alphaBlend(
        Colors.white.withAlpha((alpha(elevation) * 2.55).round()), bg);
  } else {
    return bg;
  }
}

class ElevatedContainer extends StatelessWidget {
  ElevatedContainer(
      {Key key,
      this.alignment,
      this.padding,
      double width,
      double height,
      BoxConstraints constraints,
      this.margin,
      this.transform,
      this.child,
      this.backgroundColor,
      BorderRadius borderRadius,
      Color elevatedColor,
      @required this.elevation})
      : assert(margin == null || margin.isNonNegative),
        assert(padding == null || padding.isNonNegative),
        assert(constraints == null || constraints.debugAssertIsValid()),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints,
        elevatedColor =
            elevatedColor != null ? elevatedColor : const Color(0x50000000),
        borderRadius =
            borderRadius != null ? borderRadius : BorderRadius.circular(20.0),
        super(key: key);

  final Widget child;
  final double elevation;
  final Color backgroundColor;
  final Color elevatedColor;
  final BoxConstraints constraints;
  final Alignment alignment;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Matrix4 transform;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: constraints,
      alignment: alignment,
      transform: transform,
      margin: margin,
      child: _ElevationShadow(
        borderRadius: borderRadius,
        elevation: elevation,
        backgroundColor: backgroundColor,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: materialCompliantElevation(
                  bg: Theme.of(context).backgroundColor,
                  brightness: Theme.of(context).brightness,
                  elevation: elevation)),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class _ElevationShadow extends StatelessWidget {
  const _ElevationShadow({
    Key key,
    @required this.borderRadius,
    @required this.elevation,
    @required this.backgroundColor,
    @required this.child,
  }) : super(key: key);

  final BorderRadius borderRadius;
  final double elevation;
  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark)
      return child;
    return PhysicalShape(
      clipper: ShapeBorderClipper(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        textDirection: Directionality.of(context),
      ),
      clipBehavior: Clip.none,
      elevation: elevation,
      color: backgroundColor ?? Theme.of(context).backgroundColor,
      shadowColor: const Color(0xFF000000),
      child: _ShapeBorderPaint(
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          borderOnForeground: false,
          child: child),
    );
  }
}

class _ShapeBorderPaint extends StatelessWidget {
  const _ShapeBorderPaint({
    @required this.child,
    @required this.shape,
    this.borderOnForeground = true,
  });

  final Widget child;
  final ShapeBorder shape;
  final bool borderOnForeground;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      child: child,
      painter: borderOnForeground
          ? null
          : _ShapeBorderPainter(shape, Directionality.of(context)),
      foregroundPainter: borderOnForeground
          ? _ShapeBorderPainter(shape, Directionality.of(context))
          : null,
    );
  }
}

class _ShapeBorderPainter extends CustomPainter {
  _ShapeBorderPainter(this.border, this.textDirection);
  final ShapeBorder border;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    border.paint(canvas, Offset.zero & size, textDirection: textDirection);
  }

  @override
  bool shouldRepaint(_ShapeBorderPainter oldDelegate) {
    return oldDelegate.border != border;
  }
}
