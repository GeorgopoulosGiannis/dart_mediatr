abstract class Failure {
  final String message;

  Failure(
    this.message,
  );
}

class RequestFailure extends Failure {
  RequestFailure(
    super.message,
    this.request,
  );

  final String request;
}
