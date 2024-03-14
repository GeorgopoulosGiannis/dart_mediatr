import 'i_request.dart';

/// Extend [IRequestHandler] with [R] as the return type
/// and [T] as the [IRequest] you want to handle.
abstract class IRequestHandler<T extends IRequest<R>, R> {
  const IRequestHandler();

  Future<R> call(T request);
}
