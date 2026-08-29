import 'package:flutter/material.dart';

import '../../features/job_visit/domain/entities/job_visit.dart';

/// Sync-state indicator: icon + label + color together — state is never shown
/// by color alone (assertable in widget tests via label text, and accessible).
class SyncStateChip extends StatelessWidget {
  const SyncStateChip({super.key, required this.syncState});

  final JobVisitSyncState syncState;

  @override
  Widget build(BuildContext context) {
    final (icon, label, style) = switch (syncState) {
      JobVisitSyncState.pending => (
          Icons.cloud_upload_outlined,
          'Pending',
          ChipVisual.outlined,
        ),
      JobVisitSyncState.synced => (
          Icons.cloud_done,
          'Synced',
          ChipVisual.filled,
        ),
      JobVisitSyncState.conflictResolved => (
          Icons.merge_type,
          'Conflict resolved',
          ChipVisual.accent,
        ),
    };

    final scheme = Theme.of(context).colorScheme;

    final Color background;
    final Color foreground;
    switch (style) {
      case ChipVisual.outlined:
        background = scheme.surfaceContainerHighest;
        foreground = scheme.onSurfaceVariant;
      case ChipVisual.filled:
        background = scheme.secondaryContainer;
        foreground = scheme.onSecondaryContainer;
      case ChipVisual.accent:
        background = scheme.errorContainer;
        foreground = scheme.onErrorContainer;
    }

    return Chip(
      avatar: Icon(icon, size: 18, color: foreground),
      label: Text(label),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(color: foreground),
      backgroundColor: background,
      side: style == ChipVisual.outlined
          ? BorderSide(color: scheme.outlineVariant)
          : BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

enum ChipVisual { outlined, filled, accent }