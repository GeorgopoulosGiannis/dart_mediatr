import 'i_request.dart';

/// Extend [IRequestHandler] with [R] as the return type
/// and [T] as the [IRequest] you want to handle.
abstract class IRequestHandler<R, T extends IRequest<R>> {
  Future<R> call(T request);
}
