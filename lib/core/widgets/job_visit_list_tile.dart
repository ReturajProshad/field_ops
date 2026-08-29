import 'package:flutter/material.dart';

import '../../features/job_visit/domain/entities/job_visit.dart';
import 'locked_photo_placeholder.dart';
import 'status_chip.dart';
import 'sync_state_chip.dart';

/// Row for one job visit on the list screen.
///
/// Leading: locked photo placeholder when a photo exists, else a plain status
/// icon. Never the image bytes. Trailing: the sync-state chip with a stable
/// key so widget tests can target it by visit id.
class JobVisitListTile extends StatelessWidget {
  const JobVisitListTile({super.key, required this.visit, this.onTap});

  final JobVisit visit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final subtitle = visit.gpsLat != null && visit.gpsLng != null
        ? 'Updated ${_formatTimestamp(visit.createdAt)} · ${visit.gpsLat!.toStringAsFixed(4)}, ${visit.gpsLng!.toStringAsFixed(4)}'
        : 'Updated ${_formatTimestamp(visit.createdAt)}';

    return ListTile(
      onTap: onTap,
      leading: visit.photoPath != null
          ? const LockedPhotoPlaceholder()
          : Icon(Icons.location_on_outlined, color: scheme.onSurfaceVariant),
      title: Row(
        children: [
          Expanded(
            child: Text(StatusChip.labelFor(visit.status)),
          ),
          SyncStateChip(
            key: Key('sync_chip_${visit.id}'),
            syncState: visit.syncState,
          ),
        ],
      ),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }

  String _formatTimestamp(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }
}