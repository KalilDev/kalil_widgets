import 'package:flutter/material.dart';
import 'package:kalil_widgets/constants.dart';

class FadeRoute<T> extends MaterialPageRoute<T> {
  FadeRoute({WidgetBuilder builder, RouteSettings settings, Duration duration})
      : duration = (duration != null) ? duration : durationAnimationRoute,
        super(builder: builder, settings: settings);
  final Duration duration;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final Animation<double> curved = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
    if (animation.status == AnimationStatus.reverse) {
      if (curved.value > 0.9) {
        return ScaleTransition(
            scale: Tween<double>(begin: 0.0, end: 1.0).animate(curved), child: child);
      } else {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0 / 0.9 * 1.0).animate(curved),
          child: ScaleTransition(
              scale: Tween<double>(begin: 0.0, end: 1.0).animate(curved), child: child),
        );
      }
    }
    return FadeTransition(opacity: curved, child: child);
  }
}
