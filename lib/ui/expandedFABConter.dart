import 'package:flutter/material.dart';
import '../constants.dart';
import 'animatedGradientContainer.dart';
import 'blurOverlay.dart';

class ExpandedFABCounter extends StatelessWidget {
  ExpandedFABCounter({Key key,
    @required this.counter,
    @required this.isEnabled,
    @required this.isBlurred,
    this.onPressed})
      : super(key: key);

  final int counter;
  final bool isBlurred;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = Theme
        .of(context)
        .textTheme
        .title
        .copyWith(
        color: getTextColor(0.87, bg: Theme
            .of(context)
            .colorScheme
            .background, main: Theme
            .of(context)
            .colorScheme
            .onSecondary));
    return Material(
      color: Colors.transparent,
      elevation: 16.0,
      shape: StadiumBorder(),
      child: BlurOverlay.roundedRect(
        enabled: isBlurred,
        radius: 80,
        color: Colors.transparent,
        child: AnimatedGradientContainer(
          colors: isBlurred
              ? <Color>[
            Theme
                .of(context)
                .colorScheme
                .error
                .withAlpha(180),
            Theme
                .of(context)
                .accentColor
                .withAlpha(150)
          ]
              : <Color>[
            Theme
                .of(context)
                .colorScheme
                .error,
            Theme
                .of(context)
                .accentColor
          ],
          isEnabled: isEnabled,
          height: 50,
          child: RawMaterialButton(
              elevation: 0.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(width: 24.0),
                  Icon(
                      isEnabled
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .onSecondary),
                  const SizedBox(width: 8.0),
                  Text(counter.toString(), style: style),
                  const SizedBox(width: 3.0),
                  Text(textFavs, style: style),
                  const SizedBox(width: 24.0),
                ],
              ),
              onPressed: onPressed),
        ),
      ),
    );
  }
}
