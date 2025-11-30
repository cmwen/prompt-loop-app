import 'package:equatable/equatable.dart';

/// Struggle entry entity (Duckworth: normalizing difficulty)
class StruggleEntry extends Equatable {
  final int? id;
  final int sessionId;
  final String content;
  final String? wiseFeedback;
  final DateTime createdAt;

  const StruggleEntry({
    this.id,
    required this.sessionId,
    required this.content,
    this.wiseFeedback,
    required this.createdAt,
  });

  /// Create a copy with modified fields
  StruggleEntry copyWith({
    int? id,
    int? sessionId,
    String? content,
    String? wiseFeedback,
    DateTime? createdAt,
  }) {
    return StruggleEntry(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      content: content ?? this.content,
      wiseFeedback: wiseFeedback ?? this.wiseFeedback,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, sessionId, content, wiseFeedback, createdAt];
}

/// Wise feedback structure (Duckworth: high standards + belief in ability)
class WiseFeedback extends Equatable {
  final String acknowledgment;
  final String normalization;
  final String reframe;
  final String encouragement;
  final String suggestion;

  const WiseFeedback({
    required this.acknowledgment,
    required this.normalization,
    required this.reframe,
    required this.encouragement,
    required this.suggestion,
  });

  /// Convert to display string
  String toDisplayString() {
    return '''
$acknowledgment

$normalization $reframe

$encouragement

💡 Try this: $suggestion
''';
  }

  /// Create from JSON map
  factory WiseFeedback.fromJson(Map<String, dynamic> json) {
    return WiseFeedback(
      acknowledgment: json['acknowledgment'] as String? ?? '',
      normalization: json['normalization'] as String? ?? '',
      reframe: json['reframe'] as String? ?? '',
      encouragement: json['encouragement'] as String? ?? '',
      suggestion: json['suggestion'] as String? ?? '',
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'acknowledgment': acknowledgment,
      'normalization': normalization,
      'reframe': reframe,
      'encouragement': encouragement,
      'suggestion': suggestion,
    };
  }

  @override
  List<Object?> get props => [
    acknowledgment,
    normalization,
    reframe,
    encouragement,
    suggestion,
  ];
}

/// Pre-defined wise feedback templates
class WiseFeedbackTemplates {
  WiseFeedbackTemplates._();

  static const WiseFeedback timing = WiseFeedback(
    acknowledgment: 'Timing is genuinely one of the hardest aspects to master.',
    normalization:
        'Even professional musicians spend years refining their sense of timing.',
    reframe:
        'The fact that you notice timing issues shows your ear is developing.',
    encouragement: 'You have what it takes to develop solid timing.',
    suggestion: 'Try practicing with a metronome at a slower tempo.',
  );

  static const WiseFeedback coordination = WiseFeedback(
    acknowledgment: 'Coordinating multiple movements at once is challenging.',
    normalization:
        'This is exactly the kind of struggle that builds neural pathways.',
    reframe: 'Your brain is literally rewiring itself right now.',
    encouragement:
        'Persistence through this difficulty is what separates masters from beginners.',
    suggestion:
        'Break the movement into smaller parts and practice each separately.',
  );

  static const WiseFeedback memory = WiseFeedback(
    acknowledgment:
        'Remembering sequences while executing them is cognitively demanding.',
    normalization:
        'Memory consolidation happens during sleep—you may find it easier tomorrow.',
    reframe:
        "Each attempt strengthens the memory trace, even if it doesn't feel like it.",
    encouragement: 'Your working memory will expand with consistent practice.',
    suggestion: 'Try chunking the sequence into smaller memorable groups.',
  );

  static const WiseFeedback general = WiseFeedback(
    acknowledgment:
        "What you're experiencing is a normal part of deliberate practice.",
    normalization:
        "Struggle is not a sign of inadequacy—it's a sign of growth happening.",
    reframe:
        "This difficulty means you're working at the edge of your ability.",
    encouragement:
        'I have high standards for you because I believe you can reach them.',
    suggestion: 'Focus on one small improvement at a time.',
  );

  /// Get appropriate feedback based on struggle content
  static WiseFeedback getForStruggle(String struggleContent) {
    final lower = struggleContent.toLowerCase();

    if (lower.contains('timing') ||
        lower.contains('rhythm') ||
        lower.contains('tempo') ||
        lower.contains('beat')) {
      return timing;
    }

    if (lower.contains('coordinate') ||
        lower.contains('together') ||
        lower.contains('hands') ||
        lower.contains('fingers') ||
        lower.contains('movement')) {
      return coordination;
    }

    if (lower.contains('remember') ||
        lower.contains('memory') ||
        lower.contains('forget') ||
        lower.contains('sequence')) {
      return memory;
    }

    return general;
  }
}
