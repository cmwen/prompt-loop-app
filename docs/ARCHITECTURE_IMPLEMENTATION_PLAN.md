# Technical Architecture & Implementation Plan

---
**Created**: November 29, 2025  
**Architect**: @architect agent  
**Version**: 1.0  
**Status**: Draft  
**Related Documents**: 
- [VISION.md](./VISION.md) - Product Vision
- [UX_DESIGN.md](./UX_DESIGN.md) - UX Design (Reviewed by Angela Duckworth)
- [RESEARCH_TECHNICAL_FEASIBILITY.md](./RESEARCH_TECHNICAL_FEASIBILITY.md) - Technical Research

---

## Executive Summary

This document outlines the technical architecture and implementation plan for the Deliberate Practice App. The architecture follows **Clean Architecture** principles with a feature-first folder structure, designed to support:

1. **Dual-Mode LLM Integration** (BYOK + Copy-Paste)
2. **Offline-First Data Storage** with SQLite
3. **Grit-Informed Features** (Purpose Connection, Struggle Diary, Wise Feedback)
4. **Visual Progress Tracking** with charts and skill trees

---

## 1. Architecture Overview

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           PRESENTATION LAYER                            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │   Screens   │ │   Widgets   │ │ Controllers │ │    State    │      │
│  │  (Flutter)  │ │ (Reusable)  │ │ (Riverpod)  │ │  (Notifiers)│      │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                            DOMAIN LAYER                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │  Entities   │ │  Use Cases  │ │ Repository  │ │  Validators │      │
│  │  (Models)   │ │  (Business  │ │ Interfaces  │ │   (JSON)    │      │
│  │             │ │   Logic)    │ │             │ │             │      │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                             DATA LAYER                                  │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │  Repository │ │ Data Sources│ │   Mappers   │ │   DTOs      │      │
│  │   (Impl)    │ │ (Local/LLM) │ │             │ │             │      │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    ▼                               ▼
        ┌─────────────────────┐         ┌─────────────────────┐
        │   LOCAL STORAGE     │         │    LLM SERVICES     │
        │  ┌───────────────┐  │         │  ┌───────────────┐  │
        │  │    sqflite    │  │         │  │  langchain    │  │
        │  │   (SQLite)    │  │         │  │  (BYOK Mode)  │  │
        │  └───────────────┘  │         │  ├───────────────┤  │
        │  ┌───────────────┐  │         │  │  Clipboard +  │  │
        │  │secure_storage │  │         │  │  JSON Parser  │  │
        │  │  (API Keys)   │  │         │  │(Copy-Paste)   │  │
        │  └───────────────┘  │         │  └───────────────┘  │
        └─────────────────────┘         └─────────────────────┘
```

### 1.2 State Management: Riverpod

```dart
// State hierarchy
┌──────────────────────────────────────────────────────────────┐
│                    ProviderScope (App Root)                  │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Global Providers                                       │ │
│  │  • databaseProvider (sqflite instance)                  │ │
│  │  • settingsProvider (user preferences)                  │ │
│  │  • llmServiceProvider (BYOK/Copy-Paste mode)           │ │
│  └────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Feature Providers                                      │ │
│  │  • skillsProvider (skill list + CRUD)                   │ │
│  │  • tasksProvider (task list + filtering)                │ │
│  │  • practiceSessionProvider (active session state)       │ │
│  │  • progressProvider (analytics + charts)                │ │
│  │  • purposeProvider (Duckworth: purpose connection)      │ │
│  │  • struggleDiaryProvider (Duckworth: struggle notes)    │ │
│  └────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

---

## 2. Project Structure

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # MaterialApp configuration
│
├── core/                              # Shared infrastructure
│   ├── constants/
│   │   ├── app_constants.dart         # App-wide constants
│   │   ├── db_constants.dart          # Database table/column names
│   │   └── llm_constants.dart         # LLM prompt templates, schemas
│   │
│   ├── theme/
│   │   ├── app_theme.dart             # Light/dark theme definitions
│   │   ├── app_colors.dart            # Color palette (Material 3)
│   │   └── app_typography.dart        # Text styles
│   │
│   ├── utils/
│   │   ├── json_validator.dart        # LLM response validation
│   │   ├── date_utils.dart            # Date formatting helpers
│   │   └── extensions.dart            # Dart extensions
│   │
│   ├── errors/
│   │   ├── failures.dart              # Domain-level errors
│   │   └── exceptions.dart            # Data-level exceptions
│   │
│   └── router/
│       └── app_router.dart            # GoRouter configuration
│
├── data/                              # Data layer
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── database_helper.dart   # SQLite initialization
│   │   │   ├── skill_local_ds.dart    # Skill CRUD operations
│   │   │   ├── task_local_ds.dart     # Task CRUD operations
│   │   │   ├── session_local_ds.dart  # Practice session storage
│   │   │   ├── purpose_local_ds.dart  # Purpose statements (Duckworth)
│   │   │   └── struggle_local_ds.dart # Struggle diary entries (Duckworth)
│   │   │
│   │   └── llm/
│   │       ├── llm_service.dart       # Abstract LLM interface
│   │       ├── byok_llm_service.dart  # Direct API integration
│   │       └── clipboard_service.dart # Copy-paste workflow
│   │
│   ├── models/                        # Data Transfer Objects (DTOs)
│   │   ├── skill_dto.dart
│   │   ├── task_dto.dart
│   │   ├── session_dto.dart
│   │   ├── llm_response_dto.dart
│   │   └── purpose_dto.dart
│   │
│   └── repositories/                  # Repository implementations
│       ├── skill_repository_impl.dart
│       ├── task_repository_impl.dart
│       ├── practice_repository_impl.dart
│       └── llm_repository_impl.dart
│
├── domain/                            # Domain layer (business logic)
│   ├── entities/                      # Core business objects
│   │   ├── skill.dart
│   │   ├── sub_skill.dart
│   │   ├── task.dart
│   │   ├── practice_session.dart
│   │   ├── progress_data.dart
│   │   ├── purpose.dart               # Duckworth: purpose connection
│   │   └── struggle_entry.dart        # Duckworth: struggle diary
│   │
│   ├── repositories/                  # Repository interfaces
│   │   ├── skill_repository.dart
│   │   ├── task_repository.dart
│   │   ├── practice_repository.dart
│   │   └── llm_repository.dart
│   │
│   └── usecases/                      # Business logic
│       ├── skill/
│       │   ├── create_skill.dart
│       │   ├── analyze_skill_with_llm.dart
│       │   └── get_skill_progress.dart
│       ├── task/
│       │   ├── generate_tasks_with_llm.dart
│       │   ├── complete_task.dart
│       │   └── get_today_tasks.dart
│       ├── practice/
│       │   ├── start_session.dart
│       │   ├── complete_session.dart
│       │   └── record_struggle.dart   # Duckworth: struggle diary
│       └── progress/
│           ├── calculate_streak.dart
│           ├── get_analytics.dart
│           └── check_milestones.dart
│
├── features/                          # Feature modules (UI + State)
│   ├── onboarding/
│   │   ├── screens/
│   │   │   ├── welcome_screen.dart
│   │   │   ├── mode_selection_screen.dart
│   │   │   ├── skill_input_screen.dart
│   │   │   └── purpose_connection_screen.dart  # Duckworth: MVP critical
│   │   ├── widgets/
│   │   │   ├── mode_card.dart
│   │   │   └── purpose_category_chips.dart
│   │   └── providers/
│   │       └── onboarding_provider.dart
│   │
│   ├── home/
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   ├── widgets/
│   │   │   ├── purpose_reminder_card.dart     # Duckworth: purpose reminder
│   │   │   ├── streak_card.dart
│   │   │   ├── today_tasks_list.dart
│   │   │   └── quick_actions.dart
│   │   └── providers/
│   │       └── home_provider.dart
│   │
│   ├── skills/
│   │   ├── screens/
│   │   │   ├── skills_list_screen.dart
│   │   │   ├── skill_detail_screen.dart
│   │   │   └── add_skill_screen.dart
│   │   ├── widgets/
│   │   │   ├── skill_card.dart
│   │   │   ├── skill_tree_widget.dart
│   │   │   └── sub_skill_item.dart
│   │   └── providers/
│   │       └── skills_provider.dart
│   │
│   ├── llm_workflow/
│   │   ├── screens/
│   │   │   ├── copy_paste_flow_screen.dart
│   │   │   └── byok_setup_screen.dart
│   │   ├── widgets/
│   │   │   ├── prompt_preview.dart
│   │   │   ├── step_indicator.dart
│   │   │   ├── json_paste_field.dart
│   │   │   ├── validation_status.dart
│   │   │   └── llm_quick_links.dart
│   │   └── providers/
│   │       └── llm_workflow_provider.dart
│   │
│   ├── practice/
│   │   ├── screens/
│   │   │   ├── practice_session_screen.dart
│   │   │   └── session_complete_screen.dart
│   │   ├── widgets/
│   │   │   ├── session_timer.dart
│   │   │   ├── success_criteria_checklist.dart
│   │   │   ├── struggle_diary_input.dart      # Duckworth: struggle tracking
│   │   │   └── wise_feedback_card.dart        # Duckworth: wise feedback
│   │   └── providers/
│   │       └── practice_provider.dart
│   │
│   ├── progress/
│   │   ├── screens/
│   │   │   └── progress_screen.dart
│   │   ├── widgets/
│   │   │   ├── practice_time_chart.dart
│   │   │   ├── skill_breakdown_chart.dart
│   │   │   ├── milestone_list.dart
│   │   │   └── streak_calendar.dart
│   │   └── providers/
│   │       └── progress_provider.dart
│   │
│   └── settings/
│       ├── screens/
│       │   └── settings_screen.dart
│       ├── widgets/
│       │   ├── llm_config_section.dart
│       │   ├── notification_settings.dart
│       │   └── data_export_section.dart
│       └── providers/
│           └── settings_provider.dart
│
└── shared/                            # Shared UI components
    ├── widgets/
    │   ├── app_card.dart
    │   ├── progress_bar.dart
    │   ├── empty_state.dart           # Enhanced with hope messaging
    │   ├── loading_indicator.dart
    │   ├── error_view.dart
    │   └── confirmation_dialog.dart
    │
    └── animations/
        ├── fade_animation.dart
        └── scale_animation.dart

test/
├── unit/
│   ├── domain/
│   │   └── usecases/
│   ├── data/
│   │   └── repositories/
│   └── core/
│       └── utils/
├── widget/
│   ├── features/
│   │   └── [feature]_test.dart
│   └── shared/
└── integration/
    └── flows/
        ├── onboarding_flow_test.dart
        └── copy_paste_flow_test.dart
```

---

## 3. Database Schema

### 3.1 Entity Relationship Diagram

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│     users       │       │     skills      │       │   sub_skills    │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ id (PK)         │──┐    │ id (PK)         │───────│ id (PK)         │
│ created_at      │  │    │ user_id (FK)    │       │ skill_id (FK)   │
│ onboarding_done │  └───▶│ name            │       │ name            │
└─────────────────┘       │ description     │       │ description     │
                          │ current_level   │       │ current_level   │
                          │ purpose_id (FK) │       │ target_level    │
                          │ created_at      │       │ priority        │
                          │ updated_at      │       │ progress_pct    │
                          └────────┬────────┘       │ created_at      │
                                   │                └─────────────────┘
                                   │
                                   ▼
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│    purposes     │       │     tasks       │       │practice_sessions│
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ id (PK)         │       │ id (PK)         │◀──────│ id (PK)         │
│ skill_id (FK)   │       │ skill_id (FK)   │       │ task_id (FK)    │
│ statement       │       │ sub_skill_id(FK)│       │ started_at      │
│ category        │       │ title           │       │ completed_at    │
│ created_at      │       │ description     │       │ duration_secs   │
│ updated_at      │       │ duration_mins   │       │ notes           │
└─────────────────┘       │ frequency       │       │ rating          │
                          │ difficulty      │       │ created_at      │
                          │ success_criteria│       └─────────────────┘
                          │ is_completed    │
                          │ scheduled_date  │       ┌─────────────────┐
                          │ created_at      │       │ struggle_entries│
                          └─────────────────┘       ├─────────────────┤
                                                    │ id (PK)         │
┌─────────────────┐       ┌─────────────────┐       │ session_id (FK) │
│    settings     │       │   milestones    │       │ content         │
├─────────────────┤       ├─────────────────┤       │ wise_feedback   │
│ key (PK)        │       │ id (PK)         │       │ created_at      │
│ value           │       │ skill_id (FK)   │       └─────────────────┘
│ updated_at      │       │ title           │
└─────────────────┘       │ description     │       ┌─────────────────┐
                          │ target_value    │       │     streaks     │
                          │ current_value   │       ├─────────────────┤
                          │ achieved_at     │       │ id (PK)         │
                          │ created_at      │       │ skill_id (FK)   │
                          └─────────────────┘       │ current_count   │
                                                    │ longest_count   │
                                                    │ last_practice   │
                                                    │ updated_at      │
                                                    └─────────────────┘
```

### 3.2 SQL Schema

```sql
-- Core Tables

CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  onboarding_completed INTEGER DEFAULT 0
);

CREATE TABLE skills (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL DEFAULT 1,
  name TEXT NOT NULL,
  description TEXT,
  current_level TEXT CHECK(current_level IN ('beginner','intermediate','advanced','expert')) DEFAULT 'beginner',
  target_level TEXT CHECK(target_level IN ('beginner','intermediate','advanced','expert')),
  is_archived INTEGER DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE sub_skills (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  skill_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  current_level TEXT CHECK(current_level IN ('beginner','intermediate','advanced','expert')) DEFAULT 'beginner',
  target_level TEXT,
  priority TEXT CHECK(priority IN ('high','medium','low')) DEFAULT 'medium',
  progress_percent INTEGER DEFAULT 0 CHECK(progress_percent BETWEEN 0 AND 100),
  llm_generated INTEGER DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE
);

-- Duckworth Addition: Purpose Connection
CREATE TABLE purposes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  skill_id INTEGER NOT NULL UNIQUE,
  statement TEXT NOT NULL,  -- "I want to play guitar so I can..."
  category TEXT CHECK(category IN (
    'personal_expression',
    'connecting_with_others', 
    'career_growth',
    'self_improvement',
    'contributing_beyond_self',
    'other'
  )),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT,
  FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE
);

CREATE TABLE tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  skill_id INTEGER NOT NULL,
  sub_skill_id INTEGER,
  title TEXT NOT NULL,
  description TEXT,
  duration_minutes INTEGER DEFAULT 15,
  frequency TEXT CHECK(frequency IN ('daily','weekly','custom')) DEFAULT 'daily',
  difficulty INTEGER DEFAULT 5 CHECK(difficulty BETWEEN 1 AND 10),
  success_criteria TEXT,  -- JSON array of criteria
  is_completed INTEGER DEFAULT 0,
  scheduled_date TEXT,    -- For daily task scheduling
  completed_at TEXT,
  llm_generated INTEGER DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE,
  FOREIGN KEY (sub_skill_id) REFERENCES sub_skills(id) ON DELETE SET NULL
);

CREATE TABLE practice_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id INTEGER NOT NULL,
  started_at TEXT NOT NULL,
  completed_at TEXT,
  actual_duration_seconds INTEGER,
  notes TEXT,
  rating INTEGER CHECK(rating BETWEEN 1 AND 5),
  criteria_met TEXT,  -- JSON array of completed criteria
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
);

-- Duckworth Addition: Struggle Diary
CREATE TABLE struggle_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER NOT NULL,
  content TEXT NOT NULL,        -- User's struggle description
  wise_feedback TEXT,           -- Generated or template feedback
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (session_id) REFERENCES practice_sessions(id) ON DELETE CASCADE
);

CREATE TABLE streaks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  skill_id INTEGER NOT NULL UNIQUE,
  current_count INTEGER DEFAULT 0,
  longest_count INTEGER DEFAULT 0,
  last_practice_date TEXT,
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE
);

CREATE TABLE milestones (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  skill_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  milestone_type TEXT CHECK(milestone_type IN ('practice_time','task_count','streak','custom')),
  target_value INTEGER NOT NULL,
  current_value INTEGER DEFAULT 0,
  achieved_at TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE
);

CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Indexes for performance
CREATE INDEX idx_tasks_skill ON tasks(skill_id);
CREATE INDEX idx_tasks_scheduled ON tasks(scheduled_date);
CREATE INDEX idx_tasks_completed ON tasks(is_completed);
CREATE INDEX idx_sessions_task ON practice_sessions(task_id);
CREATE INDEX idx_sub_skills_skill ON sub_skills(skill_id);
CREATE INDEX idx_streaks_skill ON streaks(skill_id);
```

### 3.3 Default Settings

```sql
-- Initial settings values
INSERT INTO settings (key, value) VALUES 
  ('llm_mode', 'copy_paste'),           -- 'copy_paste' | 'byok'
  ('llm_provider', 'openai'),           -- 'openai' | 'anthropic' | 'google'
  ('theme_mode', 'system'),             -- 'light' | 'dark' | 'system'
  ('notification_enabled', 'true'),
  ('daily_reminder_time', '09:00'),
  ('show_purpose_reminder', 'true'),    -- Duckworth: show purpose on home
  ('streak_recovery_enabled', 'true');  -- Duckworth: no punishment for breaks
```

---

## 4. Core Components Design

### 4.1 LLM Service Architecture

```dart
// Abstract interface for LLM operations
abstract class LlmService {
  Future<LlmResult<SkillAnalysis>> analyzeSkill(SkillAnalysisRequest request);
  Future<LlmResult<List<Task>>> generateTasks(TaskGenerationRequest request);
  Future<LlmResult<WiseFeedback>> generateWiseFeedback(StruggleEntry entry);
}

// BYOK Implementation (Direct API)
class ByokLlmService implements LlmService {
  final ChatModel _chatModel;
  final PromptTemplates _templates;
  
  ByokLlmService({required String apiKey, required String provider}) {
    _chatModel = _createChatModel(apiKey, provider);
    _templates = PromptTemplates();
  }
  
  @override
  Future<LlmResult<SkillAnalysis>> analyzeSkill(SkillAnalysisRequest request) async {
    final prompt = _templates.skillAnalysis(
      skillName: request.skillName,
      context: request.userContext,
    );
    
    try {
      final response = await _chatModel.invoke([HumanChatMessage(content: prompt)]);
      final parsed = _parseSkillAnalysis(response.content);
      return LlmResult.success(parsed);
    } catch (e) {
      return LlmResult.failure(LlmError.apiError(e.toString()));
    }
  }
}

// Copy-Paste Implementation
class CopyPasteLlmService implements LlmService {
  final ClipboardService _clipboard;
  final JsonValidator _validator;
  
  // Returns prompt for user to copy
  String getSkillAnalysisPrompt(SkillAnalysisRequest request) {
    return PromptTemplates.skillAnalysis(
      skillName: request.skillName,
      context: request.userContext,
    );
  }
  
  // Validates and parses pasted response
  @override
  Future<LlmResult<SkillAnalysis>> analyzeSkill(SkillAnalysisRequest request) async {
    throw UnimplementedError('Use processClipboardResponse instead');
  }
  
  Future<LlmResult<SkillAnalysis>> processClipboardResponse(String jsonResponse) async {
    final validationResult = _validator.validateSkillAnalysis(jsonResponse);
    if (!validationResult.isValid) {
      return LlmResult.failure(LlmError.validationError(validationResult.errors));
    }
    
    try {
      final parsed = SkillAnalysis.fromJson(jsonDecode(jsonResponse));
      return LlmResult.success(parsed);
    } catch (e) {
      return LlmResult.failure(LlmError.parseError(e.toString()));
    }
  }
}

// Result wrapper
sealed class LlmResult<T> {
  const LlmResult();
  factory LlmResult.success(T data) = LlmSuccess<T>;
  factory LlmResult.failure(LlmError error) = LlmFailure<T>;
}

class LlmSuccess<T> extends LlmResult<T> {
  final T data;
  const LlmSuccess(this.data);
}

class LlmFailure<T> extends LlmResult<T> {
  final LlmError error;
  const LlmFailure(this.error);
}
```

### 4.2 Prompt Templates

```dart
class PromptTemplates {
  static const String _jsonInstructions = '''
CRITICAL: Respond with ONLY valid JSON. No markdown, no explanation, no code blocks.
Start your response with { and end with }
''';

  static String skillAnalysis({
    required String skillName,
    required String userContext,
    String? purposeStatement,
  }) => '''
You are a deliberate practice expert trained in Anders Ericsson's methodology.

TASK: Analyze the following skill and break it down into learnable sub-skills.

SKILL: $skillName
USER CONTEXT: $userContext
${purposeStatement != null ? 'PURPOSE: $purposeStatement' : ''}

$_jsonInstructions

{
  "type": "skill_analysis",
  "version": "1.0",
  "data": {
    "skill": {
      "name": "$skillName",
      "description": "Brief description of the skill",
      "estimatedTimeToCompetency": "e.g., 3-6 months",
      "subSkills": [
        {
          "id": "sub_001",
          "name": "Sub-skill name",
          "description": "What this involves",
          "currentLevel": "beginner",
          "priority": "high|medium|low",
          "estimatedHours": 20,
          "prerequisites": []
        }
      ]
    }
  }
}

REQUIREMENTS:
- Generate 4-7 sub-skills
- Order by learning sequence (prerequisites first)
- Prioritize by impact on overall skill
- Be specific and actionable
- Consider the user's stated purpose when prioritizing
''';

  static String taskGeneration({
    required String skillName,
    required String subSkillName,
    required String currentLevel,
    String? recentStruggle,
  }) => '''
You are a deliberate practice coach. Generate specific, measurable practice tasks.

SKILL: $skillName
SUB-SKILL: $subSkillName  
CURRENT LEVEL: $currentLevel
${recentStruggle != null ? 'RECENT STRUGGLE: $recentStruggle (address this in tasks)' : ''}

$_jsonInstructions

{
  "type": "task_generation",
  "version": "1.0",
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

  // Duckworth Addition: Wise Feedback Generation
  static String wiseFeedback({
    required String skillName,
    required String struggleDescription,
    required String taskTitle,
  }) => '''
You are a wise mentor providing feedback to a learner.

CONTEXT:
- Skill being practiced: $skillName
- Task attempted: $taskTitle
- Struggle reported: $struggleDescription

Your feedback must embody "wise feedback" as defined by research:
1. Express HIGH STANDARDS - This is challenging work
2. Express BELIEF IN THEIR ABILITY - You can reach these standards

$_jsonInstructions

{
  "type": "wise_feedback",
  "version": "1.0",
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
```

### 4.3 State Management with Riverpod

```dart
// providers/app_providers.dart

// Database provider
@riverpod
Future<Database> database(DatabaseRef ref) async {
  return await DatabaseHelper.initialize();
}

// Settings provider
@riverpod
class Settings extends _$Settings {
  @override
  Future<AppSettings> build() async {
    final db = await ref.watch(databaseProvider.future);
    return SettingsRepository(db).loadSettings();
  }
  
  Future<void> updateLlmMode(LlmMode mode) async {
    final db = await ref.watch(databaseProvider.future);
    await SettingsRepository(db).saveSetting('llm_mode', mode.name);
    ref.invalidateSelf();
  }
}

// LLM Service provider (switches based on mode)
@riverpod
LlmService llmService(LlmServiceRef ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  
  if (settings?.llmMode == LlmMode.byok) {
    final apiKey = ref.watch(apiKeyProvider).valueOrNull;
    if (apiKey != null) {
      return ByokLlmService(
        apiKey: apiKey,
        provider: settings!.llmProvider,
      );
    }
  }
  
  return CopyPasteLlmService();
}

// Skills provider
@riverpod
class Skills extends _$Skills {
  @override
  Future<List<Skill>> build() async {
    final db = await ref.watch(databaseProvider.future);
    return SkillRepository(db).getAllSkills();
  }
  
  Future<void> createSkill(CreateSkillRequest request) async {
    final db = await ref.watch(databaseProvider.future);
    await SkillRepository(db).createSkill(request);
    ref.invalidateSelf();
  }
  
  Future<void> importLlmAnalysis(SkillAnalysis analysis) async {
    final db = await ref.watch(databaseProvider.future);
    await SkillRepository(db).createSkillFromAnalysis(analysis);
    ref.invalidateSelf();
  }
}

// Today's tasks provider
@riverpod
Future<List<Task>> todayTasks(TodayTasksRef ref) async {
  final db = await ref.watch(databaseProvider.future);
  final today = DateTime.now().toDateString();
  return TaskRepository(db).getTasksForDate(today);
}

// Active practice session provider
@riverpod
class PracticeSession extends _$PracticeSession {
  @override
  PracticeSessionState build() {
    return PracticeSessionState.idle();
  }
  
  void startSession(Task task) {
    state = PracticeSessionState.active(
      task: task,
      startTime: DateTime.now(),
      elapsedSeconds: 0,
    );
    _startTimer();
  }
  
  Future<void> completeSession({
    String? notes,
    String? struggleEntry,
    int? rating,
  }) async {
    if (state is! ActivePracticeSession) return;
    
    final activeState = state as ActivePracticeSession;
    final db = await ref.read(databaseProvider.future);
    
    // Save session
    final sessionId = await PracticeRepository(db).saveSession(
      taskId: activeState.task.id,
      duration: activeState.elapsedSeconds,
      notes: notes,
      rating: rating,
    );
    
    // Save struggle entry if provided (Duckworth addition)
    if (struggleEntry != null && struggleEntry.isNotEmpty) {
      await StruggleRepository(db).saveEntry(
        sessionId: sessionId,
        content: struggleEntry,
      );
      
      // Generate wise feedback
      final llm = ref.read(llmServiceProvider);
      if (llm is ByokLlmService) {
        final feedback = await llm.generateWiseFeedback(
          StruggleEntry(
            sessionId: sessionId,
            content: struggleEntry,
            skillName: activeState.task.skillName,
            taskTitle: activeState.task.title,
          ),
        );
        // Store feedback for display
      }
    }
    
    // Update streak
    await ref.read(streakProvider(activeState.task.skillId).notifier).recordPractice();
    
    state = PracticeSessionState.completed(sessionId: sessionId);
    ref.invalidate(todayTasksProvider);
  }
}

// Purpose provider (Duckworth addition)
@riverpod
class Purpose extends _$Purpose {
  @override
  Future<Purpose?> build(int skillId) async {
    final db = await ref.watch(databaseProvider.future);
    return PurposeRepository(db).getPurposeForSkill(skillId);
  }
  
  Future<void> savePurpose({
    required String statement,
    required PurposeCategory category,
  }) async {
    final db = await ref.watch(databaseProvider.future);
    await PurposeRepository(db).savePurpose(
      skillId: arg,  // skillId from build parameter
      statement: statement,
      category: category,
    );
    ref.invalidateSelf();
  }
}

// Streak provider with recovery (Duckworth addition: no punishment)
@riverpod
class Streak extends _$Streak {
  @override
  Future<StreakData> build(int skillId) async {
    final db = await ref.watch(databaseProvider.future);
    return StreakRepository(db).getStreak(skillId);
  }
  
  Future<void> recordPractice() async {
    final db = await ref.watch(databaseProvider.future);
    final current = await future;
    
    final today = DateTime.now().toDateString();
    final yesterday = DateTime.now().subtract(Duration(days: 1)).toDateString();
    
    int newCount;
    if (current.lastPracticeDate == yesterday) {
      // Continuing streak
      newCount = current.currentCount + 1;
    } else if (current.lastPracticeDate == today) {
      // Already practiced today
      newCount = current.currentCount;
    } else {
      // Streak broken, but we recover gracefully (Duckworth)
      newCount = 1;
    }
    
    await StreakRepository(db).updateStreak(
      skillId: arg,
      currentCount: newCount,
      longestCount: max(newCount, current.longestCount),
      lastPracticeDate: today,
    );
    
    ref.invalidateSelf();
  }
}
```

### 4.4 Navigation with GoRouter

```dart
// core/router/app_router.dart

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final container = ProviderScope.containerOf(context);
    final settings = await container.read(settingsProvider.future);
    
    // Redirect to onboarding if not completed
    if (!settings.onboardingCompleted && state.matchedLocation != '/onboarding') {
      return '/onboarding';
    }
    return null;
  },
  routes: [
    // Onboarding flow
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const WelcomeScreen(),
      routes: [
        GoRoute(
          path: 'mode',
          builder: (context, state) => const ModeSelectionScreen(),
        ),
        GoRoute(
          path: 'skill',
          builder: (context, state) => const SkillInputScreen(),
        ),
        GoRoute(
          path: 'purpose',  // Duckworth: MVP critical
          builder: (context, state) => const PurposeConnectionScreen(),
        ),
        GoRoute(
          path: 'analyze',
          builder: (context, state) => const CopyPasteFlowScreen(),
        ),
      ],
    ),
    
    // Main app shell with bottom navigation
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/skills',
          builder: (context, state) => const SkillsListScreen(),
          routes: [
            GoRoute(
              path: ':skillId',
              builder: (context, state) {
                final skillId = int.parse(state.pathParameters['skillId']!);
                return SkillDetailScreen(skillId: skillId);
              },
            ),
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddSkillScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/practice',
          builder: (context, state) => const PracticeScreen(),
          routes: [
            GoRoute(
              path: 'session/:taskId',
              builder: (context, state) {
                final taskId = int.parse(state.pathParameters['taskId']!);
                return PracticeSessionScreen(taskId: taskId);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: 'llm',
              builder: (context, state) => const LlmConfigScreen(),
            ),
            GoRoute(
              path: 'byok',
              builder: (context, state) => const ByokSetupScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
```

---

## 5. Implementation Phases

### Phase 1: Foundation (Weeks 1-3)

**Goal**: Core infrastructure and basic skill management

| Week | Tasks | Deliverables |
|------|-------|--------------|
| 1 | Project setup, database schema, core models | Running app shell with SQLite |
| 2 | Skill CRUD, basic UI components, navigation | Skills list and detail screens |
| 3 | Purpose connection screen, settings foundation | Onboarding flow complete |

**Key Features**:
- [ ] Project structure with Clean Architecture
- [ ] Database initialization with migrations
- [ ] Skill entity CRUD operations
- [ ] Sub-skill management
- [ ] Purpose connection screen (Duckworth MVP)
- [ ] Basic theme and component library
- [ ] GoRouter navigation setup
- [ ] Riverpod state management foundation

### Phase 2: Copy-Paste LLM Workflow (Weeks 4-5)

**Goal**: Complete copy-paste workflow for AI integration

| Week | Tasks | Deliverables |
|------|-------|--------------|
| 4 | Prompt templates, clipboard service, JSON validation | Copy prompt flow |
| 5 | Paste & parse flow, error handling, skill import | Full copy-paste workflow |

**Key Features**:
- [ ] Prompt template system
- [ ] Copy to clipboard functionality
- [ ] JSON response validation
- [ ] Error handling with user guidance
- [ ] Import LLM analysis into database
- [ ] Generate tasks from LLM

### Phase 3: Practice Sessions (Weeks 6-7)

**Goal**: Task management and practice session tracking

| Week | Tasks | Deliverables |
|------|-------|--------------|
| 6 | Task list, scheduling, session timer | Today's tasks, session screen |
| 7 | Session completion, struggle diary, streak tracking | Complete practice flow |

**Key Features**:
- [ ] Today's tasks view
- [ ] Practice session screen with timer
- [ ] Success criteria checklist
- [ ] Struggle diary input (Duckworth)
- [ ] Session completion with notes
- [ ] Basic streak tracking
- [ ] Streak recovery (no punishment - Duckworth)

### Phase 4: Progress & Analytics (Weeks 8-9)

**Goal**: Visual progress tracking and motivation

| Week | Tasks | Deliverables |
|------|-------|--------------|
| 8 | Practice time charts, skill breakdown, milestones | Progress screen |
| 9 | Home dashboard, purpose reminder, wise feedback | Polished home experience |

**Key Features**:
- [ ] Practice time line chart
- [ ] Skill breakdown pie/bar chart
- [ ] Milestone tracking and celebration
- [ ] Home dashboard with purpose reminder (Duckworth)
- [ ] Streak display with recovery messaging
- [ ] Wise feedback display (template-based initially)

### Phase 5: BYOK Integration (Week 10)

**Goal**: Direct LLM API integration for power users

| Week | Tasks | Deliverables |
|------|-------|--------------|
| 10 | API key storage, langchain integration, provider switching | BYOK mode |

**Key Features**:
- [ ] Secure API key storage
- [ ] OpenAI integration via langchain_dart
- [ ] Provider selection (OpenAI, Anthropic)
- [ ] Seamless mode switching
- [ ] Real-time wise feedback generation (Duckworth)

### Phase 6: Polish & Testing (Weeks 11-12)

**Goal**: Quality assurance and release preparation

| Week | Tasks | Deliverables |
|------|-------|--------------|
| 11 | Unit tests, widget tests, bug fixes | Test coverage >70% |
| 12 | Integration tests, performance optimization, release prep | Release candidate |

**Key Features**:
- [ ] Unit tests for all use cases
- [ ] Widget tests for critical flows
- [ ] Integration tests for onboarding and practice flows
- [ ] Performance profiling and optimization
- [ ] Error logging and crash reporting
- [ ] Release build configuration

---

## 6. Dependencies

### pubspec.yaml

```yaml
name: deliberate_practice_app
description: AI-powered skill development through deliberate practice

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # Navigation
  go_router: ^12.0.0
  
  # Local Storage
  sqflite: ^2.3.0
  path: ^1.8.0
  flutter_secure_storage: ^9.0.0
  
  # LLM Integration
  langchain: ^0.7.0
  langchain_openai: ^0.7.0
  openai_dart: ^0.4.0
  
  # Charts
  fl_chart: ^0.68.0
  
  # UI Components
  flutter_svg: ^2.0.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  
  # Utilities
  intl: ^0.18.0
  uuid: ^4.2.0
  collection: ^1.18.0
  equatable: ^2.0.0
  json_annotation: ^4.8.0
  
  # Dev UX
  flutter_native_splash: ^2.3.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  
  # Code Generation
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  json_serializable: ^6.7.0
  go_router_builder: ^2.4.0
  
  # Testing
  mocktail: ^1.0.0
  
flutter:
  uses-material-design: true
  
  assets:
    - assets/icons/
    - assets/images/
```

---

## 7. Risk Assessment & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| LLM response quality varies | Medium | Medium | Template optimization, validation, graceful degradation |
| JSON parsing failures | Medium | Low | Robust error handling, clear user instructions, retry options |
| Skill tree complexity | Low | Medium | Start simple, iterate based on feedback |
| Performance with large datasets | Low | Medium | Pagination, lazy loading, SQLite indexes |
| API key security | Low | High | flutter_secure_storage, no logging of keys |
| User drops off during copy-paste | Medium | High | Clear instructions, progress indicators, remember state |

---

## 8. Testing Strategy

### Unit Tests (Priority: High)

```
test/unit/
├── domain/usecases/
│   ├── create_skill_test.dart
│   ├── generate_tasks_test.dart
│   └── calculate_streak_test.dart
├── data/repositories/
│   ├── skill_repository_test.dart
│   └── task_repository_test.dart
└── core/utils/
    └── json_validator_test.dart
```

### Widget Tests (Priority: Medium)

```
test/widget/
├── features/
│   ├── onboarding/
│   │   ├── welcome_screen_test.dart
│   │   └── purpose_connection_screen_test.dart
│   ├── home/
│   │   └── home_screen_test.dart
│   └── llm_workflow/
│       └── copy_paste_flow_test.dart
└── shared/
    └── widgets/
        └── progress_bar_test.dart
```

### Integration Tests (Priority: High)

```
test/integration/
├── onboarding_flow_test.dart      # Full onboarding including purpose
├── copy_paste_workflow_test.dart  # Critical path
├── practice_session_test.dart     # Session with struggle diary
└── streak_recovery_test.dart      # Duckworth: no punishment
```

---

## 9. Architecture Decision Records (ADRs)

### ADR-001: Clean Architecture with Feature-First Structure

**Status**: Accepted

**Context**: Need maintainable, testable codebase that can scale

**Decision**: Use Clean Architecture (Domain/Data/Presentation) with feature-first folder organization

**Consequences**:
- (+) Clear separation of concerns
- (+) Easy to test business logic
- (+) Features are self-contained
- (-) More boilerplate initially
- (-) Learning curve for new developers

### ADR-002: Riverpod over Bloc/Provider

**Status**: Accepted

**Context**: Need state management solution for complex app state

**Decision**: Use Riverpod with code generation

**Consequences**:
- (+) Compile-time safety
- (+) Better testability
- (+) No BuildContext dependency
- (+) Automatic disposal
- (-) Requires code generation
- (-) Newer, less community resources

### ADR-003: Copy-Paste as Default LLM Mode

**Status**: Accepted

**Context**: Most users don't have API keys; need accessible AI experience

**Decision**: Make copy-paste workflow the default, BYOK as optional upgrade

**Consequences**:
- (+) Zero barrier to entry
- (+) Works with any LLM (ChatGPT, Claude, Gemini, etc.)
- (+) No API costs for users
- (-) More friction than direct integration
- (-) Risk of user drop-off during flow

### ADR-004: Purpose Connection as MVP Feature

**Status**: Accepted (Duckworth Review)

**Context**: Grit research shows purpose is critical for sustained effort

**Decision**: Include purpose connection screen in Phase 1 MVP, not optional

**Consequences**:
- (+) Stronger user engagement foundation
- (+) Differentiation from productivity apps
- (+) Aligned with deliberate practice research
- (-) Adds complexity to onboarding
- (-) Some users may skip

### ADR-005: SQLite over Hive/Isar

**Status**: Accepted

**Context**: Need local storage with relational queries for skills/tasks

**Decision**: Use sqflite for all persistent storage

**Consequences**:
- (+) Relational queries for complex data
- (+) Mature, well-documented
- (+) Easy backup/export
- (-) More verbose than NoSQL
- (-) Schema migrations required

---

## 10. Success Metrics

### Technical Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Test Coverage | >70% | CI reports |
| JSON Parse Success | >95% | Analytics |
| Cold Start Time | <2s | Performance tests |
| Session Crash Rate | <0.1% | Crash reporting |
| Build Time (CI) | <5min | GitHub Actions |

### User Experience Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Onboarding Completion | >80% | Analytics funnel |
| Copy-Paste Success | >90% | Step completion |
| Daily Task Completion | >50% | Database queries |
| 7-Day Retention | >40% | Analytics |
| Purpose Statement Set | >60% | Database queries |

---

## Appendix A: Wise Feedback Templates

For Phase 4 (before BYOK enables dynamic generation):

```dart
const wiseFeedbackTemplates = {
  'timing_struggle': WiseFeedback(
    acknowledgment: 'Timing is genuinely one of the hardest aspects to master.',
    normalization: 'Even professional musicians spend years refining their sense of timing.',
    reframe: 'The fact that you notice timing issues shows your ear is developing.',
    encouragement: 'You have what it takes to develop solid timing.',
    suggestion: 'Try practicing with a metronome at a slower tempo.',
  ),
  'coordination_struggle': WiseFeedback(
    acknowledgment: 'Coordinating multiple movements at once is challenging.',
    normalization: 'This is exactly the kind of struggle that builds neural pathways.',
    reframe: 'Your brain is literally rewiring itself right now.',
    encouragement: 'Persistence through this difficulty is what separates masters from beginners.',
    suggestion: 'Break the movement into smaller parts and practice each separately.',
  ),
  'memory_struggle': WiseFeedback(
    acknowledgment: 'Remembering sequences while executing them is cognitively demanding.',
    normalization: 'Memory consolidation happens during sleep—you may find it easier tomorrow.',
    reframe: 'Each attempt strengthens the memory trace, even if it doesn\'t feel like it.',
    encouragement: 'Your working memory will expand with consistent practice.',
    suggestion: 'Try chunking the sequence into smaller memorable groups.',
  ),
  'general': WiseFeedback(
    acknowledgment: 'What you\'re experiencing is a normal part of deliberate practice.',
    normalization: 'Struggle is not a sign of inadequacy—it\'s a sign of growth happening.',
    reframe: 'This difficulty means you\'re working at the edge of your ability.',
    encouragement: 'I have high standards for you because I believe you can reach them.',
    suggestion: 'Focus on one small improvement at a time.',
  ),
};
```

---

## Appendix B: Empty State Messaging (Duckworth-Informed)

```dart
const emptyStateMessages = {
  'no_skills': EmptyState(
    title: 'Your journey begins here',
    message: 'Every expert was once a beginner. What skill will you master?',
    actionLabel: 'Add Your First Skill',
  ),
  'no_tasks_today': EmptyState(
    title: 'No practice scheduled',
    message: 'Rest is part of growth. Or, add a task if you\'re ready.',
    actionLabel: 'Add a Task',
  ),
  'streak_broken': EmptyState(
    title: 'Welcome back',
    message: 'Breaks happen to everyone. What matters is that you returned. Ready to start fresh?',
    actionLabel: 'Start Practicing',
  ),
  'no_progress_yet': EmptyState(
    title: 'Progress takes time',
    message: 'The chart will fill in as you practice. Consistency matters more than intensity.',
    actionLabel: 'Start Your First Session',
  ),
};
```

---

*This architecture document is a living artifact. Update as implementation progresses and requirements evolve.*
