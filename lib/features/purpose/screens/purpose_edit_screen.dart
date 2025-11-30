import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prompt_loop/domain/entities/purpose.dart';
import 'package:prompt_loop/features/purpose/providers/purpose_provider.dart';
import 'package:prompt_loop/features/skills/providers/skills_provider.dart';
import 'package:prompt_loop/shared/widgets/loading_indicator.dart';

/// Screen for adding or editing a purpose.
class PurposeEditScreen extends ConsumerStatefulWidget {
  final int skillId;
  final int? purposeId;

  const PurposeEditScreen({
    super.key,
    required this.skillId,
    this.purposeId,
  });

  @override
  ConsumerState<PurposeEditScreen> createState() => _PurposeEditScreenState();
}

class _PurposeEditScreenState extends ConsumerState<PurposeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _statementController = TextEditingController();
  PurposeCategory _selectedCategory = PurposeCategory.personalExpression;
  bool _isLoading = false;
  bool _isInitialized = false;

  bool get isEditing => widget.purposeId != null;

  @override
  void dispose() {
    _statementController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingPurpose() async {
    if (isEditing && !_isInitialized) {
      final purpose = await ref.read(purposeBySkillProvider(widget.skillId).future);
      if (purpose != null && mounted) {
        setState(() {
          _statementController.text = purpose.statement;
          _selectedCategory = purpose.category;
          _isInitialized = true;
        });
      }
    }
  }

  Future<void> _savePurpose() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final purpose = Purpose(
        id: widget.purposeId,
        skillId: widget.skillId,
        statement: _statementController.text.trim(),
        category: _selectedCategory,
        createdAt: DateTime.now(),
      );

      if (isEditing) {
        await ref.read(purposesProvider.notifier).updatePurpose(purpose);
      } else {
        await ref.read(purposesProvider.notifier).createPurpose(purpose);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Purpose updated' : 'Purpose saved'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final skill = ref.watch(skillByIdProvider(widget.skillId));

    // Load existing purpose for editing
    if (isEditing && !_isInitialized) {
      _loadExistingPurpose();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Purpose' : 'Add Purpose'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePurpose,
            child: const Text('Save'),
          ),
        ],
      ),
      body: skill.when(
        data: (skillData) {
          if (skillData == null) {
            return const Center(child: Text('Skill not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skill info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Skill',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              skillData.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Introduction text
                  Text(
                    'Why does mastering this skill matter to you?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Understanding your "why" helps sustain effort when practice gets hard. '
                    'This isn\'t just motivation—it\'s backed by research on grit and perseverance.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Purpose statement field
                  TextFormField(
                    controller: _statementController,
                    decoration: const InputDecoration(
                      labelText: 'Your purpose statement',
                      hintText: 'e.g., "To write songs that express what I can\'t say in words"',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your purpose statement';
                      }
                      if (value.trim().length < 10) {
                        return 'Please provide a more detailed purpose';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Category selection
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: PurposeCategory.values.map((category) {
                      final isSelected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Text(_getCategoryLabel(category)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = category);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getCategoryDescription(_selectedCategory),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Inspiration section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withAlpha(13),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withAlpha(51),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tips for Writing Meaningful Purposes',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTip(context, '• Connect to people you care about'),
                        _buildTip(context, '• Think about the impact you want to have'),
                        _buildTip(context, '• Consider how this fits your life\'s work'),
                        const SizedBox(height: 12),
                        Text(
                          'Examples:',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildExample(context, '"To become financially independent and provide for my family"'),
                        _buildExample(context, '"To create art that moves people"'),
                        _buildExample(context, '"To communicate in multiple languages and connect with more people"'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _savePurpose,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEditing ? 'Update Purpose' : 'Save Purpose'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildTip(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _buildExample(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontStyle: FontStyle.italic,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _getCategoryLabel(PurposeCategory category) {
    switch (category) {
      case PurposeCategory.personalExpression:
        return 'Personal Expression';
      case PurposeCategory.connectingWithOthers:
        return 'Connecting with Others';
      case PurposeCategory.careerGrowth:
        return 'Career Growth';
      case PurposeCategory.selfImprovement:
        return 'Self Improvement';
      case PurposeCategory.contributingBeyondSelf:
        return 'Contributing Beyond Self';
      case PurposeCategory.other:
        return 'Other';
    }
  }

  String _getCategoryDescription(PurposeCategory category) {
    switch (category) {
      case PurposeCategory.personalExpression:
        return 'Skills for personal expression and creativity';
      case PurposeCategory.connectingWithOthers:
        return 'Skills for connecting with others';
      case PurposeCategory.careerGrowth:
        return 'Skills for career or professional growth';
      case PurposeCategory.selfImprovement:
        return 'Skills for challenge and self-improvement';
      case PurposeCategory.contributingBeyondSelf:
        return 'Skills for contributing to something beyond myself';
      case PurposeCategory.other:
        return 'Skills for other purposes';
    }
  }
}
