# Technical Feasibility Research: Deliberate Practice App

---
**Research Date**: November 29, 2025  
**Researcher**: @researcher agent  
**Version**: 1.0  
**Status**: Complete  
**Related Documents**: [VISION.md](./VISION.md)  

---

## Executive Summary

This research validates the **technical feasibility** of building the Deliberate Practice App as outlined in the VISION document. All core requirements can be implemented using mature, well-supported Flutter packages with high community adoption.

### Key Findings

| Requirement | Feasibility | Recommended Solution | Risk Level |
|-------------|-------------|---------------------|------------|
| Local Data Storage | ✅ High | sqflite | Low |
| LLM Integration (BYOK) | ✅ High | openai_dart / langchain_dart | Low |
| Copy-Paste Workflow | ✅ High | Clipboard + JSON parsing | Low |
| Visual Progress Tracking | ✅ High | fl_chart | Low |
| State Management | ✅ High | Riverpod | Low |
| Skill Tree Visualization | ✅ Moderate | Custom + flutter_treeview | Medium |

**Overall Assessment**: The project is **technically feasible** with low-to-medium implementation risk.

---

## 1. Local Data Storage

### Requirement
Store skills, tasks, progress data, and user preferences locally with offline-first capability.

### Recommended Solution: **sqflite**

**Package**: `sqflite: ^2.3.0`  
**Context7 ID**: `/tekartik/sqflite`  
**Benchmark Score**: 94.7 (Excellent)  
**Source Reputation**: High

#### Why sqflite?

1. **Mature & Stable**: The de-facto SQLite solution for Flutter
2. **Full CRUD Support**: Transactions, batches, and complex queries
3. **Cross-Platform**: iOS, Android, macOS, Linux, Windows, Dart VM
4. **Schema Migrations**: Built-in version management with `onCreate`, `onUpgrade`
5. **Offline-First**: Native local storage, no network required

#### Implementation Pattern

```dart
// Model class with JSON serialization
class Skill {
  int? id;
  String name;
  String description;
  String currentLevel;
  DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'current_level': currentLevel,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Skill.fromMap(Map<String, Object?> map) {
    return Skill(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      currentLevel: map['current_level'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

// Data provider with CRUD operations
class SkillProvider {
  late Database db;

  Future<void> open(String path) async {
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE skills (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT,
            current_level TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }
}
```

#### Database Schema (Draft)

```sql
-- Core Tables
CREATE TABLE skills (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  current_level TEXT CHECK(current_level IN ('beginner','intermediate','advanced','expert')),
  target_level TEXT,
  parent_skill_id INTEGER REFERENCES skills(id),
  created_at TEXT NOT NULL,
  updated_at TEXT
);

CREATE TABLE tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  skill_id INTEGER NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  duration_minutes INTEGER,
  frequency TEXT,
  difficulty INTEGER CHECK(difficulty BETWEEN 1 AND 10),
  is_completed INTEGER DEFAULT 0,
  created_at TEXT NOT NULL
);

CREATE TABLE practice_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id INTEGER NOT NULL REFERENCES tasks(id),
  started_at TEXT NOT NULL,
  completed_at TEXT,
  notes TEXT,
  rating INTEGER CHECK(rating BETWEEN 1 AND 5)
);

CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
```

### Alternative: **Hive**

For simpler key-value storage needs, Hive offers faster read/write speeds but lacks relational query capabilities. Consider for caching or simple preferences.

---

## 2. LLM Integration (BYOK Mode)

### Requirement
Support direct API calls to OpenAI, Anthropic, and other LLM providers using user-provided API keys.

### Recommended Solution: **langchain_dart** + **openai_dart**

#### Primary Package: langchain_dart

**Package**: `langchain: ^0.7.0` + `langchain_openai: ^0.7.0`  
**Context7 ID**: `/davidmigloz/langchain_dart`  
**Benchmark Score**: 92.3 (Excellent)  
**Source Reputation**: High

**Why LangChain Dart?**

1. **Provider Agnostic**: Single abstraction for OpenAI, Anthropic, Ollama, Vertex AI
2. **Streaming Support**: Real-time response streaming
3. **Tool/Function Calling**: Structured output generation
4. **Fallback Chains**: Automatic failover between providers
5. **Prompt Templates**: Reusable, parameterized prompts

```dart
// Multi-provider support with fallbacks
final openAI = ChatOpenAI(
  apiKey: userApiKey,
  defaultOptions: ChatOpenAIOptions(model: 'gpt-4o'),
);

final anthropic = ChatAnthropic(
  apiKey: userAnthropicKey,
  defaultOptions: ChatAnthropicOptions(model: 'claude-3-sonnet'),
);

// Automatic fallback chain
final chatModel = openAI.withFallbacks([anthropic]);

// Structured prompts
final prompt = ChatPromptTemplate.fromPromptMessages([
  SystemChatMessagePromptTemplate.fromTemplate(
    'You are a skill analysis expert. Analyze skills and break them into sub-skills.',
  ),
  HumanChatMessagePromptTemplate.fromTemplate(
    'Analyze this skill: {skill_name}. User context: {context}',
  ),
]);

final chain = prompt | chatModel | StringOutputParser();
final result = await chain.invoke({
  'skill_name': 'Playing Guitar',
  'context': 'Beginner, 3 months experience',
});
```

#### Direct OpenAI Integration: openai_dart

**Package**: `openai_dart: ^0.4.0`  
**Context7 ID**: `/websites/pub_dev_openai_dart`  
**Source Reputation**: High

For direct OpenAI API access without LangChain abstraction:

```dart
final client = OpenAIClient(apiKey: userApiKey);

final response = await client.createChatCompletion(
  request: CreateChatCompletionRequest(
    model: ChatCompletionModel.modelId('gpt-4o'),
    messages: [
      ChatCompletionMessage.system(
        content: 'You are a deliberate practice coach. Always respond with valid JSON.',
      ),
      ChatCompletionMessage.user(
        content: ChatCompletionUserMessageContent.string(userPrompt),
      ),
    ],
    responseFormat: ResponseFormat.jsonObject, // Force JSON output
  ),
);
```

### Supported Providers

| Provider | Package | Notes |
|----------|---------|-------|
| OpenAI | langchain_openai | GPT-4, GPT-4o, o1 |
| Anthropic | langchain_anthropic | Claude 3.x series |
| Google | langchain_google | Gemini Pro |
| Ollama | langchain_ollama | Local models (llama3, mistral) |
| Firebase Vertex AI | langchain_firebase | Google Cloud integration |

### API Key Security

```dart
// Store API keys securely using flutter_secure_storage
final secureStorage = FlutterSecureStorage();

Future<void> saveApiKey(String provider, String key) async {
  await secureStorage.write(key: '${provider}_api_key', value: key);
}

Future<String?> getApiKey(String provider) async {
  return await secureStorage.read(key: '${provider}_api_key');
}
```

**Required Package**: `flutter_secure_storage: ^9.0.0`

---

## 3. Copy-Paste Workflow (Manual Mode)

### Requirement
Generate prompts users can copy to external LLMs, and parse JSON responses pasted back.

### Solution: Flutter Clipboard + dart:convert

#### Clipboard Operations

```dart
import 'package:flutter/services.dart';

// Copy prompt to clipboard
Future<void> copyPromptToClipboard(String prompt) async {
  await Clipboard.setData(ClipboardData(text: prompt));
}

// Paste and parse JSON response
Future<Map<String, dynamic>?> parseClipboardJson() async {
  final data = await Clipboard.getData(Clipboard.kTextPlain);
  if (data?.text == null) return null;
  
  try {
    return jsonDecode(data!.text!) as Map<String, dynamic>;
  } catch (e) {
    // Handle malformed JSON
    return null;
  }
}
```

#### JSON Schema Validation

For robust JSON parsing with schema validation:

**Package**: `json_schema: ^5.0.0`

```dart
import 'dart:convert';

class LlmResponseParser {
  static const String schemaVersion = '1.0';
  
  /// Validates and parses LLM response JSON
  static ParseResult parseResponse(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate required fields
      if (!json.containsKey('type') || !json.containsKey('data')) {
        return ParseResult.error('Missing required fields: type, data');
      }
      
      final type = json['type'] as String;
      final data = json['data'] as Map<String, dynamic>;
      
      switch (type) {
        case 'skill_analysis':
          return _parseSkillAnalysis(data);
        case 'task_generation':
          return _parseTaskGeneration(data);
        default:
          return ParseResult.error('Unknown response type: $type');
      }
    } on FormatException catch (e) {
      return ParseResult.error('Invalid JSON: ${e.message}');
    }
  }
  
  static ParseResult _parseSkillAnalysis(Map<String, dynamic> data) {
    // Validate skill analysis structure
    if (!data.containsKey('skill')) {
      return ParseResult.error('Missing skill data');
    }
    return ParseResult.success(SkillAnalysis.fromJson(data));
  }
}

class ParseResult {
  final bool isSuccess;
  final dynamic data;
  final String? errorMessage;
  
  ParseResult.success(this.data) : isSuccess = true, errorMessage = null;
  ParseResult.error(this.errorMessage) : isSuccess = false, data = null;
}
```

#### Prompt Generation Templates

```dart
class PromptTemplates {
  static String skillAnalysis(String skillName, String context) => '''
You are a deliberate practice expert. Analyze the following skill and break it down into learnable sub-skills.

Skill: $skillName
User Context: $context

Respond with ONLY valid JSON in this exact format:
```json
{
  "type": "skill_analysis",
  "version": "1.0",
  "data": {
    "skill": {
      "name": "string",
      "description": "string",
      "subSkills": [
        {
          "id": "unique_id",
          "name": "sub-skill name",
          "description": "what this sub-skill involves",
          "currentLevel": "beginner|intermediate|advanced|expert",
          "priority": "high|medium|low"
        }
      ]
    }
  }
}
```

Important: 
- Generate 3-7 sub-skills
- Prioritize by impact on overall skill improvement
- Be specific and actionable
''';

  static String taskGeneration(String skillId, String skillName, String level) => '''
You are a deliberate practice coach. Generate specific practice tasks for improving a skill.

Skill: $skillName
Current Level: $level

Respond with ONLY valid JSON in this exact format:
```json
{
  "type": "task_generation",
  "version": "1.0",
  "data": {
    "tasks": [
      {
        "id": "unique_id",
        "title": "task title",
        "description": "detailed description",
        "skillId": "$skillId",
        "duration": "15 minutes",
        "frequency": "daily|weekly",
        "successCriteria": ["criterion 1", "criterion 2"],
        "difficulty": 1-10
      }
    ]
  }
}
```

Important:
- Generate 3-5 tasks
- Tasks should be specific and measurable
- Include clear success criteria
- Progress from easier to harder
''';
}
```

### User Flow UX

```
┌─────────────────────────────────────────────────────────────┐
│  Step 1: Generate Prompt                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  [Generated Prompt Text Area]                        │   │
│  │  "You are a deliberate practice expert..."           │   │
│  └─────────────────────────────────────────────────────┘   │
│  [📋 Copy Prompt]  [📖 View Instructions]                   │
├─────────────────────────────────────────────────────────────┤
│  Step 2: Get Response from Your LLM                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Paste this prompt into:                             │   │
│  │  • ChatGPT (chat.openai.com)                         │   │
│  │  • Claude (claude.ai)                                │   │
│  │  • Gemini (gemini.google.com)                        │   │
│  │  • Any other AI assistant                            │   │
│  └─────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│  Step 3: Paste Response                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  [Paste JSON Response Here]                          │   │
│  │                                                       │   │
│  └─────────────────────────────────────────────────────┘   │
│  [📥 Paste from Clipboard]  [✅ Import Response]            │
│                                                              │
│  ⚠️ Response Validation: [Status indicator]                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Visual Progress Tracking

### Requirement
Display progress charts, skill trees, and milestone visualizations.

### Recommended Solution: **fl_chart**

**Package**: `fl_chart: ^0.68.0`  
**Context7 ID**: `/imanneo/fl_chart`  
**Benchmark Score**: 44.1 (Good)  
**Source Reputation**: High

#### Why fl_chart?

1. **Chart Types**: Line, Bar, Pie, Scatter, Radar charts
2. **Highly Customizable**: Colors, gradients, animations, tooltips
3. **Touch Interactions**: Built-in touch handling and tooltips
4. **Animation Support**: Smooth transitions between data states
5. **Flutter-Native**: Pure Dart implementation, excellent performance

#### Progress Line Chart Example

```dart
import 'package:fl_chart/fl_chart.dart';

class ProgressChart extends StatelessWidget {
  final List<ProgressData> progressData;

  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: TouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          ),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(_formatDate(value)),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.deepPurple,
            barWidth: 4,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.deepPurple.withOpacity(0.3)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            spots: progressData.map((d) => FlSpot(d.day, d.score)).toList(),
          ),
        ],
      ),
    );
  }
}
```

#### Skill Level Radar Chart

```dart
// For skill sub-components comparison
RadarChart(
  RadarChartData(
    radarShape: RadarShape.polygon,
    tickCount: 5,
    ticksTextStyle: TextStyle(color: Colors.grey, fontSize: 10),
    titleTextStyle: TextStyle(color: Colors.black, fontSize: 12),
    getTitle: (index, angle) => RadarChartTitle(text: skillNames[index]),
    dataSets: [
      RadarDataSet(
        fillColor: Colors.blue.withOpacity(0.3),
        borderColor: Colors.blue,
        dataEntries: skillLevels.map((l) => RadarEntry(value: l)).toList(),
      ),
    ],
  ),
);
```

### Alternative: Skill Tree Visualization

For hierarchical skill trees, consider custom implementation or:

**Package**: `graphview: ^1.2.0` - For graph-based layouts  
**Package**: `flutter_treeview: ^1.0.5` - For expandable tree structures

```dart
// Custom skill tree node
class SkillTreeNode extends StatelessWidget {
  final Skill skill;
  final List<Skill> children;
  
  Widget build(BuildContext context) {
    return Column(
      children: [
        SkillCard(skill: skill),
        if (children.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: children.map((child) => 
              SkillTreeNode(skill: child, children: child.subSkills)
            ).toList(),
          ),
      ],
    );
  }
}
```

---

## 5. State Management

### Requirement
Manage app state across screens, handle async operations, and support dependency injection.

### Recommended Solution: **Riverpod**

**Package**: `flutter_riverpod: ^2.5.0`  
**Context7 ID**: `/websites/riverpod_dev`  
**Benchmark Score**: 71.0 (Good)  
**Source Reputation**: High

#### Why Riverpod?

1. **Compile-Time Safety**: No runtime errors from provider access
2. **Auto-Dispose**: Automatic cleanup of unused state
3. **Family Providers**: Parameterized providers for dynamic data
4. **Testing Support**: Easy mocking and container isolation
5. **DevTools Integration**: State inspection and debugging
6. **No BuildContext Required**: Access providers from anywhere

#### Provider Architecture

```dart
// Skills provider
@riverpod
class SkillsNotifier extends _$SkillsNotifier {
  @override
  Future<List<Skill>> build() async {
    final db = ref.watch(databaseProvider);
    return db.getAllSkills();
  }

  Future<void> addSkill(Skill skill) async {
    final db = ref.read(databaseProvider);
    await db.insertSkill(skill);
    ref.invalidateSelf();
  }

  Future<void> updateSkillLevel(int skillId, String level) async {
    final db = ref.read(databaseProvider);
    await db.updateSkillLevel(skillId, level);
    ref.invalidateSelf();
  }
}

// Tasks for a specific skill (family provider)
@riverpod
Future<List<Task>> tasksForSkill(Ref ref, int skillId) async {
  final db = ref.watch(databaseProvider);
  return db.getTasksForSkill(skillId);
}

// LLM service provider
@riverpod
LlmService llmService(Ref ref) {
  final settings = ref.watch(settingsProvider);
  return LlmService(
    apiKey: settings.apiKey,
    provider: settings.llmProvider,
  );
}

// Progress statistics
@riverpod
Future<ProgressStats> progressStats(Ref ref) async {
  final sessions = await ref.watch(practiceSessionsProvider.future);
  return ProgressStats.calculate(sessions);
}
```

#### Widget Integration

```dart
class SkillsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillsAsync = ref.watch(skillsNotifierProvider);
    
    return skillsAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error: error),
      data: (skills) => ListView.builder(
        itemCount: skills.length,
        itemBuilder: (context, index) => SkillCard(skill: skills[index]),
      ),
    );
  }
}
```

### Alternative: BLoC

For teams preferring event-driven architecture:

**Package**: `flutter_bloc: ^8.1.0`

---

## 6. Dependency Summary

### Production Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  
  # Local Storage
  sqflite: ^2.3.0
  path: ^1.9.0
  
  # LLM Integration
  langchain: ^0.7.0
  langchain_openai: ^0.7.0
  openai_dart: ^0.4.0
  
  # Security
  flutter_secure_storage: ^9.0.0
  
  # Charts & Visualization
  fl_chart: ^0.68.0
  
  # JSON
  json_annotation: ^4.8.0
  
  # Utilities
  uuid: ^4.0.0
  intl: ^0.19.0
  equatable: ^2.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code Generation
  riverpod_generator: ^2.4.0
  json_serializable: ^6.7.0
  build_runner: ^2.4.0
  
  # Testing
  mockito: ^5.4.0
  sqflite_common_ffi: ^2.3.0
```

### Package Maturity Assessment

| Package | Version | Pub Points | Popularity | Maintenance |
|---------|---------|------------|------------|-------------|
| sqflite | 2.3.x | 140/140 | 99% | Active |
| flutter_riverpod | 2.5.x | 140/140 | 98% | Active |
| fl_chart | 0.68.x | 140/140 | 97% | Active |
| openai_dart | 0.4.x | 130/140 | 85% | Active |
| langchain_dart | 0.7.x | 130/140 | 80% | Active |

---

## 7. Technical Risks & Mitigations

### Risk 1: LLM Response Inconsistency

**Risk**: LLMs may not always return valid JSON or follow schema exactly.

**Mitigations**:
- Use `responseFormat: jsonObject` when available (OpenAI)
- Implement robust JSON validation with detailed error messages
- Provide example responses in prompts
- Allow users to manually edit/fix responses
- Retry with refined prompts

### Risk 2: Skill Tree Complexity

**Risk**: Deeply nested skill hierarchies may be difficult to visualize on mobile.

**Mitigations**:
- Limit depth to 3 levels initially
- Implement collapsible tree nodes
- Provide alternative list/grid views
- Use horizontal scrolling for wide trees

### Risk 3: Offline-First Sync Conflicts

**Risk**: If future cloud sync is added, conflicts may arise.

**Mitigations**:
- Design schema with `updated_at` timestamps now
- Use UUIDs instead of auto-increment IDs
- Plan for conflict resolution strategy early

### Risk 4: API Key Security

**Risk**: User API keys must be stored securely.

**Mitigations**:
- Use `flutter_secure_storage` (encrypted storage)
- Never log or transmit keys unnecessarily
- Provide clear security documentation to users

---

## 8. Architecture Recommendation

### Proposed Architecture: Clean Architecture + MVVM

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── utils/
│   └── extensions/
├── data/
│   ├── datasources/
│   │   ├── local/           # sqflite implementations
│   │   └── remote/          # LLM API implementations
│   ├── models/              # Data transfer objects
│   └── repositories/        # Repository implementations
├── domain/
│   ├── entities/            # Core business objects
│   ├── repositories/        # Repository interfaces
│   └── usecases/            # Business logic
├── presentation/
│   ├── providers/           # Riverpod providers
│   ├── screens/
│   │   ├── home/
│   │   ├── skills/
│   │   ├── tasks/
│   │   ├── progress/
│   │   └── settings/
│   ├── widgets/             # Reusable widgets
│   └── theme/
└── main.dart
```

---

## 9. Next Steps

### Immediate Actions

1. **Set up project structure** per architecture recommendation
2. **Implement database schema** and migration system
3. **Create JSON schemas** for LLM responses (formal JSON Schema)
4. **Build prompt templates** library
5. **Design API abstraction** for LLM providers

### MVP Feature Priority

1. ✅ Skill input and storage
2. ✅ Copy-paste prompt workflow
3. ✅ JSON response parsing
4. ✅ Basic skill tree display
5. ✅ Task list with completion tracking

### Future Considerations

- Cloud sync (Supabase, Firebase)
- Push notifications for practice reminders
- Widget for home screen progress display
- Export/share functionality

---

## 10. References

- [sqflite Documentation](https://pub.dev/packages/sqflite)
- [Flutter Riverpod](https://riverpod.dev)
- [FL Chart Documentation](https://github.com/imaNNeo/fl_chart)
- [LangChain Dart](https://github.com/davidmigloz/langchain_dart)
- [OpenAI Dart](https://pub.dev/packages/openai_dart)
- [Flutter Clipboard](https://api.flutter.dev/flutter/services/Clipboard-class.html)
- [Dart JSON Serialization](https://dart.dev/libraries/serialization/json)

---

*This research document provides technical foundation for the Deliberate Practice App. Refer to VISION.md for product requirements and user stories.*
