import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kalil_widgets/constants.dart';

enum Shape { Oval, RRect, Rect }
class BlurOverlay extends ImplicitlyAnimatedWidget {
  BlurOverlay({Key key,
    @required this.child,
    @required bool enabled,
    double intensity = 1.0,
    this.color,
    Duration duration})
      : duration = duration ?? durationAnimationMedium,
        shape = Shape.Rect,
        radius = null,
        intensity = enabled ? intensity : 0.0,
        super(key: key, duration: duration ?? durationAnimationMedium);

  BlurOverlay.roundedRect({Key key,
    @required this.child,
    @required bool enabled,
    double intensity = 1.0,
    this.color,
    @required this.radius,
    Duration duration})
      : duration = duration ?? durationAnimationMedium,
        shape = Shape.RRect,
        intensity = enabled ? intensity : 0.0,
        super(key: key, duration: duration ?? durationAnimationMedium);

  BlurOverlay.circle({Key key,
    @required this.child,
    @required bool enabled,
    double intensity = 1.0,
    this.color,
    Duration duration})
      : duration = duration ?? durationAnimationMedium,
        shape = Shape.Oval,
        radius = null,
        intensity = enabled ? intensity : 0.0,
        super(key: key, duration: duration ?? durationAnimationMedium);

  final Duration duration;
  final Widget child;
  final double intensity;
  final Color color;
  final double radius;
  final Shape shape;

  @override
  _BlurOverlayState createState() => _BlurOverlayState();
}

class _BlurOverlayState extends AnimatedWidgetBaseState<BlurOverlay> {
  Tween<double> _sigma;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _sigma = visitor(_sigma, widget.intensity * 4, (dynamic value) => Tween<double>(begin: value));
  }

  @override
  Widget build(BuildContext context) {
      final double sigma = _sigma.evaluate(animation);
      final Color overlayColor = widget.color ?? Theme
          .of(context)
          .backgroundColor
          .withAlpha(190);

      switch (widget.shape) {
        case Shape.Rect:
          return ClipRect(
              clipBehavior: Clip.antiAlias,
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                  child: AnimatedContainer(
                      duration: widget.duration, color: overlayColor, child: widget.child)));
          break;
        case Shape.Oval:
          return ClipOval(
              clipBehavior: Clip.antiAlias,
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                  child: AnimatedContainer(
                      duration: widget.duration, color: overlayColor, child: widget.child)));
          break;
        case Shape.RRect:
          return ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius.toDouble()),
              clipBehavior: Clip.antiAlias,
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                  child: AnimatedContainer(
                      duration: widget.duration, color: overlayColor, child: widget.child)));
          break;
        default:
          return widget.child;
      }
  }
}
