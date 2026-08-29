import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/status_selector.dart';
import '../providers/create_job_visit_form.dart';

class CreateJobVisitScreen extends ConsumerStatefulWidget {
  const CreateJobVisitScreen({super.key});

  @override
  ConsumerState<CreateJobVisitScreen> createState() =>
      _CreateJobVisitScreenState();
}

class _CreateJobVisitScreenState extends ConsumerState<CreateJobVisitScreen> {
  @override
  void initState() {
    super.initState();
    // Kick off automatic GPS capture once on entry. Deferred past the first
    // frame: writing notifier state during initState (= build) is disallowed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(createJobVisitFormProvider.notifier).captureGps();
    });
  }

  Future<void> _save() async {
    final id = await ref.read(createJobVisitFormProvider.notifier).save();
    if (!mounted) return;
    if (id == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not create visit.')),
        );
      return;
    }
    context.pushReplacement(AppRoutes.detail(id));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final draft = ref.watch(createJobVisitFormProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Job Visit')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StatusSelector(
            value: draft.status,
            onChanged: (s) =>
                ref.read(createJobVisitFormProvider.notifier).setStatus(s),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: Icon(
                draft.gps != null
                    ? Icons.my_location
                    : Icons.location_off_outlined,
                color: draft.gps != null
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
              ),
              title: Text(
                draft.gps != null
                    ? 'GPS captured: ${draft.gps!.lat.toStringAsFixed(4)}, ${draft.gps!.lng.toStringAsFixed(4)}'
                    : draft.capturing
                    ? 'Capturing GPS…'
                    : 'GPS not captured',
              ),
              subtitle: Text(
                draft.gps != null
                    ? 'Captured automatically at creation'
                    : 'You can add it later from the visit screen',
              ),
              trailing: draft.capturing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: draft.saving ? null : _save,
            child: draft.saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create visit'),
          ),
        ],
      ),
    );
  }
}
