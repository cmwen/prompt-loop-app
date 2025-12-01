import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:prompt_loop/core/router/app_router.dart';
import 'package:prompt_loop/core/theme/app_colors.dart';
import 'package:prompt_loop/core/constants/llm_constants.dart';
import 'package:prompt_loop/data/services/copy_paste_llm_service.dart';
import 'package:prompt_loop/domain/services/llm_service.dart';
import 'package:prompt_loop/domain/entities/task.dart';
import 'package:prompt_loop/domain/entities/skill.dart';
import 'package:prompt_loop/domain/entities/sub_skill.dart';
import 'package:prompt_loop/features/skills/providers/skills_provider.dart';
import 'package:prompt_loop/features/tasks/providers/tasks_provider.dart';
import 'package:prompt_loop/features/purpose/providers/purpose_provider.dart';
import 'package:prompt_loop/data/providers/repository_providers.dart';
import 'package:prompt_loop/shared/widgets/loading_indicator.dart';
import 'package:prompt_loop/shared/widgets/app_card.dart';

/// Copy-paste LLM workflow screen.
class CopyPasteWorkflowScreen extends ConsumerStatefulWidget {
  final CopyPasteWorkflowType workflowType;

  const CopyPasteWorkflowScreen({super.key, required this.workflowType});

  @override
  ConsumerState<CopyPasteWorkflowScreen> createState() =>
      _CopyPasteWorkflowScreenState();
}

class _CopyPasteWorkflowScreenState
    extends ConsumerState<CopyPasteWorkflowScreen> {
  final _responseController = TextEditingController();
  String? _currentPrompt;
  bool _isPromptCopied = false;
  bool _isProcessing = false;
  String? _errorMessage;

  // For skill analysis
  final _skillNameController = TextEditingController();
  final _currentLevelController = TextEditingController();
  final _goalsController = TextEditingController();

  // Selected skill and sub-skill for task generation
  int? _selectedSkillId;
  int? _selectedSubSkillId;

  @override
  void initState() {
    super.initState();
    // Add listener to rebuild button state when text changes
    _skillNameController.addListener(() {
      setState(() {}); // Rebuild to update button enabled state
    });
    
    // Note: For text sharing, users will use the "Paste from Clipboard" button
    // The receive_sharing_intent package doesn't support text intents in this version
  }

  @override
  void dispose() {
    _responseController.dispose();
    _skillNameController.dispose();
    _currentLevelController.dispose();
    _goalsController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.workflowType) {
      case CopyPasteWorkflowType.skillAnalysis:
        return 'Analyze Skill';
      case CopyPasteWorkflowType.taskGeneration:
        return 'Generate Tasks';
      case CopyPasteWorkflowType.struggleAnalysis:
        return 'Get Feedback';
    }
  }

  void _generatePrompt() {
    setState(() {
      _isPromptCopied = false;
      _errorMessage = null;
    });

    switch (widget.workflowType) {
      case CopyPasteWorkflowType.skillAnalysis:
        _generateSkillAnalysisPrompt();
        break;
      case CopyPasteWorkflowType.taskGeneration:
        _generateTaskPrompt();
        break;
      case CopyPasteWorkflowType.struggleAnalysis:
        _generateStrugglePrompt();
        break;
    }
  }

  void _generateSkillAnalysisPrompt() {
    final request = SkillAnalysisRequest(
      skillDescription: _skillNameController.text.trim(),
      currentLevel: _currentLevelController.text.trim().isEmpty
          ? null
          : _currentLevelController.text.trim(),
      goals: _goalsController.text.trim().isEmpty
          ? null
          : _goalsController.text.trim(),
    );

    final service = CopyPasteLlmService(
      onPromptReady: (prompt) async => setState(() => _currentPrompt = prompt),
      onResponseReceived: () async => _responseController.text,
    );

    // This generates the prompt but doesn't wait for response
    service.analyzeSkill(request);
  }

  void _generateTaskPrompt() async {
    if (_selectedSkillId == null) return;

    setState(() {
      _errorMessage = null;
    });

    try {
      // Get skill data
      final skills = ref.read(skillsProvider).valueOrNull ?? [];
      final skill = skills.firstWhere(
        (s) => s.id == _selectedSkillId,
        orElse: () => throw Exception('Skill not found'),
      );

      // Get sub-skills
      final subSkills = await ref.read(subSkillsProvider(_selectedSkillId!).future);

      // Get specific sub-skill if selected
      SubSkill? targetSubSkill;
      if (_selectedSubSkillId != null) {
        targetSubSkill = subSkills.firstWhere(
          (s) => s.id == _selectedSubSkillId,
          orElse: () => throw Exception('Sub-skill not found'),
        );
      }

      // Get purpose (if any)
      final purpose = await ref.read(purposeBySkillProvider(_selectedSkillId!).future);

      // Get recent tasks for this skill
      final tasks = await ref.read(tasksBySkillProvider(_selectedSkillId!).future);
      final recentTasks = tasks.take(5).toList();

      // Build context-enriched prompt
      final contextBuffer = StringBuffer();
      contextBuffer.writeln('You are a deliberate practice coach. Generate specific, measurable practice tasks.');
      contextBuffer.writeln();
      contextBuffer.writeln('═══════════════════════════════════════════════════════════════');
      contextBuffer.writeln('USER CONTEXT');
      contextBuffer.writeln('═══════════════════════════════════════════════════════════════');
      contextBuffer.writeln();
      contextBuffer.writeln('SKILL: ${skill.name}');
      contextBuffer.writeln('LEVEL: ${skill.currentLevel.name}');

      if (targetSubSkill != null) {
        contextBuffer.writeln();
        contextBuffer.writeln('TARGET SUB-SKILL: ${targetSubSkill.name}');
        contextBuffer.writeln('Description: ${targetSubSkill.description}');
        contextBuffer.writeln('Priority: ${targetSubSkill.priority.name}');
        contextBuffer.writeln('Progress: ${targetSubSkill.progressPercent}%');
      }

      if (purpose != null) {
        contextBuffer.writeln();
        contextBuffer.writeln('PURPOSE: "${purpose.statement}"');
        contextBuffer.writeln('(Category: ${_getCategoryLabel(purpose.category)})');
      }

      if (subSkills.isNotEmpty && targetSubSkill == null) {
        contextBuffer.writeln();
        contextBuffer.writeln('SUB-SKILLS IN PROGRESS:');
        for (final subSkill in subSkills) {
          contextBuffer.writeln('  • ${subSkill.name} (${subSkill.priority.name} priority) - ${subSkill.progressPercent}% complete');
        }
      }

      if (recentTasks.isNotEmpty) {
        contextBuffer.writeln();
        contextBuffer.writeln('RECENT TASKS:');
        for (final task in recentTasks) {
          final status = task.isCompleted ? '✓' : '○';
          contextBuffer.writeln('  $status ${task.title}');
        }
      }

      contextBuffer.writeln();
      contextBuffer.writeln('═══════════════════════════════════════════════════════════════');
      contextBuffer.writeln();
      contextBuffer.writeln('Generate 3-5 practice tasks that:');
      if (targetSubSkill != null) {
        contextBuffer.writeln('• Focus specifically on the "${targetSubSkill.name}" sub-skill');
      } else {
        contextBuffer.writeln('• Build on current progress shown above');
        contextBuffer.writeln('• Target the sub-skills marked as high priority');
      }
      if (purpose != null) {
        contextBuffer.writeln('• Connect to the user\'s purpose: "${purpose.statement}"');
      }
      contextBuffer.writeln('• Are specific, measurable, and achievable in 10-30 minutes');
      contextBuffer.writeln();
      contextBuffer.writeln('${LlmConstants.jsonInstructions}');
      contextBuffer.writeln();
      contextBuffer.writeln('''{
  "tasks": [
    {
      "title": "Task title",
      "description": "Detailed description with specific instructions",
      "estimated_minutes": 20,
      "difficulty": 5,
      "frequency": "daily",
      "target_sub_skill": "sub-skill name this task targets",
      "success_criteria": ["Criterion 1", "Criterion 2"]
    }
  ]
}''');

      setState(() {
        _currentPrompt = contextBuffer.toString();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error building prompt: $e';
      });
    }
  }

  String _getCategoryLabel(dynamic category) {
    final categoryStr = category.toString().split('.').last;
    switch (categoryStr) {
      case 'personalExpression':
        return 'Personal Expression';
      case 'connectingWithOthers':
        return 'Connecting with Others';
      case 'careerGrowth':
        return 'Career Growth';
      case 'selfImprovement':
        return 'Self Improvement';
      case 'contributingBeyondSelf':
        return 'Contributing Beyond Self';
      default:
        return 'Other';
    }
  }

  void _generateStrugglePrompt() {
    // TODO: Implement struggle analysis prompt
    setState(() {
      _currentPrompt = '''Analyze this struggle and provide wise feedback.

Please respond with JSON in this format:
{
  "high_standards_message": "Your expectations are high, and that's good...",
  "belief_message": "I believe you can achieve this because...",
  "actionable_suggestions": ["Suggestion 1", "Suggestion 2"],
  "encouragement": "Keep going because..."
}''';
    });
  }

  Future<void> _copyPrompt() async {
    if (_currentPrompt == null) return;

    await Clipboard.setData(ClipboardData(text: _currentPrompt!));
    setState(() => _isPromptCopied = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prompt copied to clipboard!')),
      );
    }
  }

  Future<void> _sharePrompt() async {
    if (_currentPrompt == null) return;

    try {
      await Share.share(
        _currentPrompt!,
        subject: 'Practice Task Prompt',
      );
      setState(() => _isPromptCopied = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
  }

  Future<void> _pasteResponse() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      _responseController.text = clipboardData!.text!;
    }
  }

  Future<void> _processResponse() async {
    if (_responseController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please paste the AI response first');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Parse and save the response based on workflow type
      switch (widget.workflowType) {
        case CopyPasteWorkflowType.skillAnalysis:
          await _processSkillAnalysis();
          break;
        case CopyPasteWorkflowType.taskGeneration:
          await _processTaskGeneration();
          break;
        case CopyPasteWorkflowType.struggleAnalysis:
          await _processStruggleAnalysis();
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Response processed successfully!')),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppPaths.home);
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error processing response: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _processSkillAnalysis() async {
    final response = _responseController.text.trim();
    if (response.isEmpty) {
      throw Exception('No response to parse');
    }

    final service = CopyPasteLlmService(
      onPromptReady: (_) async {},
      onResponseReceived: () async => response,
    );

    final request = SkillAnalysisRequest(
      skillDescription: _skillNameController.text.trim(),
      currentLevel: _currentLevelController.text.trim().isEmpty
          ? null
          : _currentLevelController.text.trim(),
      goals: _goalsController.text.trim().isEmpty
          ? null
          : _goalsController.text.trim(),
    );

    final result = await service.analyzeSkill(request);

    if (!result.isSuccess) {
      throw Exception(result.error);
    }

    final analysis = result.data;
    if (analysis == null) {
      throw Exception('No analysis data returned');
    }

    // Check if skill already exists by name
    final repository = await ref.read(skillRepositoryProvider.future);
    final existingSkill = await repository.getSkillByName(analysis.skillName);

    int skillId;
    if (existingSkill != null) {
      // Update existing skill
      final updatedSkill = existingSkill.copyWith(
        description: analysis.skillDescription,
        currentLevel: analysis.suggestedLevel,
        updatedAt: DateTime.now(),
      );
      await ref.read(skillsProvider.notifier).updateSkill(updatedSkill);
      skillId = existingSkill.id!;
    } else {
      // Create new skill
      final skill = Skill(
        name: analysis.skillName,
        description: analysis.skillDescription,
        currentLevel: analysis.suggestedLevel,
        createdAt: DateTime.now(),
      );
      skillId = await ref.read(skillsProvider.notifier).createSkill(skill);
    }

    // Get existing sub-skills to avoid duplicates
    final existingSubSkills = await repository.getSubSkills(skillId);
    final existingSubSkillNames = existingSubSkills.map((s) => s.name.toLowerCase()).toSet();

    // Create only new sub-skills
    for (final subSkillSuggestion in analysis.subSkills) {
      if (!existingSubSkillNames.contains(subSkillSuggestion.name.toLowerCase())) {
        final subSkill = SubSkill(
          skillId: skillId,
          name: subSkillSuggestion.name,
          description: subSkillSuggestion.description,
          priority: subSkillSuggestion.priority,
          isLlmGenerated: true,
          createdAt: DateTime.now(),
        );

        await ref.read(skillsProvider.notifier).createSubSkill(subSkill);
      }
    }
  }

  Future<void> _processTaskGeneration() async {
    if (_selectedSkillId == null) {
      throw Exception('No skill selected');
    }

    final response = _responseController.text.trim();
    if (response.isEmpty) {
      throw Exception('No response to parse');
    }

    final service = CopyPasteLlmService(
      onPromptReady: (_) async {},
      onResponseReceived: () async => response,
    );

    final request = TaskGenerationRequest(
      skill: Skill(
        id: 0,
        name: '',
        currentLevel: SkillLevel.beginner,
        createdAt: DateTime.now(),
      ),
      subSkills: [],
    );

    final result = await service.generateTasks(request);

    if (!result.isSuccess) {
      throw Exception(result.error);
    }

    final tasks = result.data ?? [];
    final tasksNotifier = ref.read(tasksProvider.notifier);

    for (final taskSuggestion in tasks) {
      final task = Task(
        skillId: _selectedSkillId!,
        subSkillId: _selectedSubSkillId, // Associate with selected sub-skill
        title: taskSuggestion.title,
        description: taskSuggestion.description,
        durationMinutes: taskSuggestion.durationMinutes,
        difficulty: taskSuggestion.difficulty,
        successCriteria: taskSuggestion.successCriteria,
        frequency: taskSuggestion.frequency,
        isLlmGenerated: true,
        createdAt: DateTime.now(),
      );

      await tasksNotifier.createTask(task);
    }
  }

  Future<void> _processStruggleAnalysis() async {
    // TODO: Parse JSON and show feedback
  }

  /// Handle back button press with confirmation if there's unsaved work
  Future<bool> _onWillPop() async {
    // If we have a generated prompt but haven't processed it, confirm exit
    if (_currentPrompt != null && !_isProcessing) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard progress?'),
          content: const Text(
            'You have a generated prompt that hasn\'t been processed yet. '
            'If you go back, you\'ll lose this progress.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Stay'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard & Go Back'),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }
    return true;
  }

  void _handleBack() async {
    if (await _onWillPop()) {
      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppPaths.home);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _onWillPop()) {
          if (mounted) {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppPaths.home);
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
          title: Text(_title),
        ),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: Input
            _StepHeader(
              step: 1,
              title: 'Describe what you need',
              isActive: _currentPrompt == null,
            ),
            if (_currentPrompt == null) ...[
              const SizedBox(height: 12),
              _buildInputForm(),
            ],
            const SizedBox(height: 24),

            // Step 2: Copy prompt
            _StepHeader(
              step: 2,
              title: 'Share or copy prompt',
              isActive: _currentPrompt != null && !_isPromptCopied,
            ),
            if (_currentPrompt != null) ...[
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Prompt ready!',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        // Share button (recommended for Android)
                        OutlinedButton.icon(
                          onPressed: _sharePrompt,
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                        ),
                        const SizedBox(width: 8),
                        // Copy button (fallback)
                        FilledButton.icon(
                          onPressed: _copyPrompt,
                          icon: Icon(
                            _isPromptCopied ? Icons.check : Icons.copy,
                          ),
                          label: Text(_isPromptCopied ? 'Copied!' : 'Copy'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Tip about sharing
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tip: Use "Share" to send directly to ChatGPT or Claude. '
                              'After getting a response, share it back to import.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Prompt preview
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _currentPrompt!.length > 300
                            ? '${_currentPrompt!.substring(0, 300)}...'
                            : _currentPrompt!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Step 3: Paste response
            _StepHeader(
              step: 3,
              title: 'Paste AI response',
              isActive: _isPromptCopied,
            ),
            if (_isPromptCopied) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _responseController,
                      decoration: const InputDecoration(
                        labelText: 'AI Response (JSON)',
                        hintText:
                            'Paste the response from ChatGPT/Claude here...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pasteResponse,
                    icon: const Icon(Icons.paste),
                    label: const Text('Paste from Clipboard'),
                  ),
                  const Spacer(),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Process button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isProcessing ? null : _processResponse,
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Process Response'),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildInputForm() {
    switch (widget.workflowType) {
      case CopyPasteWorkflowType.skillAnalysis:
        return _buildSkillAnalysisForm();
      case CopyPasteWorkflowType.taskGeneration:
        return _buildTaskGenerationForm();
      case CopyPasteWorkflowType.struggleAnalysis:
        return _buildStruggleForm();
    }
  }

  Widget _buildSkillAnalysisForm() {
    return Column(
      children: [
        TextField(
          controller: _skillNameController,
          decoration: const InputDecoration(
            labelText: 'Skill to analyze',
            hintText: 'e.g., Guitar playing, Public speaking, Programming',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _currentLevelController,
          decoration: const InputDecoration(
            labelText: 'Current level (optional)',
            hintText: 'e.g., Beginner, Intermediate, 2 years experience',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _goalsController,
          decoration: const InputDecoration(
            labelText: 'Goals (optional)',
            hintText: 'What do you want to achieve with this skill?',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _skillNameController.text.trim().isEmpty
                ? null
                : _generatePrompt,
            child: const Text('Generate Prompt'),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskGenerationForm() {
    final skills = ref.watch(skillsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a skill to generate practice tasks for:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        skills.when(
          data: (skillList) {
            if (skillList.isEmpty) {
              return const Text('No skills yet. Add a skill first.');
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<int>(
                  value: _selectedSkillId,
                  decoration: const InputDecoration(
                    labelText: 'Select Skill',
                    border: OutlineInputBorder(),
                  ),
                  items: skillList
                      .map(
                        (skill) => DropdownMenuItem(
                          value: skill.id,
                          child: Text(skill.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSkillId = value;
                      _selectedSubSkillId = null; // Reset sub-skill selection
                    });
                  },
                ),
                if (_selectedSkillId != null) ...[
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, _) {
                      final subSkills = ref.watch(subSkillsProvider(_selectedSkillId!));
                      return subSkills.when(
                        data: (subSkillList) {
                          if (subSkillList.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'No sub-skills for this skill yet. Tasks will be generated for the skill overall.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Optional: Select a specific sub-skill',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int?>(
                                value: _selectedSubSkillId,
                                decoration: const InputDecoration(
                                  labelText: 'Sub-skill (Optional)',
                                  border: OutlineInputBorder(),
                                  hintText: 'All sub-skills',
                                ),
                                items: [
                                  const DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text('All sub-skills'),
                                  ),
                                  ...subSkillList.map(
                                    (subSkill) => DropdownMenuItem<int?>(
                                      value: subSkill.id,
                                      child: Text(subSkill.name),
                                    ),
                                  ),
                                ],
                                onChanged: (value) =>
                                    setState(() => _selectedSubSkillId = value),
                              ),
                            ],
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (e, _) => Text('Error loading sub-skills: $e'),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _selectedSkillId == null
                        ? null
                        : _generatePrompt,
                    child: const Text('Generate Prompt'),
                  ),
                ),
              ],
            );
          },
          loading: () => const LoadingIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),
      ],
    );
  }

  Widget _buildStruggleForm() {
    return Column(
      children: [
        const Text('Describe what you\'re struggling with:'),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Your struggle',
            hintText: 'What specific challenge are you facing?',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _generatePrompt,
            child: const Text('Generate Prompt'),
          ),
        ),
      ],
    );
  }
}

/// Step header widget.
class _StepHeader extends StatelessWidget {
  final int step;
  final String title;
  final bool isActive;

  const _StepHeader({
    required this.step,
    required this.title,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withAlpha(102),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive
                ? null
                : Theme.of(context).colorScheme.onSurface.withAlpha(102),
          ),
        ),
      ],
    );
  }
}
