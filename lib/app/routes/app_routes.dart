/// Named routes. Pages are registered in [AppPages].
abstract class Routes {
  Routes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String search = '/search';
  static const String forecast = '/forecast';
  static const String weatherDetails = '/weather-details';
  static const String favorites = '/favorites';
  static const String map = '/map';
  static const String alerts = '/alerts';
  static const String settings = '/settings';
  static const String about = '/settings/about';
  static const String notFound = '/not-found';
}
