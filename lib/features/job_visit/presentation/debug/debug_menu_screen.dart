import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/status_selector.dart';
import '../../domain/entities/job_visit.dart';
import '../providers/job_visit_providers.dart';
import '../providers/sync_providers.dart';

/// Demo control panel. Everything here either flips mock connectivity (which
/// runs a sync) or writes DIRECTLY into the mock backend store — never into
/// the local DB, which is what makes the two-device and notification demos
/// possible from a single physical device.
class DebugMenuScreen extends ConsumerStatefulWidget {
  const DebugMenuScreen({super.key});

  @override
  ConsumerState<DebugMenuScreen> createState() => _DebugMenuScreenState();
}

class _DebugMenuScreenState extends ConsumerState<DebugMenuScreen> {
  @override
  Widget build(BuildContext context) {
    final online = ref.watch(isOnlineProvider);
    final visitsAsync = ref.watch(sortedJobVisitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Back to list',
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Online (simulate connectivity)'),
            subtitle: const Text(
              'Flipping to online runs a sync immediately.',
            ),
            value: online,
            onChanged: (value) async {
              ref.read(isOnlineProvider.notifier).state = value;
              if (!value) return;
              await _runSync();
            },
          ),
          const Divider(),
          const _FailAfterNCard(),
          const Divider(),
          visitsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Could not load visits: $e'),
            data: (visits) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeviceBEditCard(visits: visits),
                const Divider(),
                _BackendStatusCard(visits: visits),
              ],
            ),
          ),
          const Divider(),
          const _SyncLogCard(),
        ],
      ),
    );
  }

  Future<void> _runSync() async {
    // Arm the debug-menu failure injection against the shared backend, then
    // run the sync. The toggle flipping online IS the connectivity event.
    final backend = await ref.read(mockSyncServiceProvider.future);
    backend.failAfterRecords(ref.read(failAfterRecordsProvider));
    final engine = await ref.read(syncEngineProvider.future);
    final result = await engine.sync();

    // The engine already narrated every step into the developer log via its
    // onEvent wiring; here we add a closing summary line + the snackbar.
    final logLine = result.skipped
        ? 'Sync already running — ignored'
        : result.succeeded
            ? 'Sync finished: ${result.synced} visit(s) synced'
            : 'Sync stopped after ${result.synced} visit(s): ${result.failure}';
    final log = ref.read(syncLogProvider);
    ref.read(syncLogProvider.notifier).state = [
      ...log,
      SyncLogLine(message: logLine, at: DateTime.now()),
    ];
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(logLine)),
    );
  }
}

/// "Fail sync after N records" — a number input + Arm/Disarm. Arming makes the
/// mock backend throw on the Nth record of the NEXT sync run; Disarm clears it
/// so a later sync can succeed (needed for the resumability demo).
class _FailAfterNCard extends ConsumerStatefulWidget {
  const _FailAfterNCard();

  @override
  ConsumerState<_FailAfterNCard> createState() => _FailAfterNCardState();
}

class _FailAfterNCardState extends ConsumerState<_FailAfterNCard> {
  final _controller = TextEditingController(text: '2');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final armedFor = ref.watch(failAfterRecordsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fail sync after N records',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'N',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () {
                    final n = int.tryParse(_controller.text.trim());
                    ref.read(failAfterRecordsProvider.notifier).state = n;
                  },
                  child: const Text('Arm'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: armedFor == null
                      ? null
                      : () =>
                          ref.read(failAfterRecordsProvider.notifier).state =
                              null,
                  child: const Text('Disarm'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              armedFor == null
                  ? 'Failure injection disarmed.'
                  : 'Armed: next sync throws after $armedFor records.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Resolves the currently selected visit by *id* from the current list.
///
/// [JobVisit] has no `==` override, so identity comparisons break the moment
/// Drift re-emits new instances after a sync commits. Storing the id (never
/// the instance) keeps the dropdown selection stable across re-emissions.
JobVisit? resolveVisitById(String? id, List<JobVisit> visits) {
  if (id != null) {
    for (final v in visits) {
      if (v.id == id) return v;
    }
  }
  return visits.isEmpty ? null : visits.first;
}

/// "Simulate Device B edit" — pick an existing visit + field + value. The edit
/// is based on the BACKEND's stored record (not the local row), then written
/// directly into the mock backend store with an offset timestamp and `device-b`
/// as the writer. Basing it on the local row would fold A's own offline edits
/// into B's write → a phantom conflict in the headline demo.
class _DeviceBEditCard extends ConsumerStatefulWidget {
  const _DeviceBEditCard({required this.visits});

  final List<JobVisit> visits;

  @override
  ConsumerState<_DeviceBEditCard> createState() => _DeviceBEditCardState();
}

enum _BField { status, photo }

class _DeviceBEditCardState extends ConsumerState<_DeviceBEditCard> {
  String? _visitId;
  _BField _field = _BField.status;
  JobVisitStatus _status = JobVisitStatus.onSite;
  final _photoPath = TextEditingController(text: '/device-b/photo.png');
  bool _busy = false;

  @override
  void dispose() {
    _photoPath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_visitId == null && widget.visits.isNotEmpty) {
      _visitId = widget.visits.first.id;
    }
    final visit = resolveVisitById(_visitId, widget.visits);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Simulate Device B edit',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (visit == null)
              const Text('No visits to edit yet.')
            else ...[
              DropdownButtonFormField<String>(
                initialValue: visit.id,
                isExpanded: true,
                items: widget.visits
                    .map((v) => DropdownMenuItem(
                          value: v.id,
                          child: Text(
                            '${v.id.substring(0, 8)} · ${StatusChip.labelFor(v.status)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _visitId = v),
                decoration: const InputDecoration(labelText: 'Visit'),
              ),
              const SizedBox(height: 12),
              SegmentedButton<_BField>(
                segments: const [
                  ButtonSegment(value: _BField.status, label: Text('Status')),
                  ButtonSegment(value: _BField.photo, label: Text('Photo')),
                ],
                selected: {_field},
                onSelectionChanged: (s) => setState(() => _field = s.first),
              ),
              const SizedBox(height: 12),
              if (_field == _BField.status)
                StatusSelector(
                  value: _status,
                  onChanged: (s) => setState(() => _status = s),
                )
              else
                TextField(
                  controller: _photoPath,
                  decoration: const InputDecoration(
                    labelText: 'Photo path',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: _busy ? null : () => _writeDeviceB(),
                child: Text(_busy ? 'Writing…' : 'Write Device B edit to backend'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _writeDeviceB() async {
    final visit = resolveVisitById(_visitId, widget.visits);
    if (visit == null) return;
    setState(() => _busy = true);
    try {
      final backend = await ref.read(mockSyncServiceProvider.future);
      // Direct debug writes are never failure-injected.
      backend.failAfterRecords(null);

      final remote = await backend.getVisit(visit.id);
      if (remote == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This visit has never synced — sync once before simulating Device B.',
            ),
          ),
        );
        return;
      }
      final now = DateTime.now().millisecondsSinceEpoch + 5000;
      final remoteEdit = switch (_field) {
        _BField.status => remote.copyWith(
            status: _status,
            statusUpdatedAt: now,
            deviceId: 'device-b',
          ),
        _BField.photo => remote.copyWith(
            photoPath: _photoPath.text.trim(),
            photoUpdatedAt: now,
            deviceId: 'device-b',
          ),
      };
      await backend.upsertVisit(remoteEdit);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device B edit written to backend. Flip online to sync.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// "Backend changes status" — pick a visit + new status, writes directly into
/// the mock backend store. This is the trigger the notification demo hangs off.
class _BackendStatusCard extends ConsumerStatefulWidget {
  const _BackendStatusCard({required this.visits});

  final List<JobVisit> visits;

  @override
  ConsumerState<_BackendStatusCard> createState() => _BackendStatusCardState();
}

class _BackendStatusCardState extends ConsumerState<_BackendStatusCard> {
  String? _visitId;
  JobVisitStatus _status = JobVisitStatus.completed;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    if (_visitId == null && widget.visits.isNotEmpty) {
      _visitId = widget.visits.first.id;
    }
    final visit = resolveVisitById(_visitId, widget.visits);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Backend changes status',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (visit == null)
              const Text('No visits to change yet.')
            else ...[
              DropdownButtonFormField<String>(
                initialValue: visit.id,
                isExpanded: true,
                items: widget.visits
                    .map((v) => DropdownMenuItem(
                          value: v.id,
                          child: Text(
                            '${v.id.substring(0, 8)} · ${StatusChip.labelFor(v.status)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _visitId = v),
                decoration: const InputDecoration(labelText: 'Visit'),
              ),
              const SizedBox(height: 12),
              StatusSelector(
                value: _status,
                onChanged: (s) => setState(() => _status = s),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: _busy ? null : () => _writeBackendStatus(),
                child: Text(_busy ? 'Writing…' : 'Write status to backend'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _writeBackendStatus() async {
    final visit = resolveVisitById(_visitId, widget.visits);
    if (visit == null) return;
    setState(() => _busy = true);
    try {
      final backend = await ref.read(mockSyncServiceProvider.future);
      // Direct debug writes are never failure-injected.
      backend.failAfterRecords(null);

      final remote = await backend.getVisit(visit.id);
      if (remote == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This visit has never synced — sync once before changing its backend status.',
            ),
          ),
        );
        return;
      }
      final now = DateTime.now().millisecondsSinceEpoch + 5000;
      final remoteEdit = remote.copyWith(
        status: _status,
        statusUpdatedAt: now,
        deviceId: 'device-b',
      );
      await backend.upsertVisit(remoteEdit);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status written to backend. Flip online to sync.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _SyncLogCard extends ConsumerWidget {
  const _SyncLogCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(syncLogProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Developer log — how the sync unfolded',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                TextButton(
                  onPressed: log.isEmpty
                      ? null
                      : () => ref
                          .read(syncLogProvider.notifier)
                          .state = const <SyncLogLine>[],
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Each line is one step the engine actually took: pull → merge '
              '(baseline comparison) → push → commit, or skip.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: log.isEmpty
                  ? const Text('No syncs yet this session.')
                  : SingleChildScrollView(
                      reverse: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final line in log)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                line.toString(),
                                style: fontFeatureDefaults.copyWith(
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Monospace stylistic set so step timestamps and structure read like a log.
final fontFeatureDefaults = TextStyle(
  fontFamily: 'monospace',
  fontFamilyFallback: const ['Menlo', 'Consolas', 'Courier'],
);