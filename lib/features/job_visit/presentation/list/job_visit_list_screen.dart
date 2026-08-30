import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/job_visit_list_tile.dart';
import '../providers/job_visit_providers.dart';

class JobVisitListScreen extends ConsumerWidget {
  const JobVisitListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(sortedJobVisitsProvider);
    final sortMode = ref.watch(visitSortModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Visits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report_outlined),
            tooltip: 'Debug menu',
            onPressed: () => context.push(AppRoutes.debug),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SegmentedButton<VisitSortMode>(
              segments: const [
                ButtonSegment(
                  value: VisitSortMode.byStatus,
                  label: Text('By status'),
                ),
                ButtonSegment(
                  value: VisitSortMode.bySyncState,
                  label: Text('By sync state'),
                ),
              ],
              selected: {sortMode},
              onSelectionChanged: (selection) {
                ref.read(visitSortModeProvider.notifier).state =
                    selection.first;
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.create),
        child: const Icon(Icons.add),
      ),
      body: visitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const EmptyState(
          icon: Icons.error_outline,
          message: 'Could not load visits.',
        ),
        data: (visits) => visits.isEmpty
            ? const EmptyState(
                icon: Icons.location_off_outlined,
                message:
                    'No job visits yet.\nCreate your first one to get started.',
              )
            : ListView.builder(
                itemCount: visits.length,
                itemBuilder: (context, index) {
                  final visit = visits[index];
                  return JobVisitListTile(
                    visit: visit,
                    onTap: () {
                      developer.log("id=${visit.id}");
                      context.push(AppRoutes.detail(visit.id));
                    },
                  );
                },
              ),
      ),
    );
  }
}
