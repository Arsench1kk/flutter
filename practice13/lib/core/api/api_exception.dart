part 'no_connection_exception.dart';
part 'server_exception.dart';
part 'not_found_exception.dart';
part 'unauthorized_exception.dart';
part 'bad_response_exception.dart';

sealed class ApiException implements Exception {
  const ApiException();
}
