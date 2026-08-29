import 'package:flutter/material.dart';

import '../../features/job_visit/domain/entities/job_visit.dart';

/// Read-only status label + color treatment for a [JobVisitStatus].
///
/// Status is also never conveyed by color alone — always paired with the
/// human-readable label here and in [StatusSelector].
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final JobVisitStatus status;

  static String labelFor(JobVisitStatus status) => switch (status) {
        JobVisitStatus.enRoute => 'En Route',
        JobVisitStatus.onSite => 'On Site',
        JobVisitStatus.completed => 'Completed',
        JobVisitStatus.blocked => 'Blocked',
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(labelFor(status)),
      labelStyle: Theme.of(context)
          .textTheme
          .labelMedium
          ?.copyWith(color: scheme.onSurface),
      backgroundColor: scheme.surfaceContainerHighest,
      side: BorderSide(color: scheme.outlineVariant),
      visualDensity: VisualDensity.compact,
    );
  }
}