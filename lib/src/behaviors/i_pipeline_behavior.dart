import '../internals/i_request.dart';

typedef RequestHandlerDelegate<T> = Future<T> Function(IRequest<T> req);

abstract class IPipelineBehavior<R extends IRequest, T> {
  Future<T> process(R request, RequestHandlerDelegate next);
}
