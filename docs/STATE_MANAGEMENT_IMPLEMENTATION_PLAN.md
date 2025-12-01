# State Management & Data Tracking Implementation Plan

## Current Status Analysis

### ✅ What's Implemented
- Practice session entity and repository layer
- Database schema for tracking
- Basic providers for practice data
- Practice session start/complete logic
- Streak tracking structure
- Progress data entities

### ❌ What's Missing (TODOs)
1. **Progress Calculation**
   - Skill progress percentage calculation
   - Sub-skill progress tracking
   - Daily progress data aggregation

2. **Task Completion Tracking**
   - Tasks completed per skill
   - Tasks completed per day
   - Completion rate calculations

3. **Practice Time Aggregation**
   - Total practice time per skill (partially done)
   - Practice time tracking and display
   - Time-based statistics and trends

4. **Streak Management**
   - Streak calculation logic
   - Streak recovery system (Duckworth)
   - Streak display and motivation

5. **Milestone System**
   - Milestone tracking and achievement
   - Milestone progress updates
   - Achievement notifications

6. **Analytics & Reporting**
   - Weekly/monthly summaries
   - Performance trends
   - Sub-skill progress breakdown

## Implementation Plan

### Phase 1: Progress Calculation (Hours 1-2)
**Goal:** Calculate and track all progress metrics

#### 1.1 Skill Progress Calculation
- Calculate: `(completed_tasks / total_tasks) * 100`
- Add `getSkillProgress()` to PracticeRepository
- Add `skillProgressProvider` to practice_provider.dart
- Use in progress_screen.dart

#### 1.2 Practice Time Tracking
- Aggregate practice time per skill
- Implement `getPracticeTimeForSkill(skillId)`
- Display in skill cards and progress screen

#### 1.3 Sub-Skill Progress
- Calculate sub-skill progress based on related tasks
- Implement `getSubSkillProgress(subSkillId)`
- Show in skill detail screen

### Phase 2: Daily Statistics (Hours 2-3)
**Goal:** Track daily metrics for charts

#### 2.1 Daily Progress Data
- Create daily aggregates: tasks completed, practice time
- Implement `getDailyProgress(skillId, date)`
- Generate 30-day history for charts

#### 2.2 Task Completion Stats
- Tasks completed today per skill
- Tasks completed this week
- Completion rate trends

### Phase 3: Streak & Motivation (Hours 3-4)
**Goal:** Implement streak system with Duckworth recovery

#### 3.1 Streak Calculation
- Count consecutive days of practice
- Implement streak recovery (1-2 day grace period)
- Update streak on session completion

#### 3.2 Milestone Tracking
- Create milestone provider
- Implement achievement detection
- Update milestone progress

### Phase 4: UI Integration (Hours 4-5)
**Goal:** Display all calculated metrics

#### 4.1 Progress Screen
- Show real practice time vs estimated
- Display skill progress bars
- Show daily breakdown chart
- Show streaks and milestones

#### 4.2 Home Screen
- Show today's practice time
- Show tasks completed count
- Show current streaks

#### 4.3 Skill Detail Screen
- Show skill progress percentage
- Show practice time invested
- Show sub-skill progress breakdown
- Show achievements/milestones

## Database Changes Needed

### New Queries
```sql
-- Total completed tasks for a skill
SELECT COUNT(*) FROM tasks 
WHERE skill_id = ? AND is_completed = 1

-- Total practice time for a skill
SELECT SUM(actual_duration_seconds) FROM practice_sessions
JOIN tasks ON practice_sessions.task_id = tasks.id
WHERE tasks.skill_id = ? AND practice_sessions.completed_at IS NOT NULL

-- Daily stats for skill
SELECT 
  DATE(completed_at) as day,
  COUNT(*) as tasks_completed,
  SUM(actual_duration_seconds) as total_seconds
FROM practice_sessions
JOIN tasks ON practice_sessions.task_id = tasks.id
WHERE tasks.skill_id = ? 
  AND practice_sessions.completed_at IS NOT NULL
GROUP BY DATE(completed_at)
ORDER BY day DESC

-- Streak calculation
SELECT COUNT(DISTINCT DATE(recorded_at)) 
FROM practice_streaks
WHERE skill_id = ? 
  AND recorded_at >= DATE('now', '-30 days')
```

## Data Structures to Add

### ProgressCalculation
```dart
class ProgressCalculation {
  final int tasksCompleted;
  final int tasksTotal;
  final double progressPercent;
  final int practiceMinutes;
  final int currentStreak;
  final List<DailyProgress> dailyHistory;
}
```

### DailyProgress
```dart
class DailyProgress {
  final DateTime date;
  final int tasksCompleted;
  final int practiceMinutes;
}
```

## Implementation Order
1. Add repository methods for calculations
2. Create/update providers
3. Update practice_session completion logic
4. Add UI widgets to display metrics
5. Connect all pieces in screens
6. Test with sample data
7. Optimize queries

## Success Criteria
- ✓ Progress percentages calculated accurately
- ✓ Practice time tracked for each skill
- ✓ Daily statistics aggregated correctly
- ✓ Streaks calculated with recovery
- ✓ All TODOs replaced with working code
- ✓ UI displays real data (not 0.0 placeholders)
- ✓ Tests passing for all calculations
