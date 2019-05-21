import 'package:flutter/material.dart';

class FadeRoute<T> extends MaterialPageRoute<T> {
  final Duration duration;
  FadeRoute({WidgetBuilder builder, RouteSettings settings, Duration duration})
      : this.duration = (duration != null) ? duration : Duration(milliseconds: 600),
        super(builder: builder, settings: settings);

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    Animation<double> curved =
    new CurvedAnimation(parent: animation, curve: Curves.easeInOut);
    if (animation.status == AnimationStatus.reverse) {
      if (curved.value > 0.9) {
        return ScaleTransition(
            scale: Tween(begin: 0.0, end: 1.0).animate(curved), child: child);
      } else {
        return FadeTransition(
          opacity: Tween(begin: 0.0, end: 1.0 / 0.9 * 1.0).animate(curved),
          child: ScaleTransition(
              scale: Tween(begin: 0.0, end: 1.0).animate(curved), child: child),
        );
      }
    }
    return FadeTransition(opacity: curved, child: child);
  }
}