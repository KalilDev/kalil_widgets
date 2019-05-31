class Constants {
  // Texts
  // Tooltips
  static const String textTooltipDrawer = 'Abrir gaveta';
  static const String textTooltipBack = 'Voltar';
  static const String textTooltipFav = 'Adicionar aos favoritos';
  static const String textTooltipTextSizeLess = 'Diminuir tamanho do texto';
  static const String textTooltipTextSizePlus = 'Aumentar tamanho do texto';

  // Material Guidelines
  static const Map<int,int> guidelinesDarkElevation = <int,int>{
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
  static const Duration durationAnimationShort = Duration(milliseconds: 200);
  static const Duration durationAnimationMedium = Duration(milliseconds: 400);
  static const Duration durationAnimationLong = Duration(milliseconds: 600);
  static const Duration durationAnimationRoute = Duration(milliseconds: 600);
}