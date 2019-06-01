import 'package:flutter/material.dart';
import '../constants.dart';

class NonNegativeTween<T extends dynamic> extends Animatable<T> {
  NonNegativeTween({this.begin, this.end});

  T begin;
  T end;

  @protected
  T lerp(double t) {
    assert(begin != null);
    assert(end != null);
    return begin + (end - begin) * t;
  }

  @override
  T transform(double t) {
    final double k = durationAnimationMedium.inMilliseconds/durationAnimationRoute.inMilliseconds;
    if (t == 0.0)
      return begin;
    if (t == 1.0)
      return end;
    if (t < k)
      return lerp(k);
    return lerp(t);
  }

  @override
  String toString() => '$runtimeType($begin \u2192 $end)';
}