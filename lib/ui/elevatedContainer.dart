import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kalil_widgets/constants.dart';

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

  double get alpha {
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
          (guidelinesDarkElevation[
          keyList[keyList.indexOf(elevation) + 1]] -
              guidelinesDarkElevation[
              keyList[keyList.indexOf(elevation) - 1]]) *
              curvedRatio;
    }
  }

  BoxDecoration materialCompliantElevation({Color bg, Brightness brightness}) {
    if (brightness == Brightness.dark) {
      return BoxDecoration(
          borderRadius: borderRadius,
          color: Color.alphaBlend(
              Colors.white.withAlpha((alpha * 2.55).round()), bg));
    } else {
      return BoxDecoration(borderRadius: borderRadius, color: bg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: constraints,
      alignment: alignment,
      transform: transform,
      margin: margin,
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        color: Colors.transparent,
        elevation: elevation,
        child: Container(
          decoration: materialCompliantElevation(
              bg: backgroundColor != null
                  ? backgroundColor
                  : Theme.of(context).backgroundColor,
              brightness: Theme.of(context).brightness),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}