import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/locked_photo_placeholder.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/status_selector.dart';
import '../../../../core/widgets/sync_state_chip.dart';
import '../../domain/entities/job_visit.dart';
import '../../domain/usecases/edit_job_visit.dart';
import '../providers/job_visit_providers.dart';
import '../providers/sync_providers.dart';

class JobVisitDetailScreen extends ConsumerWidget {
  const JobVisitDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitAsync = ref.watch(jobVisitByIdProvider(id));

    return visitAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: EmptyState(
          icon: Icons.error_outline,
          message: 'Something went wrong: $e',
        ),
      ),
      data: (visit) =>
          visit == null ? _NotFoundScreen() : _DetailBody(visit: visit),
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Visit')),
      body: EmptyState(
        icon: Icons.search_off,
        message: 'Visit not found.',
        actionLabel: 'Back to list',
        onAction: () => context.go(AppRoutes.list),
      ),
    );
  }
}

class _DetailBody extends ConsumerStatefulWidget {
  const _DetailBody({required this.visit});

  final JobVisit visit;

  @override
  ConsumerState<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends ConsumerState<_DetailBody> {
  bool _addingPhoto = false;
  bool _updatingLocation = false;

  JobVisit get _visit => widget.visit;

  Future<void> _edit(JobVisitPatch patch) async {
    await ref.read(editJobVisitProvider).call(current: _visit, patch: patch);
    // Online app: push the edit through immediately. Best-effort, guarded.
    unawaited(ref.read(autoSyncProvider)());
    // Rebuild follows from the reactive stream; nothing else to do.
  }

  Future<void> _addOrReplacePhoto() async {
    setState(() => _addingPhoto = true);
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final savedPath = await ref.read(photoStoreProvider).save(picked.path);
        if (savedPath != null) {
          await _edit(JobVisitPatch(photoPath: savedPath));
        }
      }
    } finally {
      if (mounted) setState(() => _addingPhoto = false);
    }
  }

  Future<void> _updateLocation() async {
    setState(() => _updatingLocation = true);
    try {
      final position = await ref.read(currentLocationProvider).fetch();
      if (position != null) {
        await _edit(JobVisitPatch(gpsLat: position.lat, gpsLng: position.lng));
      }
    } finally {
      if (mounted) setState(() => _updatingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visit = _visit;
    final hasGps = visit.gpsLat != null && visit.gpsLng != null;
    final hasPhoto = visit.photoPath != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Visit'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SyncStateChip(
              key: Key('detail_sync_chip_${visit.id}'),
              syncState: visit.syncState,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status — autosave on change.
          StatusSelector(
            value: visit.status,
            onChanged: (next) => _edit(JobVisitPatch(status: next)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Status: '),
              StatusChip(status: visit.status),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.my_location,
                color: hasGps ? scheme.primary : scheme.onSurfaceVariant,
              ),
              title: Text(
                hasGps
                    ? '${visit.gpsLat!.toStringAsFixed(4)}, ${visit.gpsLng!.toStringAsFixed(4)}'
                    : 'No GPS recorded',
              ),
              subtitle: Text(
                hasGps && visit.gpsUpdatedAt != null
                    ? 'Updated ${_formatTimestamp(visit.gpsUpdatedAt!)}'
                    : 'Set at creation, or update now',
              ),
              trailing: _updatingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.my_location),
                      tooltip: 'Update location',
                      onPressed: _updateLocation,
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Photo — displayed only as a locked placeholder. The gate lives
          // inside the viewer (ui-plan §3.4), so tapping just navigates there.
          Card(
            child: ListTile(
              leading: hasPhoto
                  ? LockedPhotoPlaceholder(dimensions: 48)
                  : Icon(
                      Icons.add_photo_alternate_outlined,
                      color: scheme.onSurfaceVariant,
                    ),
              title: Text(
                hasPhoto ? 'Photo attached (locked)' : 'No photo attached',
              ),
              subtitle: Text(
                hasPhoto
                    ? 'Unlockable from the photo viewer'
                    : 'Add a photo from your gallery',
              ),
              trailing: _addingPhoto
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton(
                      onPressed: _addOrReplacePhoto,
                      child: Text(hasPhoto ? 'Replace' : 'Add'),
                    ),
              onTap: hasPhoto
                  ? () => context.push(AppRoutes.photo(visit.id))
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }
}
