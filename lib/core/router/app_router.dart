import 'package:go_router/go_router.dart';

import '../../features/job_visit/presentation/create/create_job_visit_screen.dart';
import '../../features/job_visit/presentation/debug/debug_menu_screen.dart';
import '../../features/job_visit/presentation/detail/job_visit_detail_screen.dart';
import '../../features/job_visit/presentation/list/job_visit_list_screen.dart';
import '../../features/job_visit/presentation/photo/job_visit_photo_viewer_screen.dart';
import 'app_routes.dart';

/// Route list, flat per ui-plan §2. Exposed separately so tests can construct
/// fresh [GoRouter] instances (a GoRouter holds navigation state; a shared
/// singleton would leak state between test cases).
final List<GoRoute> appRoutes = [
  GoRoute(
    path: AppRoutes.list,
    name: 'jobVisitList',
    builder: (context, state) => const JobVisitListScreen(),
  ),
  GoRoute(
    path: AppRoutes.create,
    name: 'createJobVisit',
    builder: (context, state) => const CreateJobVisitScreen(),
  ),
  GoRoute(
    path: AppRoutes.photoPattern,
    name: 'jobVisitPhoto',
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      return JobVisitPhotoViewerScreen(id: id);
    },
  ),
  GoRoute(
    path: AppRoutes.detailPattern,
    name: 'jobVisitDetail',
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      return JobVisitDetailScreen(id: id);
    },
  ),
  GoRoute(
    path: AppRoutes.debug,
    name: 'debugMenu',
    builder: (context, state) => const DebugMenuScreen(),
  ),
];

/// App-wide router. Order is load-bearing: `/visit/new` MUST precede
/// `/visit/:id`, or `new` matches as the id param. Deep-link targets for
/// Phases 8+ land on `/visit/:id`.
final appRouter = GoRouter(
  initialLocation: AppRoutes.list,
  routes: appRoutes,
);

/// Fresh router for tests (independent navigation state per case).
GoRouter buildTestRouter() =>
    GoRouter(initialLocation: AppRoutes.list, routes: appRoutes);