import 'package:equatable/equatable.dart';

class ApiException extends Equatable implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
  });

  final String message;
  final int? statusCode;
  final String? code;

  @override
  List<Object?> get props => [message, statusCode, code];

  @override
  String toString() => 'ApiException($statusCode): $message';
}
