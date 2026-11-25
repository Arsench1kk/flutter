part of 'api_exception.dart';

class BadResponseException extends ApiException {
  const BadResponseException([this.detail]);

  final String? detail;
}
