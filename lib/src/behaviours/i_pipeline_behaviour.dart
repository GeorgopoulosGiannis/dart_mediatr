import '../internals/i_request.dart';

typedef RequestHandlerDelegate<T> = Future<T> Function(IRequest<T> req);

abstract class IPipelineBehaviour<R extends IRequest, T> {
  Future<T> proccess(R request, RequestHandlerDelegate next);
}
