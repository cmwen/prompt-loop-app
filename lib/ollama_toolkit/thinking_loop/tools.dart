import 'dart:async';

/// Abstract base class for tools that can be called by agents
abstract class Tool {
  /// Unique name of the tool
  String get name;

  /// Description of what the tool does
  String get description;

  /// JSON Schema for the tool's parameters
  Map<String, dynamic> get parameters;

  /// Execute the tool with the given arguments
  Future<String> execute(Map<String, dynamic> args);

  /// Convert tool to OpenAI-style tool definition
  Map<String, dynamic> toDefinition() {
    return {
      'type': 'function',
      'function': {
        'name': name,
        'description': description,
        'parameters': parameters,
      },
    };
  }

  @override
  String toString() => 'Tool($name)';
}

/// Example calculator tool
class CalculatorTool extends Tool {
  @override
  String get name => 'calculator';

  @override
  String get description => 'Perform basic arithmetic calculations';

  @override
  Map<String, dynamic> get parameters => {
    'type': 'object',
    'properties': {
      'expression': {
        'type': 'string',
        'description':
            'Mathematical expression to evaluate (e.g., "2 + 2", "10 * 5")',
      },
    },
    'required': ['expression'],
  };

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final expression = args['expression'] as String;

    try {
      // Simple expression evaluator (supports +, -, *, /)
      final result = _evaluateExpression(expression);
      return result.toString();
    } catch (e) {
      return 'Error: Unable to evaluate expression "$expression": $e';
    }
  }

  double _evaluateExpression(String expr) {
    // Remove whitespace
    expr = expr.replaceAll(' ', '');

    // Handle multiplication and division first
    while (expr.contains('*') || expr.contains('/')) {
      final multMatch = RegExp(r'(\d+\.?\d*)\*(\d+\.?\d*)').firstMatch(expr);
      final divMatch = RegExp(r'(\d+\.?\d*)/(\d+\.?\d*)').firstMatch(expr);

      if (multMatch != null &&
          (divMatch == null || multMatch.start < divMatch.start)) {
        final a = double.parse(multMatch.group(1)!);
        final b = double.parse(multMatch.group(2)!);
        expr = expr.replaceFirst(multMatch.group(0)!, (a * b).toString());
      } else if (divMatch != null) {
        final a = double.parse(divMatch.group(1)!);
        final b = double.parse(divMatch.group(2)!);
        expr = expr.replaceFirst(divMatch.group(0)!, (a / b).toString());
      }
    }

    // Handle addition and subtraction
    var result = 0.0;
    final parts = expr.split(RegExp(r'(?=[+\-])'));
    for (final part in parts) {
      if (part.isEmpty) continue;
      if (part.startsWith('+')) {
        result += double.parse(part.substring(1));
      } else if (part.startsWith('-')) {
        result -= double.parse(part.substring(1));
      } else {
        result = double.parse(part);
      }
    }

    return result;
  }
}

/// Example time tool
class CurrentTimeTool extends Tool {
  @override
  String get name => 'current_time';

  @override
  String get description => 'Get the current date and time';

  @override
  Map<String, dynamic> get parameters => {'type': 'object', 'properties': {}};

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final now = DateTime.now();
    return now.toIso8601String();
  }
}
