/// Single source of truth for paths. The route table in `app_router.dart`
class AppRoutes {
  AppRoutes._();

  static const String list = '/';
  static const String create = '/visit/new';

  /// Path pattern used in route *registration*.
  static const String detailPattern = '/visit/:id';
  static String detail(String id) => '/visit/$id';

  /// Photo viewer — deeper segment count than `/visit/:id`, so registration
  /// order vs the detail route is not load-bearing, but the specific route
  /// precedes the parameterized one out of habit.
  static const String photoPattern = '/visit/:id/photo';
  static String photo(String id) => '/visit/$id/photo';

  static const String debug = '/debug';
}
