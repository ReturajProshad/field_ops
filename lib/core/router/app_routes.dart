/// Single source of truth for paths. The route table in `app_router.dart`
class AppRoutes {
  AppRoutes._();

  static const String list = '/';
  static const String create = '/visit/new';

  /// Path pattern used in route *registration*.
  static const String detailPattern = '/visit/:id';
  static String detail(String id) => '/visit/$id';
}
