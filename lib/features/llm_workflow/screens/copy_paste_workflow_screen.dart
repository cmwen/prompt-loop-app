import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:deliberate_practice_app/core/router/app_router.dart';
import 'package:deliberate_practice_app/core/theme/app_colors.dart';
import 'package:deliberate_practice_app/data/services/copy_paste_llm_service.dart';
import 'package:deliberate_practice_app/domain/services/llm_service.dart';
import 'package:deliberate_practice_app/features/skills/providers/skills_provider.dart';
import 'package:deliberate_practice_app/shared/widgets/loading_indicator.dart';
import 'package:deliberate_practice_app/shared/widgets/app_card.dart';

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

  // Selected skill for task generation
  int? _selectedSkillId;

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

  void _generateTaskPrompt() {
    // TODO: Implement task generation prompt
    setState(() {
      _currentPrompt =
          '''Generate deliberate practice tasks for the selected skill.

Please respond with JSON in this format:
{
  "tasks": [
    {
      "title": "Task title",
      "description": "Detailed description",
      "estimated_minutes": 30,
      "difficulty": 5,
      "frequency": "daily",
      "success_criteria": ["Criterion 1", "Criterion 2"]
    }
  ]
}''';
    });
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
        context.pop();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error processing response: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _processSkillAnalysis() async {
    // TODO: Parse JSON and create skill/sub-skills
    // For now, just show success
  }

  Future<void> _processTaskGeneration() async {
    // TODO: Parse JSON and create tasks
  }

  Future<void> _processStruggleAnalysis() async {
    // TODO: Parse JSON and show feedback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
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
              title: 'Copy prompt to AI',
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
                        FilledButton.icon(
                          onPressed: _copyPrompt,
                          icon: Icon(
                            _isPromptCopied ? Icons.check : Icons.copy,
                          ),
                          label: Text(_isPromptCopied ? 'Copied!' : 'Copy'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _currentPrompt!.length > 200
                            ? '${_currentPrompt!.substring(0, 200)}...'
                            : _currentPrompt!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Copy this prompt and paste it into ChatGPT, Claude, or your preferred AI assistant.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              children: [
                DropdownButtonFormField<int>(
                  initialValue: _selectedSkillId,
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
                  onChanged: (value) =>
                      setState(() => _selectedSkillId = value),
                ),
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
