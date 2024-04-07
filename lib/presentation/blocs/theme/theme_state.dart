enum Themes { kg, primary_1, primary_3, primary_5, preparatory, secondary }

class ThemeState {
  final Themes theme;

  ThemeState(this.theme);
}

class InitialTheme extends ThemeState {
  InitialTheme() : super(Themes.kg);
}
