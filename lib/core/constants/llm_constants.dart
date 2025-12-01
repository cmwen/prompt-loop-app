/// LLM-related constants and prompt templates
class LlmConstants {
  LlmConstants._();

  // Response Types
  static const String typeSkillAnalysis = 'skill_analysis';
  static const String typeTaskGeneration = 'task_generation';
  static const String typeWiseFeedback = 'wise_feedback';

  // Schema Version
  static const String schemaVersion = '1.0';

  // JSON Instructions
  static const String jsonInstructions = '''
CRITICAL: Respond with ONLY valid JSON. No markdown, no explanation, no code blocks.
Start your response with { and end with }''';
}

/// Prompt template generator
class PromptTemplates {
  PromptTemplates._();

  /// Generate skill analysis prompt
  static String skillAnalysis({
    required String skillName,
    required String userContext,
    String? purposeStatement,
  }) =>
      '''
You are a deliberate practice expert trained in Anders Ericsson's methodology.

TASK: Analyze the following skill and break it down into learnable sub-skills.

SKILL: $skillName
USER CONTEXT: $userContext
${purposeStatement != null ? 'PURPOSE: $purposeStatement' : ''}

${LlmConstants.jsonInstructions}

REQUIRED FORMAT - You must respond with exactly this structure:
{
  "skill_name": "The skill name",
  "skill_description": "Brief 1-2 sentence description of the skill",
  "suggested_level": "beginner|intermediate|advanced|expert",
  "sub_skills": [
    {
      "name": "Sub-skill name",
      "description": "What this involves and why it matters",
      "priority": "high|medium|low",
      "estimated_hours": 20
    }
  ],
  "learning_path": [
    "Step 1: Start with...",
    "Step 2: Progress to...",
    "Step 3: Master..."
  ]
}

REQUIREMENTS:
- skill_name: Must match the skill being analyzed
- skill_description: 1-2 sentences explaining what the skill is
- suggested_level: Assess user's current level based on their context
- sub_skills: Generate 4-7 sub-skills ordered by learning sequence
- Each sub_skill must have: name, description, priority, estimated_hours
- priority: high (fundamental), medium (important), low (nice-to-have)
- learning_path: 3-5 steps outlining recommended progression
- Be specific and actionable
- Consider the user's stated purpose when prioritizing
''';

  /// Generate task generation prompt
  static String taskGeneration({
    required String skillName,
    required String subSkillName,
    required String currentLevel,
    String? recentStruggle,
  }) =>
      '''
You are a deliberate practice coach. Generate specific, measurable practice tasks.

SKILL: $skillName
SUB-SKILL: $subSkillName  
CURRENT LEVEL: $currentLevel
${recentStruggle != null ? 'RECENT STRUGGLE: $recentStruggle (address this in tasks)' : ''}

${LlmConstants.jsonInstructions}

{
  "type": "${LlmConstants.typeTaskGeneration}",
  "version": "${LlmConstants.schemaVersion}",
  "data": {
    "tasks": [
      {
        "id": "task_001",
        "title": "Clear, action-oriented title",
        "description": "Detailed instructions",
        "subSkillId": "sub_001",
        "durationMinutes": 15,
        "frequency": "daily",
        "difficulty": 5,
        "successCriteria": [
          "Specific measurable criterion 1",
          "Specific measurable criterion 2"
        ],
        "tips": [
          "Helpful tip for success"
        ]
      }
    ]
  }
}

REQUIREMENTS:
- Generate 3-5 tasks
- Tasks must be specific and measurable
- Include clear success criteria (2-4 per task)
- Progress from easier to harder
- Duration between 10-30 minutes each
- Address the user's struggle if provided
''';

  /// Generate wise feedback prompt (Duckworth addition)
  static String wiseFeedback({
    required String skillName,
    required String struggleDescription,
    required String taskTitle,
  }) =>
      '''
You are a wise mentor providing feedback to a learner.

CONTEXT:
- Skill being practiced: $skillName
- Task attempted: $taskTitle
- Struggle reported: $struggleDescription

Your feedback must embody "wise feedback" as defined by research:
1. Express HIGH STANDARDS - This is challenging work
2. Express BELIEF IN THEIR ABILITY - You can reach these standards

${LlmConstants.jsonInstructions}

{
  "type": "${LlmConstants.typeWiseFeedback}",
  "version": "${LlmConstants.schemaVersion}",
  "data": {
    "acknowledgment": "Validate the specific struggle they described",
    "normalization": "Explain why this is a common challenge",
    "reframe": "How this struggle is actually a sign of progress",
    "encouragement": "Express confidence in their ability",
    "suggestion": "One small, specific thing to try next time"
  }
}

TONE:
- Warm but not patronizing
- Specific to their struggle, not generic
- Convey that struggle is normal and expected
- Express genuine belief in their potential
''';
}
