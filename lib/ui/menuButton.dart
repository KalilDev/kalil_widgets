import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    pop() => Navigator.of(context).pop();
    openDrawer() => Scaffold.of(context).openDrawer();

    return Hero(
      tag: 'MenuButton',
      child: Tooltip(
          message: canPop ? 'Voltar' : 'Abrir gaveta',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                customBorder: CircleBorder(),
                child: Container(
                    height: 60,
                    width: 60,
                    child: Stack(
                      children: <Widget>[
                        Center(
                            child: Container(
                                height: 32.0,
                                width: 32.0,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .backgroundColor
                                        .withAlpha(90),
                                    shape: BoxShape.circle))),
                        Center(child: Icon(canPop ? Icons.arrow_back : Icons.menu)),
                      ],
                    )),
                onTap: () => canPop ? pop() : openDrawer()),
          )),
    );
  }
}
