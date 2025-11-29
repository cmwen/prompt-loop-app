import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prompt_loop_app/core/router/app_router.dart';
import 'package:prompt_loop_app/core/theme/app_colors.dart';
import 'package:prompt_loop_app/domain/entities/purpose.dart';
import 'package:prompt_loop_app/features/purpose/providers/purpose_provider.dart';
import 'package:prompt_loop_app/features/skills/providers/skills_provider.dart';

/// Purpose setup screen for connecting skills to meaning.
class PurposeSetupScreen extends ConsumerStatefulWidget {
  final int? skillId;
  
  const PurposeSetupScreen({
    super.key,
    this.skillId,
  });
  
  @override
  ConsumerState<PurposeSetupScreen> createState() => _PurposeSetupScreenState();
}

class _PurposeSetupScreenState extends ConsumerState<PurposeSetupScreen> {
  final _purposeController = TextEditingController();
  PurposeCategory _selectedCategory = PurposeCategory.personal;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }
  
  Future<void> _savePurpose() async {
    if (_purposeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your purpose')),
      );
      return;
    }
    
    if (widget.skillId == null) {
      context.go(AppPaths.home);
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final purpose = Purpose(
        skillId: widget.skillId!,
        description: _purposeController.text.trim(),
        category: _selectedCategory,
        createdAt: DateTime.now(),
      );
      
      await ref.read(purposesProvider.notifier).createPurpose(purpose);
      
      if (mounted) {
        context.go(AppPaths.home);
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
  
  void _skip() {
    context.go(AppPaths.home);
  }
  
  @override
  Widget build(BuildContext context) {
    final skill = widget.skillId != null 
        ? ref.watch(skillByIdProvider(widget.skillId!))
        : null;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Purpose'),
        actions: [
          TextButton(
            onPressed: _skip,
            child: const Text('Skip for now'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Illustration
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.lightbulb,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Why does this matter?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Explanation
            Text(
              'Research by Angela Duckworth shows that connecting your practice to a deeper purpose significantly increases perseverance and success.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (skill != null)
              skill.when(
                data: (s) => s != null ? Text(
                  'Why do you want to master ${s.name}?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ) : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            const SizedBox(height: 24),
            
            // Purpose input
            TextField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Your Purpose',
                hintText: 'e.g., "To inspire others through my music" or "To build products that help people"',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            
            // Category selection
            Text(
              'What type of purpose is this?',
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
            
            // Example purposes
            Text(
              'Need inspiration?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...const [
              '"To become financially independent and provide for my family"',
              '"To contribute to solving climate change"',
              '"To create art that moves people"',
              '"To be able to communicate in multiple languages and connect with more people"',
            ].map((example) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Text(
                      example,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )),
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
                    : const Text('Save & Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getCategoryLabel(PurposeCategory category) {
    switch (category) {
      case PurposeCategory.personal:
        return 'Personal Growth';
      case PurposeCategory.career:
        return 'Career';
      case PurposeCategory.social:
        return 'Social Impact';
      case PurposeCategory.creative:
        return 'Creative Expression';
      case PurposeCategory.health:
        return 'Health & Wellness';
      case PurposeCategory.other:
        return 'Other';
    }
  }
  
  String _getCategoryDescription(PurposeCategory category) {
    switch (category) {
      case PurposeCategory.personal:
        return 'Skills for self-improvement and personal fulfillment';
      case PurposeCategory.career:
        return 'Skills for professional development and career advancement';
      case PurposeCategory.social:
        return 'Skills to help others or contribute to society';
      case PurposeCategory.creative:
        return 'Skills for artistic or creative expression';
      case PurposeCategory.health:
        return 'Skills for physical or mental well-being';
      case PurposeCategory.other:
        return 'Skills for other purposes';
    }
  }
}
