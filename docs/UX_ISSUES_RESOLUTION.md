# UX Issues Resolution Design

---
**Created**: November 30, 2025  
**Designer**: @experience-designer agent  
**Version**: 1.0  
**Status**: Design Specification  
**Related Documents**: [UX_DESIGN.md](./UX_DESIGN.md), [VISION.md](./VISION.md)  

---

## Executive Summary

This document addresses 6 critical UX issues identified during user testing:

| Issue # | Problem | Severity | Solution |
|---------|---------|----------|----------|
| 1 | Welcome screen shows every time | High | Implement first-time-only onboarding check |
| 2 | Prompt lacks Skills/Tasks context | High | Enrich prompts with existing data context |
| 3 | JSON pasting from LLM not working | Critical | Improve JSON parsing & error recovery |
| 4 | Clipboard data loss during app switching | High | Use Android Intent sharing |
| 5 | Back navigation broken for Generate Task | Medium | Fix navigation stack handling |
| 6 | Purpose management not implemented | Medium | Design full Purpose CRUD screens |

---

## Issue 1: Welcome Screen Shows Every Time

### Current Behavior
The onboarding screen appears every time the app is opened, even for returning users.

### Root Cause Analysis
The `onboardingCompleted` flag is being read correctly from settings, but either:
1. The flag is not being properly persisted after completion
2. The initial redirect logic has a timing issue with async state loading

### UX Solution: First-Time Detection Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      APP LAUNCH                              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ Check local DB  │
                    │ onboarding_     │
                    │ completed flag  │
                    └─────────────────┘
                              │
              ┌───────────────┴───────────────┐
              │                               │
              ▼                               ▼
       Flag = TRUE                     Flag = FALSE/NULL
              │                               │
              ▼                               ▼
    ┌─────────────────┐             ┌─────────────────┐
    │   Go to Home    │             │  Show Welcome   │
    │   Screen        │             │  Screen         │
    └─────────────────┘             └─────────────────┘
                                              │
                                              ▼
                                    ┌─────────────────┐
                                    │  User completes │
                                    │  onboarding     │
                                    └─────────────────┘
                                              │
                                              ▼
                                    ┌─────────────────┐
                                    │ Set flag = TRUE │
                                    │ Navigate home   │
                                    └─────────────────┘
```

### Implementation Requirements

1. **Splash/Loading Screen**: Add a brief splash while checking onboarding status
2. **Synchronous Check**: Ensure the check completes before navigation decision
3. **Persistent Storage**: Use SQLite (already in use) for reliable persistence
4. **Reset Option**: Add "Reset Onboarding" in Settings for debugging/fresh start

### Design Specification

```
┌──────────────────────────────────────────────────────────────┐
│                      SPLASH SCREEN                           │
│                                                              │
│                    🎯 Prompt Loop                            │
│                                                              │
│                   ○ ○ ○ (loading dots)                       │
│                                                              │
│                                                              │
└──────────────────────────────────────────────────────────────┘
Duration: Max 1 second (or until DB check completes)
```

---

## Issue 2: Prompt Lacks Skills/Tasks Context

### Current Behavior
Generated prompts don't include user's existing skills, sub-skills, tasks, or purpose statements. This makes LLM responses generic and disconnected from the user's practice journey.

### Root Cause Analysis
The `_generateTaskPrompt()` method creates a static prompt without querying the user's data context.

### UX Solution: Context-Enriched Prompts

#### Information to Include in Prompts

| Data Type | Why Important | Example |
|-----------|---------------|---------|
| Skills | Provides domain context | "Guitar playing (Intermediate)" |
| Sub-skills | Shows current focus areas | "Chord transitions, Fingerpicking, Rhythm" |
| Recent Tasks | Shows practice history | "Last practiced: 'Chord changes between G-C-D'" |
| Purpose | Provides motivation context | "To write songs that express emotions" |
| Struggles | Identifies pain points | "Difficulty with barre chords" |

#### Enhanced Prompt Template Structure

```
┌──────────────────────────────────────────────────────────────┐
│              CONTEXT-AWARE PROMPT GENERATION                 │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  📋 Generated Prompt (preview)                         │ │
│  │                                                        │ │
│  │  You are a deliberate practice coach.                  │ │
│  │                                                        │ │
│  │  USER CONTEXT:                                         │ │
│  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │ │
│  │  Skill: Guitar playing                                 │ │
│  │  Level: Intermediate (practicing for 6 months)         │ │
│  │  Purpose: "To write songs that express what I can't    │ │
│  │            say in words"                               │ │
│  │                                                        │ │
│  │  SUB-SKILLS IN PROGRESS:                              │ │
│  │  • Chord transitions (High priority) - 15 hrs logged  │ │
│  │  • Fingerpicking patterns (Medium) - 8 hrs logged     │ │
│  │  • Strumming rhythm (High) - 12 hrs logged            │ │
│  │                                                        │ │
│  │  RECENT TASKS COMPLETED:                              │ │
│  │  • "Practice G-C-D chord changes" (completed 3x)      │ │
│  │  • "Fingerpick 'Dust in the Wind' intro" (in progress)│ │
│  │                                                        │ │
│  │  CURRENT STRUGGLE:                                     │ │
│  │  "Barre chords still feel impossible - my index       │ │
│  │   finger can't press all strings cleanly"             │ │
│  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │ │
│  │                                                        │ │
│  │  Generate 3-5 practice tasks that:                     │ │
│  │  • Build on current progress                          │ │
│  │  • Address the stated struggle                        │ │
│  │  • Connect to the user's purpose                      │ │
│  │  ...                                                  │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ℹ️ This prompt includes your skill context to help          │
│     the AI generate more relevant practice tasks.            │
│                                                              │
│              [📋 Copy Prompt]                                │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

#### Data Model for Prompt Context

```dart
class PromptContext {
  final Skill skill;
  final List<SubSkill> subSkills;
  final Purpose? purpose;
  final List<Task> recentTasks;
  final List<StruggleEntry>? recentStruggles;
  
  String toPromptSection() {
    // Generate formatted context string
  }
}
```

---

## Issue 3: JSON Pasting from LLM Not Working

### Current Behavior
Valid JSON from LLM responses fails to parse, even when the JSON structure is correct.

### Root Cause Analysis
Common LLM response issues:
1. **Markdown wrapping**: LLMs often wrap JSON in ```json ... ``` code blocks
2. **Extra text**: LLMs add explanations before/after JSON
3. **Unicode issues**: Smart quotes or special characters
4. **Whitespace**: Leading/trailing whitespace or BOM characters

### UX Solution: Robust JSON Extraction & Validation

#### Multi-Stage Parsing Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│                   PASTE AI RESPONSE                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  [Paste from Clipboard]                                │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│                         ▼                                   │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  🔍 VALIDATION STATUS                                  │ │
│  │                                                        │ │
│  │  Step 1: Extract JSON  ✓ Found JSON block              │ │
│  │  Step 2: Parse JSON    ✓ Valid syntax                  │ │
│  │  Step 3: Validate      ✓ Schema matches                │ │
│  │  Step 4: Extract data  ✓ Found 4 tasks                 │ │
│  │                                                        │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│              [✓ Import Tasks]                                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

#### Error Recovery UI

```
┌──────────────────────────────────────────────────────────────┐
│  ⚠️ JSON Parsing Issue                                       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  We detected some issues with the AI response:               │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  ❌ Problem: Response wrapped in markdown                │ │
│  │                                                        │ │
│  │  We found: ```json ... ```                             │ │
│  │                                                        │ │
│  │  ✅ Auto-fix available: Remove markdown wrapper         │ │
│  │                                                        │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌──────────────────┐  ┌──────────────────┐                 │
│  │  [Auto-Fix & Retry]│  │  [Edit Manually]  │                 │
│  └──────────────────┘  └──────────────────┘                 │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

#### JSON Cleaning Algorithm

```dart
/// Clean LLM response to extract valid JSON
String cleanLlmResponse(String response) {
  var cleaned = response.trim();
  
  // Step 1: Remove markdown code blocks
  final codeBlockPattern = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
  final codeBlockMatch = codeBlockPattern.firstMatch(cleaned);
  if (codeBlockMatch != null) {
    cleaned = codeBlockMatch.group(1)!;
  }
  
  // Step 2: Find JSON object boundaries
  final firstBrace = cleaned.indexOf('{');
  final lastBrace = cleaned.lastIndexOf('}');
  if (firstBrace >= 0 && lastBrace > firstBrace) {
    cleaned = cleaned.substring(firstBrace, lastBrace + 1);
  }
  
  // Step 3: Fix common character issues
  cleaned = cleaned
      .replaceAll('"', '"')  // Smart quotes
      .replaceAll('"', '"')
      .replaceAll(''', "'")
      .replaceAll(''', "'");
  
  return cleaned;
}
```

---

## Issue 4: Clipboard Data Loss During App Switching

### Current Behavior
When users copy the prompt, switch to ChatGPT/Claude, get a response, and copy it, they lose the original prompt context. Returning to Prompt Loop, the clipboard only contains the LLM response.

### Root Cause Analysis
Android clipboard only holds one item at a time. Manual app switching is error-prone and interrupts the workflow.

### UX Solution: Android Intent Sharing

Instead of clipboard-based flow, use Android's native sharing system:

#### Option A: Share Prompt to LLM App

```
┌──────────────────────────────────────────────────────────────┐
│                   SHARE PROMPT                               │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Your prompt is ready! Share it with your AI assistant:      │
│                                                              │
│  ┌──────────────────────────────────────────────────────────┐│
│  │  📤 SHARE TO...                                          ││
│  │                                                          ││
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐        ││
│  │  │ ChatGPT │ │ Claude  │ │ Gemini  │ │  More   │        ││
│  │  │   🤖    │ │   🧠    │ │   ✨    │ │   ...   │        ││
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘        ││
│  │                                                          ││
│  └──────────────────────────────────────────────────────────┘│
│                                                              │
│  After getting the response, share it back to Prompt Loop:   │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  💡 TIP: In ChatGPT/Claude, select all the response     │ │
│  │  text and tap "Share" → choose "Prompt Loop"            │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│              [📤 Share Prompt]   [📋 Copy Instead]           │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

#### Option B: Receive Shared Text (Response)

```
┌──────────────────────────────────────────────────────────────┐
│                   INCOMING SHARE                             │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  📥 Text shared from ChatGPT                                 │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  {                                                      │ │
│  │    "tasks": [                                          │ │
│  │      {                                                 │ │
│  │        "title": "Practice barre chord finger..."       │ │
│  │        ...                                             │ │
│  │      }                                                 │ │
│  │    ]                                                   │ │
│  │  }                                                      │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  ✓ Valid JSON detected                                 │ │
│  │  ✓ Found 4 practice tasks                              │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  What would you like to do with this data?                   │
│                                                              │
│  ┌──────────────────┐  ┌──────────────────┐                 │
│  │ [Import Tasks]    │  │ [View Details]    │                 │
│  └──────────────────┘  └──────────────────┘                 │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

#### Android Manifest Configuration

```xml
<!-- AndroidManifest.xml additions -->

<!-- Share prompt TO other apps -->
<activity android:name=".MainActivity" ...>
  <!-- Existing intent-filter for launcher -->
</activity>

<!-- Receive text FROM other apps -->
<activity
    android:name=".ShareReceiverActivity"
    android:exported="true"
    android:label="Import to Prompt Loop">
    <intent-filter>
        <action android:name="android.intent.action.SEND" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="text/plain" />
    </intent-filter>
</activity>
```

#### Workflow Comparison

| Step | Clipboard Flow (Current) | Intent Share Flow (Proposed) |
|------|--------------------------|------------------------------|
| 1 | Copy prompt | Tap "Share" → select ChatGPT |
| 2 | Switch to ChatGPT | ChatGPT opens with prompt |
| 3 | Paste prompt | (Already pasted) |
| 4 | Copy response | Tap Share → select Prompt Loop |
| 5 | Switch back to app | Prompt Loop opens with response |
| 6 | Paste response | (Already imported) |

**Benefits:**
- No clipboard overwrites
- Fewer manual steps (6 → 4)
- Works even if app is killed in background
- More reliable data transfer

---

## Issue 5: Back Navigation Broken for Generate Task

### Current Behavior
When user taps back from the "Generate Tasks" workflow screen, nothing happens or it navigates to wrong screen.

### Root Cause Analysis
The copy-paste workflow screen is opened via `context.push()` but may not be properly handling the back action, or the route isn't set up correctly for popping.

### UX Solution: Proper Navigation Stack

#### Expected Navigation Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    Home     │ →   │   Skills    │ →   │  Skill      │
│    Screen   │     │   List      │     │  Detail     │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
                    ┌─────────────┐     ┌─────────────┐
                    │   Task      │ ←   │  Generate   │
                    │   Created   │     │  Tasks      │
                    │   (Toast)   │     │  Screen     │
                    └─────────────┘     └─────────────┘
                                               │
                                        [Back Button]
                                               │
                                               ▼
                                        Returns to
                                        Skill Detail
```

#### AppBar Configuration

```dart
AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppPaths.home);
      }
    },
  ),
  title: Text(_title),
),
```

#### Confirmation Dialog for Unsaved Work

```
┌──────────────────────────────────────────────────────────────┐
│  ⚠️ Discard progress?                                        │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  You have a generated prompt that hasn't been processed yet. │
│  If you go back, you'll lose this progress.                  │
│                                                              │
│              [Stay]           [Discard & Go Back]            │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## Issue 6: Purpose Management Not Implemented

### Current Behavior
Users can create a purpose during onboarding, but there's no way to:
- View existing purposes
- Edit a purpose
- Delete a purpose
- Add purposes to existing skills

### UX Solution: Purpose Management Screens

#### 6.1 Purpose List Screen (Access from Settings)

```
┌──────────────────────────────────────────────────────────────┐
│  ← Settings           MY PURPOSES                            │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Your purposes drive your practice. Review them often.       │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  🎸 Guitar Playing                                      │ │
│  │  ────────────────────────────────────────────────────  │ │
│  │  "To write songs that express what I can't say         │ │
│  │   in words"                                            │ │
│  │                                                        │ │
│  │  Category: Personal Expression                         │ │
│  │  Created: Nov 15, 2025                                 │ │
│  │                                        [Edit] [Delete] │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  💼 Public Speaking                                     │ │
│  │  ────────────────────────────────────────────────────  │ │
│  │  "To inspire my team and lead with clarity"            │ │
│  │                                                        │ │
│  │  Category: Career Growth                               │ │
│  │  Created: Nov 20, 2025                                 │ │
│  │                                        [Edit] [Delete] │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  📱 Flutter Development                 ⚠️ No Purpose   │ │
│  │  ────────────────────────────────────────────────────  │ │
│  │  "Tap to add a purpose for this skill"                 │ │
│  │                                            [Add Purpose]│ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

#### 6.2 Add/Edit Purpose Screen

```
┌──────────────────────────────────────────────────────────────┐
│  ← Cancel             EDIT PURPOSE            [Save]         │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Skill: 🎸 Guitar Playing                                    │
│                                                              │
│  ────────────────────────────────────────────────────────   │
│                                                              │
│  Why does mastering this skill matter to you?                │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  To write songs that express what I can't say          │ │
│  │  in words                                              │ │
│  │                                                        │ │
│  │                                                        │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  Category                                                    │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ ○ Personal Expression                        ← Current  │ │
│  │ ○ Connecting with Others                               │ │
│  │ ○ Career Growth                                        │ │
│  │ ○ Self Improvement                                     │ │
│  │ ○ Contributing Beyond Self                             │ │
│  │ ○ Other                                                │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  💡 TIPS FOR WRITING MEANINGFUL PURPOSES                     │
│  ────────────────────────────────────────────────────────   │
│  • Connect to people you care about                          │
│  • Think about the impact you want to have                   │
│  • Consider how this fits your life's work                   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

#### 6.3 Delete Confirmation

```
┌──────────────────────────────────────────────────────────────┐
│  🗑️ Delete Purpose?                                          │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Are you sure you want to delete this purpose statement?     │
│                                                              │
│  "To write songs that express what I can't say in words"     │
│                                                              │
│  This won't delete the skill itself.                         │
│                                                              │
│              [Cancel]           [Delete]                     │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

#### Navigation Structure

```
Settings
└── My Purposes (new menu item)
    ├── Purpose List Screen
    │   ├── Edit Purpose → Edit Screen
    │   ├── Delete Purpose → Confirmation Dialog
    │   └── Add Purpose (for skills without) → Add Screen
    └── Add Purpose Screen

Skill Detail Screen
└── Purpose Card
    ├── "Add Purpose" (if none) → Add Screen
    └── "Edit" (if exists) → Edit Screen
```

---

## Implementation Priority

| Priority | Issue | Effort | Impact |
|----------|-------|--------|--------|
| P0 | Issue 3: JSON parsing | Low | Critical - app unusable without fix |
| P0 | Issue 1: Welcome screen | Low | High - poor first impression |
| P1 | Issue 5: Back navigation | Low | Medium - breaks basic UX |
| P1 | Issue 2: Context in prompts | Medium | High - improves LLM quality |
| P2 | Issue 4: Intent sharing | Medium | High - better workflow |
| P2 | Issue 6: Purpose management | Medium | Medium - feature completeness |

---

## Design Assets Needed

1. **Share/Receive icons** for intent flow
2. **Purpose management illustrations**
3. **JSON validation status icons** (success, error, warning)
4. **Splash screen animation** (optional)

---

## Accessibility Considerations

- All validation messages must have screen reader announcements
- Purpose text fields should support voice input
- Share flow must work with TalkBack enabled
- Back navigation must be keyboard accessible

---

## Testing Scenarios

### Issue 1: Onboarding
- [ ] Fresh install shows onboarding
- [ ] After completion, home screen shows directly
- [ ] Force close and reopen still goes to home
- [ ] Clear app data resets to onboarding

### Issue 3: JSON Parsing
- [ ] Paste JSON with markdown wrapper ```json
- [ ] Paste JSON with explanation text before/after
- [ ] Paste JSON with smart quotes
- [ ] Paste truncated/invalid JSON (graceful error)

### Issue 4: Intent Sharing
- [ ] Share prompt to ChatGPT opens correctly
- [ ] Receive shared text from ChatGPT
- [ ] Handle share when app is not running
- [ ] Handle share when app is in background

---

*Document Version: 1.0*
*Last Updated: November 30, 2025*
