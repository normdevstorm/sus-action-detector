import 'package:meta/meta.dart';

/// A generic class which provides exceptions in a Firebase-friendly format
/// to users.
///
/// ```dart
/// try {
///   await Firebase.initializeApp();
/// } catch (e) {
///   print(e.toString());
/// }
/// ```
@immutable
class FirebaseException implements Exception {
  /// A generic class which provides exceptions in a Firebase-friendly format
  /// to users.
  ///
  /// ```dart
  /// try {
  ///   await Firebase.initializeApp();
  /// } catch (e) {
  ///   print(e.toString());
  /// }
  /// ```
  FirebaseException(
      {required this.plugin,
      this.message,
      this.code = 'unknown',
      this.stackTrace});

  /// The plugin the exception is for.
  ///
  /// The value will be used to prefix the message to give more context about
  /// the exception.
  final String plugin;

  /// The long form message of the exception.
  final String? message;

  /// The optional code to accommodate the message.
  ///
  /// Allows users to identify the exception from a short code-name, for example
  /// "no-app" is used when a user attempts to read a [FirebaseApp] which does
  /// not exist.
  final String code;

  /// The stack trace which provides information to the user about the call
  /// sequence that triggered an exception
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FirebaseException) return false;
    return other.toString() == toString();
  }

  @override
  int get hashCode {
    return toString().hashCode;
  }

  @override
  String toString() {
    return '[$plugin/$code] $message';
  }
}
