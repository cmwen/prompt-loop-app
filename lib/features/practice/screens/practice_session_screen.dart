import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prompt_loop/features/skills/providers/skills_provider.dart';
import 'package:prompt_loop/features/tasks/providers/tasks_provider.dart';
import 'package:prompt_loop/features/practice/providers/practice_provider.dart';
import 'package:prompt_loop/shared/widgets/loading_indicator.dart';
import 'package:prompt_loop/core/theme/app_colors.dart';

/// Practice session screen for deliberate practice.
class PracticeSessionScreen extends ConsumerStatefulWidget {
  final int skillId;
  final int? taskId;

  const PracticeSessionScreen({super.key, required this.skillId, this.taskId});

  @override
  ConsumerState<PracticeSessionScreen> createState() =>
      _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends ConsumerState<PracticeSessionScreen> {
  DateTime? _startTime;
  DateTime? _pausedTime;
  Duration _pausedDuration = Duration.zero;
  bool _isPracticing = false;
  bool _isPaused = false;
  int _rating = 3;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startPractice();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _startPractice() {
    setState(() {
      _startTime = DateTime.now();
      _isPracticing = true;
      _isPaused = false;
    });
  }

  void _pausePractice() {
    if (_isPracticing && !_isPaused) {
      setState(() {
        _pausedTime = DateTime.now();
        _isPaused = true;
      });
    }
  }

  void _resumePractice() {
    if (_isPracticing && _isPaused && _pausedTime != null) {
      setState(() {
        _pausedDuration += DateTime.now().difference(_pausedTime!);
        _pausedTime = null;
        _isPaused = false;
      });
    }
  }

  Duration _getElapsedTime() {
    if (_startTime == null) return Duration.zero;
    final now = _isPaused && _pausedTime != null ? _pausedTime! : DateTime.now();
    return now.difference(_startTime!) - _pausedDuration;
  }

  Future<void> _endPractice() async {
    if (_startTime == null) return;

    // Get total duration excluding pauses
    final duration = _getElapsedTime();

    try {
      // Start the session first
      final sessionId = await ref
          .read(practiceSessionsProvider.notifier)
          .startSession(widget.taskId!);

      // Complete the session with actual duration
      await ref.read(practiceSessionsProvider.notifier).completeSession(
        sessionId: sessionId,
        durationSeconds: duration.inSeconds,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        rating: _rating,
      );

      // Record practice for streak
      await ref
          .read(practiceSessionsProvider.notifier)
          .recordPracticeForStreak(widget.skillId);

      // Mark task as completed if provided
      if (widget.taskId != null) {
        await ref.read(tasksProvider.notifier).completeTask(widget.taskId!);
      }

      if (mounted) {
        _showCompletionDialog(duration);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving session: $e')));
      }
    }
  }

  void _showCompletionDialog(Duration duration) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.celebration, size: 48, color: AppColors.success),
        title: const Text('Great Practice!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You practiced for ${duration.inMinutes} minutes.'),
            const SizedBox(height: 8),
            const Text('Keep up the good work! 💪'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close dialog
              if (mounted) {
                // Navigate back to home or previous screen
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/'); // Go to home if can't pop
                }
              }
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final skill = ref.watch(skillByIdProvider(widget.skillId));
    final task = widget.taskId != null
        ? ref
              .watch(tasksProvider)
              .valueOrNull
              ?.firstWhere(
                (t) => t.id == widget.taskId,
                orElse: () => throw Exception('Task not found'),
              )
        : null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _showExitConfirmation();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Practice Session'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitConfirmation(),
          ),
        ),
        body: skill.when(
        data: (skillData) {
          if (skillData == null) {
            return const Center(child: Text('Skill not found'));
          }

          final isTaskCompleted = task?.isCompleted ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Skill info
                Text(
                  skillData.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Task info if available
                if (task != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.task_alt, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Today\'s Task',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (task.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        if (task.successCriteria.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Success Criteria:',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          ...task.successCriteria.map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• '),
                                  Expanded(child: Text(c)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Show completed status or timer
                if (isTaskCompleted) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.success),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Task Completed',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (task?.completedAt != null)
                                Text(
                                  'Completed on ${_formatDate(task!.completedAt!)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Want to practice again?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        ref.read(tasksProvider.notifier).uncompleteTask(task!.id!);
                        setState(() {
                          _startPractice();
                        });
                      },
                      icon: const Icon(Icons.replay),
                      label: const Text('Practice Again'),
                    ),
                  ),
                ] else ...[
                  // Timer with pause/resume
                  if (_isPracticing) ...[
                    _PracticeTimerWithControls(
                      startTime: _startTime!,
                      getElapsedTime: _getElapsedTime,
                      isPaused: _isPaused,
                      onPause: _pausePractice,
                      onResume: _resumePractice,
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Rating
                  Text(
                    'How did the practice feel?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _RatingSelector(
                    rating: _rating,
                    onRatingChanged: (r) => setState(() => _rating = r),
                  ),
                  const SizedBox(height: 24),

                  // Notes
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'What did you learn? What was challenging?',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    enabled: !_isPaused,
                  ),
                  const SizedBox(height: 32),

                  // End session button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isPaused ? null : _endPractice,
                      icon: const Icon(Icons.check),
                      label: const Text('End Practice'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading...'),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Exit Practice?'),
        content: const Text('Your progress will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Continue Practicing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close dialog
              if (mounted) {
                // Navigate back
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/'); // Go to home if can't pop
                }
              }
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

/// Timer widget with pause/resume controls.
class _PracticeTimerWithControls extends StatefulWidget {
  final DateTime startTime;
  final Duration Function() getElapsedTime;
  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onResume;

  const _PracticeTimerWithControls({
    required this.startTime,
    required this.getElapsedTime,
    required this.isPaused,
    required this.onPause,
    required this.onResume,
  });

  @override
  State<_PracticeTimerWithControls> createState() => _PracticeTimerWithControlsState();
}

class _PracticeTimerWithControlsState extends State<_PracticeTimerWithControls> {
  late Stream<int> _timerStream;

  @override
  void initState() {
    super.initState();
    _timerStream = Stream.periodic(const Duration(seconds: 1), (i) => i);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _timerStream,
      builder: (context, snapshot) {
        final duration = widget.getElapsedTime();
        final minutes = duration.inMinutes.toString().padLeft(2, '0');
        final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

        return Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  color: widget.isPaused
                      ? AppColors.warning.withAlpha(25)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: widget.isPaused
                      ? Border.all(color: AppColors.warning, width: 2)
                      : null,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isPaused) ...[
                          const Icon(Icons.pause_circle, color: AppColors.warning),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          '$minutes:$seconds',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.isPaused ? 'Paused' : 'Practice Time',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.isPaused
                            ? AppColors.warning
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isPaused)
                    FilledButton.icon(
                      onPressed: widget.onResume,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Resume'),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: widget.onPause,
                      icon: const Icon(Icons.pause),
                      label: const Text('Pause'),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Rating selector widget.
class _RatingSelector extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;

  const _RatingSelector({required this.rating, required this.onRatingChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final value = index + 1;
        return GestureDetector(
          onTap: () => onRatingChanged(value),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: value <= rating
                      ? Theme.of(context).colorScheme.primary.withAlpha(25)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: value <= rating
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getRatingEmoji(value),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getRatingLabel(value),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        );
      }),
    );
  }

  String _getRatingEmoji(int value) {
    switch (value) {
      case 1:
        return '😫';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '🎉';
      default:
        return '😐';
    }
  }

  String _getRatingLabel(int value) {
    switch (value) {
      case 1:
        return 'Hard';
      case 2:
        return 'Tough';
      case 3:
        return 'OK';
      case 4:
        return 'Good';
      case 5:
        return 'Great';
      default:
        return '';
    }
  }
}
