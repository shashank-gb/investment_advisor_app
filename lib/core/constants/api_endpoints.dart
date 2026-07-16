/// REST API endpoint paths. All paths are relative to [AppConfig.apiBaseUrl].
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String profile = '/user/profile';

  // Home
  static const String fundCategories = '/funds/categories';
  static const String topFunds = '/funds/top-performing';
  static const String marketIndexes = '/market/indexes';
  static const String blogs = '/content/blogs';
  static const String ads = '/content/ads';

  // Portfolio (BSE Star MF integration via backend)
  static const String portfolio = '/portfolio/holdings';
  static const String portfolioSummary = '/portfolio/summary';

  // Watchlist
  static const String watchlistGroups = '/watchlist/groups';
  static const String watchlistFunds = '/watchlist/funds';
  static const String fundSearch = '/funds/search';

  // App design (remote theme/config)
  static const String appDesign = '/config/design';
}
