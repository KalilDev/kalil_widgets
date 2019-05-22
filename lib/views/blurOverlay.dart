import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kalil_widgets/constants.dart';

enum Shape { Oval, RRect, Rect }
class BlurOverlay extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final double intensity;
  final Color color;
  final Duration duration;
  final double radius;
  final Shape shape;

  BlurOverlay({Key key,
    @required this.child,
    @required this.enabled,
    this.intensity = 1.0,
    this.color,
    Duration duration})
      : this.duration = (duration != null) ? duration : Constants.durationAnimationMedium,
        this.shape = Shape.Rect,
        this.radius = null,
        super(key: key);

  BlurOverlay.roundedRect({Key key,
    @required this.child,
    @required double radius,
    @required this.enabled,
    this.intensity = 1.0,
    this.color,
    Duration duration})
      : this.duration = (duration != null) ? duration : Constants.durationAnimationMedium,
        this.shape = Shape.RRect,
        this.radius = radius,
        super(key: key);

  BlurOverlay.circle({Key key,
    @required this.child,
    @required this.enabled,
    this.intensity = 1.0,
    this.color,
    Duration duration})
      : this.duration = (duration != null) ? duration : Constants.durationAnimationMedium,
        this.shape = Shape.Oval,
        this.radius = null,
        super(key: key);

  @override
  _BlurOverlayState createState() => _BlurOverlayState();
}

class _BlurOverlayState extends State<BlurOverlay>
    with TickerProviderStateMixin {
  bool _wasEnabled;
  AnimationController _blurController;
  Animation<double> _animation;

  @override
  void initState() {
    _blurController = new AnimationController(
        vsync: this, duration: widget.duration);
    _animation =
    new CurvedAnimation(parent: _blurController, curve: Curves.easeInOut);
    _wasEnabled = widget.enabled;
    _blurController.value = widget.enabled ? 1.0 : 0.0;
    super.initState();
  }

  @override
  void dispose() {
    _blurController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _animation, builder: (context, child) {
      if (_wasEnabled != widget.enabled) {
        _wasEnabled = widget.enabled;
        widget.enabled ? _blurController.forward() : _blurController.reverse();
      }
      final Color defaultColor = Color.lerp(
          Theme
              .of(context)
              .backgroundColor
              .withAlpha(170),
          Theme
              .of(context)
              .backgroundColor
              .withAlpha(120),
          _animation.value);
      final _overlayColor = widget.color ?? defaultColor;
      final sigma = 4 * widget.intensity * _animation.value;

      switch (widget.shape) {
        case Shape.Rect:
          return ClipRect(
              clipBehavior: Clip.antiAlias,
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                  child: Container(
                      color: _overlayColor, child: widget.child)));
          break;
        case Shape.Oval:
          return ClipOval(
              clipBehavior: Clip.antiAlias,
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                  child: Container(
                      color: _overlayColor, child: widget.child)));
          break;
        case Shape.RRect:
          return ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius.toDouble()),
              clipBehavior: Clip.antiAlias,
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                  child: Container(
                      color: _overlayColor, child: widget.child)));
          break;
      }
    });
  }
}
