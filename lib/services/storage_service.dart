import 'package:shared_preferences/shared_preferences.dart';

/// A simple wrapper around SharedPreferences for key-value storage.
///
/// This service provides a convenient interface for storing and retrieving
/// simple data types (strings, bools, ints, doubles) that persist across
/// app restarts.
///
/// ## Usage
///
/// ```dart
/// // Initialize the service (typically in main.dart before runApp)
/// final storage = StorageService();
/// await storage.init();
///
/// // Store values
/// await storage.setString('username', 'john_doe');
/// await storage.setBool('darkMode', true);
/// await storage.setInt('loginCount', 5);
///
/// // Retrieve values
/// final username = storage.getString('username'); // 'john_doe'
/// final darkMode = storage.getBool('darkMode'); // true
/// final loginCount = storage.getInt('loginCount'); // 5
///
/// // Remove a specific key
/// await storage.remove('username');
///
/// // Clear all stored data
/// await storage.clear();
/// ```
///
/// ## Best Practices
///
/// - Call `init()` before using any other methods
/// - Use for small, simple data (preferences, settings, tokens)
/// - For complex data structures, consider using a database like Hive or Isar
/// - Keys should be descriptive and use a consistent naming convention
///
/// ## Thread Safety
///
/// SharedPreferences operations are asynchronous and thread-safe.
/// However, avoid rapid successive writes to the same key.
class StorageService {
  SharedPreferences? _prefs;

  /// Initialize the storage service.
  ///
  /// Must be called before using any other methods.
  /// Typically called in main.dart before runApp().
  ///
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   final storage = StorageService();
  ///   await storage.init();
  ///   runApp(MyApp());
  /// }
  /// ```
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Ensures the service is initialized before use.
  void _ensureInitialized() {
    if (_prefs == null) {
      throw StateError('StorageService not initialized. Call init() first.');
    }
  }

  // ============================================================
  // String operations
  // ============================================================

  /// Retrieves a string value for the given [key].
  ///
  /// Returns `null` if the key doesn't exist or isn't a string.
  String? getString(String key) {
    _ensureInitialized();
    return _prefs!.getString(key);
  }

  /// Stores a string [value] for the given [key].
  ///
  /// Returns `true` if the value was successfully stored.
  Future<bool> setString(String key, String value) async {
    _ensureInitialized();
    return _prefs!.setString(key, value);
  }

  // ============================================================
  // Boolean operations
  // ============================================================

  /// Retrieves a boolean value for the given [key].
  ///
  /// Returns `null` if the key doesn't exist or isn't a boolean.
  bool? getBool(String key) {
    _ensureInitialized();
    return _prefs!.getBool(key);
  }

  /// Stores a boolean [value] for the given [key].
  ///
  /// Returns `true` if the value was successfully stored.
  Future<bool> setBool(String key, bool value) async {
    _ensureInitialized();
    return _prefs!.setBool(key, value);
  }

  // ============================================================
  // Integer operations
  // ============================================================

  /// Retrieves an integer value for the given [key].
  ///
  /// Returns `null` if the key doesn't exist or isn't an integer.
  int? getInt(String key) {
    _ensureInitialized();
    return _prefs!.getInt(key);
  }

  /// Stores an integer [value] for the given [key].
  ///
  /// Returns `true` if the value was successfully stored.
  Future<bool> setInt(String key, int value) async {
    _ensureInitialized();
    return _prefs!.setInt(key, value);
  }

  // ============================================================
  // Double operations
  // ============================================================

  /// Retrieves a double value for the given [key].
  ///
  /// Returns `null` if the key doesn't exist or isn't a double.
  double? getDouble(String key) {
    _ensureInitialized();
    return _prefs!.getDouble(key);
  }

  /// Stores a double [value] for the given [key].
  ///
  /// Returns `true` if the value was successfully stored.
  Future<bool> setDouble(String key, double value) async {
    _ensureInitialized();
    return _prefs!.setDouble(key, value);
  }

  // ============================================================
  // String list operations
  // ============================================================

  /// Retrieves a list of strings for the given [key].
  ///
  /// Returns `null` if the key doesn't exist or isn't a string list.
  List<String>? getStringList(String key) {
    _ensureInitialized();
    return _prefs!.getStringList(key);
  }

  /// Stores a list of strings [value] for the given [key].
  ///
  /// Returns `true` if the value was successfully stored.
  Future<bool> setStringList(String key, List<String> value) async {
    _ensureInitialized();
    return _prefs!.setStringList(key, value);
  }

  // ============================================================
  // Utility operations
  // ============================================================

  /// Checks if a [key] exists in storage.
  bool containsKey(String key) {
    _ensureInitialized();
    return _prefs!.containsKey(key);
  }

  /// Removes the value associated with [key].
  ///
  /// Returns `true` if the key was successfully removed.
  Future<bool> remove(String key) async {
    _ensureInitialized();
    return _prefs!.remove(key);
  }

  /// Removes all key-value pairs from storage.
  ///
  /// Use with caution - this clears ALL stored data.
  Future<bool> clear() async {
    _ensureInitialized();
    return _prefs!.clear();
  }

  /// Returns all keys currently stored.
  Set<String> getKeys() {
    _ensureInitialized();
    return _prefs!.getKeys();
  }
}
