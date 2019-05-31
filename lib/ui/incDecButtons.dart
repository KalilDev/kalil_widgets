import 'package:flutter/material.dart';
import '../constants.dart';
import 'blurOverlay.dart';
import 'nonNegativeTween.dart';

class IncDecButton extends StatefulWidget {
  const IncDecButton(
      {@required this.isBlurred, @required this.value, @required this.onIncrease, @required this.onDecrease});

  final bool isBlurred;
  final double value;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  _IncDecButtonState createState() => _IncDecButtonState();
}

class _IncDecButtonState extends State<IncDecButton>
    with TickerProviderStateMixin {
  AnimationController _scaleController;
  Animation<double> _scale;

  AnimationController _colorController;
  Animation<double> _color;
  Color _oldColor;
  Color _newColor;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
        duration: Constants.durationAnimationMedium +
            Constants.durationAnimationRoute,
        vsync: this);
    _scale = NonNegativeTween<double>(begin: animationStart, end: 1.0).animate(CurvedAnimation(
        parent: _scaleController, curve: Curves.easeInOut));
    _scaleController.forward();
    _colorController = AnimationController(
      duration: Constants.durationAnimationMedium,
      vsync: this
    );
    _color = CurvedAnimation(parent: _colorController, curve: Curves.easeInOut);
    _colorController.addListener(() {
      if (_colorController.status == AnimationStatus.completed) {
        _colorController.value = 0.0;
        _oldColor = _newColor;
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  double get animationStart =>
      0 -
          (Constants.durationAnimationRoute.inMilliseconds /
          Constants.durationAnimationMedium.inMilliseconds);

  @override
  Widget build(BuildContext context) {
    final Color color = widget.isBlurred
        ? Theme
        .of(context)
        .primaryColor
        .withAlpha(150)
        : Theme
        .of(context)
        .primaryColor;
    if (color != _newColor) {
      _newColor = color;
      if (_oldColor != null) {
        _colorController.forward();
      } else {
        _oldColor = color;
      }
    }
    return ScaleTransition(
      scale: _scale,
      child: Material(
        color: Colors.transparent,
        elevation: 16.0,
        child: BlurOverlay.roundedRect(
          enabled: widget.isBlurred,
          radius: 80,
          child: AnimatedBuilder(
            animation: _color,
            builder: (BuildContext context, _) => Material(
                color: ColorTween(begin: _oldColor, end: color).lerp(_color.value),
                child: Row(children: <Widget>[
                  DecreaseButton(
                      value: widget.value, onDecrease: widget.onDecrease, isInverted: true,),
                  IncreaseButton(
                      value: widget.value, onIncrease: widget.onIncrease, isInverted: true,),
                ]),
              )
          ),
        ),
      ),
    );
  }
}

class IncreaseButton extends StatefulWidget {
  IncreaseButton({@required this.value, @required this.onIncrease, bool isInverted})
      : isInverted = isInverted != null ? isInverted : false;

  final double value;
  final VoidCallback onIncrease;
  final bool isInverted;

  @override
  _IncreaseButtonState createState() => _IncreaseButtonState();
}

class _IncreaseButtonState extends State<IncreaseButton>
    with TickerProviderStateMixin {
  double oldValue;
  AnimationController _plusController;
  Animation<double> _plus;

  @override
  void initState() {
    super.initState();
    _plusController = AnimationController(
        duration: Constants.durationAnimationMedium, vsync: this);
    _plus =
    CurvedAnimation(parent: _plusController, curve: Curves.decelerate)
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.dismissed) {
          _plusController.forward();
        }
      });
    oldValue = widget.value;
    _plusController.value = 1.0;
  }

  @override
  void dispose() {
    _plusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (oldValue != widget.value) {
      if (oldValue < widget.value)
        _plusController.reverse();
      oldValue = widget.value;
    }
    return ScaleTransition(
        child: IconButton(
          icon: Icon(Icons.arrow_upward, color: Theme.of(context).primaryColorBrightness == Brightness.light && widget.isInverted ? Colors.black : Theme.of(context).iconTheme.color),
          onPressed: widget.onIncrease,
          tooltip: Constants.textTooltipTextSizePlus,
        ),
        scale: Tween<double>(begin: 1.3, end: 1.0).animate(_plus));
  }
}

class DecreaseButton extends StatefulWidget {
  DecreaseButton({@required this.value, @required this.onDecrease, bool isInverted})
      : isInverted = isInverted != null ? isInverted : false;

  final double value;
  final VoidCallback onDecrease;
  final bool isInverted;

  @override
  _DecreaseButtonState createState() => _DecreaseButtonState();
}

class _DecreaseButtonState extends State<DecreaseButton>
    with TickerProviderStateMixin {
  double oldValue;
  AnimationController _minusController;
  Animation<double> _minus;

  @override
  void initState() {
    super.initState();
    _minusController = AnimationController(
        duration: Constants.durationAnimationMedium, vsync: this);
    _minus =
    CurvedAnimation(parent: _minusController, curve: Curves.decelerate)
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.dismissed) {
          _minusController.forward();
        }
      });
    oldValue = widget.value;
    _minusController.value = 1.0;
  }

  @override
  void dispose() {
    _minusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (oldValue != widget.value) {
      if (oldValue > widget.value)
        _minusController.reverse();
      oldValue = widget.value;
    }
    return ScaleTransition(
        child: IconButton(
          icon: Icon(Icons.arrow_downward, color: Theme.of(context).primaryColorBrightness == Brightness.light && widget.isInverted ? Colors.black : Theme.of(context).iconTheme.color),
          onPressed: widget.onDecrease,
          tooltip: Constants.textTooltipTextSizeLess,
        ),
        scale: Tween<double>(begin: 0.7, end: 1.0).animate(_minus));
  }
}
