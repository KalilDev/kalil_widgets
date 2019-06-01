import 'package:flutter/material.dart';

// Texts
const String textFavs = 'Favoritos';
// Tooltips
const String textTooltipDrawer = 'Abrir gaveta';
const String textTooltipBack = 'Voltar';
const String textTooltipFav = 'Adicionar aos favoritos';
const String textTooltipTextSizeLess = 'Diminuir tamanho do texto';
const String textTooltipTextSizePlus = 'Aumentar tamanho do texto';

// Material Guidelines
Color getTextColor(double percent, {Color bg, Color main}) =>
    Color.alphaBlend(main.withAlpha((255 * percent).round()), bg);

const Map<int,int> guidelinesDarkElevation = <int,int>{
  0: 0,
  1: 5,
  2: 7,
  3: 8,
  4: 9,
  6: 11,
  8: 12,
  12: 14,
  16: 15,
  24: 16,
  100: 16
};

// Animation durations
const Duration durationAnimationShort = Duration(milliseconds: 200);
const Duration durationAnimationMedium = Duration(milliseconds: 400);
const Duration durationAnimationLong = Duration(milliseconds: 600);
const Duration durationAnimationRoute = Duration(milliseconds: 600);