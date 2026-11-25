part of 'api_exception.dart';

class ServerException extends ApiException {
  const ServerException(this.status);

  final int status;
}
