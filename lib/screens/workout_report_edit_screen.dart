import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/exercise_video_service.dart';
import '../services/facility_booking_service.dart';
import '../services/workout_progress.dart';

class WorkoutReportEditScreen extends StatefulWidget {
  const WorkoutReportEditScreen({super.key, required this.report});

  final WorkoutReport report;

  @override
  State<WorkoutReportEditScreen> createState() =>
      _WorkoutReportEditScreenState();
}

class _WorkoutReportEditScreenState extends State<WorkoutReportEditScreen> {
  late WorkoutProgress _progress;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _progress = widget.report.workoutProgress;
  }

  List<Map<String, dynamic>> get _plan => widget.report.planSnapshot;

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final assigned = <String, AssignedExerciseProgress>{};
      for (final (index, item) in _plan.indexed) {
        final id = exerciseIdOf(item, fallbackIndex: index);
        final current = _progress.forExercise(id);
        assigned[id] = gatedAssignedProgress(
          item: item,
          completedSetIndexes: current.completedSetIndexes,
          exerciseCompleted: current.exerciseCompleted,
        );
      }
      final updated = await FacilityBookingService.instance
          .correctWorkoutReport(
            reportId: widget.report.id,
            expectedRevision: widget.report.revision,
            progress: _progress.copyWith(assigned: assigned),
          );
      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } on FacilityBookingException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Could not save the workout correction.';
      });
    }
  }

  void _setAssigned(String id, AssignedExerciseProgress entry) {
    setState(() {
      _progress = _progress.copyWith(
        assigned: {..._progress.assigned, id: entry},
      );
    });
  }

  void _setExtraSets(String id, ExtraSetsProgress extra) {
    final next = {..._progress.extraSets};
    if (extra.count <= 0) {
      next.remove(id);
    } else {
      next[id] = extra;
    }
    setState(() => _progress = _progress.copyWith(extraSets: next));
  }

  Future<void> _addExercise() async {
    final created = await showModalBottomSheet<ExtraExerciseProgress>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddExerciseSheet(),
    );
    if (created == null || !mounted) return;
    setState(() {
      _progress = _progress.copyWith(
        extraExercises: [..._progress.extraExercises, created],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit workout'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const Text(
            'Correct missed or extra work from this session. Assigned exercises cannot be removed. Extra work is listed separately and does not raise plan completion.',
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ],
          const SizedBox(height: 16),
          Text(
            'Assigned workout',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (_plan.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No assigned checklist was stored for this session.',
                ),
              ),
            )
          else
            ..._plan.indexed.map((entry) => _assignedCard(entry.$1, entry.$2)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Extra exercises',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              TextButton.icon(
                onPressed: _addExercise,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          if (_progress.extraExercises.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No extra exercises added.'),
              ),
            )
          else
            ..._progress.extraExercises.indexed.map(
              (entry) => _extraExerciseCard(entry.$1, entry.$2),
            ),
        ],
      ),
    );
  }

  Widget _assignedCard(int index, Map<String, dynamic> item) {
    final id = exerciseIdOf(item, fallbackIndex: index);
    final name = item['name']?.toString() ?? 'Exercise';
    final prescribed = prescribedSetCount(item);
    final assigned = gatedAssignedProgress(
      item: item,
      completedSetIndexes: _progress.forExercise(id).completedSetIndexes,
      exerciseCompleted: _progress.forExercise(id).exerciseCompleted,
    );
    final extra = _progress.extraSetsFor(id);
    final reps = item['reps']?.toString().trim() ?? extra.reps ?? '';
    final setsDone = allPrescribedSetsComplete(
      item,
      assigned.completedSetIndexes,
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              value: assigned.exerciseCompleted,
              onChanged: setsDone
                  ? (selected) => _setAssigned(
                      id,
                      gatedAssignedProgress(
                        item: item,
                        completedSetIndexes: assigned.completedSetIndexes,
                        exerciseCompleted: selected == true,
                      ),
                    )
                  : null,
              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                prescribed > 0
                    ? 'Tick every assigned set before marking this complete'
                    : 'Mark complete if this exercise was finished',
              ),
            ),
            if (prescribed > 0)
              ...List.generate(prescribed, (setIndex) {
                final number = setIndex + 1;
                return CheckboxListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 28, right: 16),
                  value: assigned.completedSetIndexes.contains(number),
                  onChanged: (selected) {
                    final next = {...assigned.completedSetIndexes};
                    if (selected == true) {
                      next.add(number);
                    } else {
                      next.remove(number);
                    }
                    _setAssigned(
                      id,
                      gatedAssignedProgress(
                        item: item,
                        completedSetIndexes: next.toList(),
                        exerciseCompleted: assigned.exerciseCompleted,
                      ),
                    );
                  },
                  title: Text(
                    reps.isEmpty ? 'Set $number' : 'Set $number · $reps reps',
                  ),
                );
              }),
            if (extra.count > 0)
              ...List.generate(extra.count, (setIndex) {
                final number = setIndex + 1;
                return CheckboxListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 28, right: 16),
                  value: extra.completedIndexes.contains(number),
                  onChanged: (selected) {
                    final next = {...extra.completedIndexes};
                    if (selected == true) {
                      next.add(number);
                    } else {
                      next.remove(number);
                    }
                    _setExtraSets(
                      id,
                      extra.copyWith(completedIndexes: next.toList()),
                    );
                  },
                  title: Text(
                    reps.isEmpty
                        ? 'Extra set $number'
                        : 'Extra set $number · $reps reps',
                  ),
                );
              }),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: extra.count >= 10
                    ? null
                    : () => _setExtraSets(
                        id,
                        extra.copyWith(
                          count: extra.count + 1,
                          reps: extra.reps ?? (reps.isEmpty ? null : reps),
                        ),
                      ),
                child: const Text('Add extra set'),
              ),
            ),
            if (extra.count > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    final nextCount = extra.count - 1;
                    _setExtraSets(
                      id,
                      extra.copyWith(
                        count: nextCount,
                        completedIndexes: extra.completedIndexes
                            .where((index) => index <= nextCount)
                            .toList(),
                      ),
                    );
                  },
                  child: const Text('Remove last extra set'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _extraExerciseCard(int index, ExtraExerciseProgress item) {
    final setsDone =
        item.sets <= 0 ||
        uniqueSetIndexes(item.completedSetIndexes, item.sets).length ==
            item.sets;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            CheckboxListTile(
              value: item.exerciseCompleted,
              onChanged: setsDone
                  ? (selected) => _replaceExtra(
                      index,
                      item.copyWith(exerciseCompleted: selected == true),
                    )
                  : null,
              title: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                item.source == 'library'
                    ? 'From Exercise Library'
                    : 'Custom exercise',
              ),
              secondary: IconButton(
                tooltip: 'Remove extra exercise',
                onPressed: () {
                  final next = [..._progress.extraExercises]..removeAt(index);
                  setState(
                    () => _progress = _progress.copyWith(extraExercises: next),
                  );
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ),
            if (item.sets > 0)
              ...List.generate(item.sets, (setIndex) {
                final number = setIndex + 1;
                return CheckboxListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 28, right: 16),
                  value: item.completedSetIndexes.contains(number),
                  onChanged: (selected) {
                    final next = {...item.completedSetIndexes};
                    if (selected == true) {
                      next.add(number);
                    } else {
                      next.remove(number);
                    }
                    final completed = next.toList();
                    final allDone =
                        uniqueSetIndexes(completed, item.sets).length ==
                        item.sets;
                    _replaceExtra(
                      index,
                      item.copyWith(
                        completedSetIndexes: completed,
                        exerciseCompleted: item.exerciseCompleted && allDone,
                      ),
                    );
                  },
                  title: Text(
                    item.reps == null || item.reps!.isEmpty
                        ? 'Set $number'
                        : 'Set $number · ${item.reps} reps',
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _replaceExtra(int index, ExtraExerciseProgress item) {
    final next = [..._progress.extraExercises];
    next[index] = item;
    setState(() => _progress = _progress.copyWith(extraExercises: next));
  }
}

class _AddExerciseSheet extends StatefulWidget {
  const _AddExerciseSheet();

  @override
  State<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<_AddExerciseSheet> {
  final _search = TextEditingController();
  final _customName = TextEditingController();
  final _sets = TextEditingController(text: '3');
  final _reps = TextEditingController(text: '12');
  List<ExerciseVideoLibraryItem> _videos = const [];
  bool _loadingLibrary = true;
  bool _custom = false;

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
    _loadLibrary();
  }

  @override
  void dispose() {
    _search.dispose();
    _customName.dispose();
    _sets.dispose();
    _reps.dispose();
    super.dispose();
  }

  Future<void> _loadLibrary() async {
    try {
      final videos = await ExerciseVideoService.instance.fetchLibrary();
      if (!mounted) return;
      setState(() {
        _videos = videos;
        _loadingLibrary = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingLibrary = false);
    }
  }

  int get _setCount => int.tryParse(_sets.text.trim()) ?? 0;

  void _submit({ExerciseVideoLibraryItem? video}) {
    final name = video?.title ?? _customName.text.trim();
    if (name.isEmpty) return;
    final sets = _setCount.clamp(0, 20);
    Navigator.of(context).pop(
      ExtraExerciseProgress(
        id: 'extra-${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        sets: sets,
        reps: _reps.text.trim().isEmpty ? null : _reps.text.trim(),
        source: video == null ? 'custom' : 'library',
        videoId: video?.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filterExerciseVideoLibrary(_videos, query: _search.text);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add extra exercise',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Library')),
                ButtonSegment(value: true, label: Text('Custom')),
              ],
              selected: {_custom},
              onSelectionChanged: (value) =>
                  setState(() => _custom = value.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _sets,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Sets',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reps,
              decoration: const InputDecoration(
                labelText: 'Reps',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (_custom) ...[
              TextField(
                controller: _customName,
                decoration: const InputDecoration(
                  labelText: 'Exercise name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _submit(),
                child: const Text('Add custom exercise'),
              ),
            ] else ...[
              TextField(
                controller: _search,
                decoration: const InputDecoration(
                  labelText: 'Search Exercise Library',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 8),
              if (_loadingLibrary)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                SizedBox(
                  height: 240,
                  child: filtered.isEmpty
                      ? const Center(child: Text('No matching exercises.'))
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final video = filtered[index];
                            return ListTile(
                              title: Text(video.title),
                              subtitle: video.topics.isEmpty
                                  ? null
                                  : Text(video.topics.join(' · ')),
                              onTap: () => _submit(video: video),
                            );
                          },
                        ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
