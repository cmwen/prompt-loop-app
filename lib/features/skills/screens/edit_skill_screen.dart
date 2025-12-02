import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prompt_loop/domain/entities/skill.dart';
import 'package:prompt_loop/features/skills/providers/skills_provider.dart';

/// Screen for editing an existing skill.
class EditSkillScreen extends ConsumerStatefulWidget {
  final int skillId;

  const EditSkillScreen({super.key, required this.skillId});

  @override
  ConsumerState<EditSkillScreen> createState() => _EditSkillScreenState();
}

class _EditSkillScreenState extends ConsumerState<EditSkillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  SkillLevel _selectedLevel = SkillLevel.beginner;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSkill();
  }

  Future<void> _loadSkill() async {
    try {
      final skills = ref.read(skillsProvider).valueOrNull ?? [];
      final skill = skills.firstWhere(
        (s) => s.id == widget.skillId,
        orElse: () => throw Exception('Skill not found'),
      );

      _nameController.text = skill.name;
      _descriptionController.text = skill.description ?? '';
      _selectedLevel = skill.currentLevel;

      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading skill: $e')));
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveSkill() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final skills = ref.read(skillsProvider).valueOrNull ?? [];
      final currentSkill = skills.firstWhere((s) => s.id == widget.skillId);

      final updatedSkill = currentSkill.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        currentLevel: _selectedLevel,
        updatedAt: DateTime.now(),
      );

      await ref.read(skillsProvider.notifier).updateSkill(updatedSkill);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Skill updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating skill: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Skill')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Skill')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skill name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Skill Name',
                  hintText: 'e.g., Guitar Playing, Public Speaking',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a skill name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'What does this skill involve?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // Current level
              Text(
                'Current Level',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...SkillLevel.values.map(
                (level) => RadioListTile<SkillLevel>(
                  title: Text(level.displayName),
                  subtitle: Text(_getLevelDescription(level)),
                  value: level,
                  groupValue: _selectedLevel,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedLevel = value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveSkill,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLevelDescription(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return 'Just starting out';
      case SkillLevel.intermediate:
        return 'Building competence';
      case SkillLevel.advanced:
        return 'Strong skills, refining expertise';
      case SkillLevel.expert:
        return 'Mastery level';
    }
  }
}
