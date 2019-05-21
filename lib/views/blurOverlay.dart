import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kalil_widgets/constants.dart';

class BlurOverlay extends StatefulWidget {
  final Widget child;
  final int radius;
  final bool enabled;
  final double intensity;
  final Color color;
  final Duration duration;

  BlurOverlay({Key key,
    @required this.child,
    this.radius = 0,
    @required this.enabled,
    this.intensity = 1.0,
    this.color,
    Duration duration})
      : this.duration = (duration != null) ? duration : Constants.durationAnimationMedium,
       super(key: key);

  @override
  _BlurOverlayState createState() => _BlurOverlayState();
}

class _BlurOverlayState extends State<BlurOverlay>
    with TickerProviderStateMixin {
  bool _wasEnabled;
  AnimationController _blurController;
  Animation<double> _animation;
  double _blur;

  @override
  void initState() {
    _blurController = new AnimationController(
        vsync: this, duration: widget.duration);
    _animation =
    new CurvedAnimation(parent: _blurController, curve: Curves.easeInOut);
    _wasEnabled = widget.enabled;
    _blurController.value = widget.enabled ? 1.0 : 0.0;
    _blur = _blurController.value;
    _blurController.addListener(() => setState(() => _blur = _animation.value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_wasEnabled != widget.enabled) {
      setState(() => _wasEnabled = widget.enabled);
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
        _blur);
    final _overlayColor = widget.color ?? defaultColor;
    final sigma = 4 * widget.intensity * _blur;

    switch (widget.radius) {
      case 0:
        return ClipRect(
            clipBehavior: Clip.antiAlias,
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                child: Container(
                    color: _overlayColor, child: widget.child)));
        break;
      case 100:
        return ClipOval(
            clipBehavior: Clip.antiAlias,
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                child: Container(
                    color: _overlayColor, child: widget.child)));
        break;
    }

    return ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius.toDouble()),
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: Container(
                color: _overlayColor, child: widget.child)));
  }
}
