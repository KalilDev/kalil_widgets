import 'package:flutter/material.dart';
import 'package:kalil_widgets/constants.dart';

class SlideRoute<T> extends MaterialPageRoute<T> {
  final Duration duration;
  SlideRoute({WidgetBuilder builder, RouteSettings settings, Duration duration})
      : this.duration = (duration != null) ? duration : Constants.durationAnimationRoute,
        super(builder: builder, settings: settings);

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    Animation<double> curved =
    new CurvedAnimation(parent: animation, curve: Curves.easeInOut);
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    );
  }
}
