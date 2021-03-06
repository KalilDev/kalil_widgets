import 'dart:async';

import 'package:flutter/material.dart';
import '../constants.dart';
import 'animatedGradientContainer.dart';
import 'blurOverlay.dart';
import 'nonNegativeTween.dart';

class BiStateFAB extends StatefulWidget {
  BiStateFAB(
      {@required this.onPressed,
        @required this.isBlurred,
        @required this.isEnabled,
        IconData enabledIcon,
        IconData disabledIcon,
        this.enabledColor,
        this.disabledColor,
        this.iconColor})
      : icons = <IconData>[
    (enabledIcon != null) ? enabledIcon : Icons.favorite,
    (disabledIcon != null) ? disabledIcon : Icons.favorite_border
  ];

  final VoidCallback onPressed;
  final bool isBlurred;
  final bool isEnabled;
  final List<IconData> icons;
  final Color disabledColor;
  final Color enabledColor;
  final Color iconColor;

  @override
  _BiStateFABState createState() => _BiStateFABState();
}

class _BiStateFABState extends State<BiStateFAB> with TickerProviderStateMixin {
  AnimationController _scaleController;
  AnimationController _iconController;
  Animation<double> _scale;
  Animation<double> _iconScale;
  bool disposed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
        duration: durationAnimationRoute +
            durationAnimationMedium,
        vsync: this);
    _iconController = AnimationController(
        duration: durationAnimationMedium, vsync: this);

    _scale = NonNegativeTween<double>(begin: animationStart, end: 1.0).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut));
    _iconScale = CurvedAnimation(parent: _iconController, curve: Curves.easeInOut);

    _scaleController.forward();
    _iconController.value = 1.0;
    Future<void>.delayed(
        durationAnimationRoute + durationAnimationMedium,
        () => _iconController.notifyStatusListeners(AnimationStatus.completed));
  }

  @override
  void dispose() {
    _iconController.dispose();
    _scaleController.dispose();
    disposed = true;
    super.dispose();
  }

  double get animationStart =>
      0 -
      (durationAnimationRoute.inMilliseconds /
          durationAnimationMedium.inMilliseconds);

  @override
  Widget build(BuildContext context) {
    if (widget.isEnabled) {
      _iconController.notifyStatusListeners(AnimationStatus.completed);
    }
    _iconScale.addStatusListener((AnimationStatus status) {
      if(!disposed) {
        if (widget.isEnabled) {
          if (status == AnimationStatus.completed) {
            _iconController.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _iconController.forward();
          }
        } else {
          _iconController.animateTo(1.0);
        }
      }
    });

    final Color enabledColor = widget?.enabledColor ?? Theme.of(context).colorScheme.error;
    final Color disabledColor = widget?.disabledColor ?? Theme.of(context).primaryColor;
    final Color iconColor = widget?.iconColor ?? Theme.of(context).colorScheme.onSecondary;
    return ScaleTransition(
      scale: _scale,
      child: Material(
        color: Colors.transparent,
        elevation: 16.0,
        child: BlurOverlay.circle(
          enabled: widget.isBlurred,
          child: AnimatedGradientContainer(
            colors: widget.isBlurred
                ? <Color>[
                    Theme.of(context).backgroundColor.withAlpha(150),
                    disabledColor.withAlpha(150)
                  ]
                : <Color>[
                    Theme.of(context).backgroundColor,
                    disabledColor
                  ],
            trueValues: const <double>[1.0, 2.0],
            falseValues: const <double>[-1.0, 0.0],
            isEnabled: widget.isEnabled,
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              child: ScaleTransition(
                scale: widget.isEnabled
                    ? Tween<double>(begin: 0.7, end: 1.3).animate(_iconScale)
                    : Tween<double>(
                            begin: Tween<double>(begin: 0.7, end: 1.3)
                                .animate(_iconScale)
                                .value,
                            end: 1.0)
                        .animate(_iconScale),
                child: Icon(
                    widget.isEnabled ? widget.icons[0] : widget.icons[1],
                    color: widget.isEnabled
                        ? enabledColor
                        : iconColor)
              ),
              onPressed: widget.onPressed,
              tooltip: textTooltipFav,
            ),
          ),
        ),
      ),
    );
  }
}
