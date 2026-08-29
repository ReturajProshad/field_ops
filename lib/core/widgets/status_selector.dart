import 'package:flutter/material.dart';

import '../../features/job_visit/domain/entities/job_visit.dart';
import 'status_chip.dart';

/// Pick a [JobVisitStatus] from the four enum values. Uses a dropdown, not a
/// `SegmentedButton` — four labeled segments overflow on narrow phones
/// (ui-plan §3.2).
class StatusSelector extends StatelessWidget {
  const StatusSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final JobVisitStatus value;
  final ValueChanged<JobVisitStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<JobVisitStatus>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Status'),
      items: [
        for (final status in JobVisitStatus.values)
          DropdownMenuItem(
            value: status,
            child: Text(StatusChip.labelFor(status)),
          ),
      ],
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }
}