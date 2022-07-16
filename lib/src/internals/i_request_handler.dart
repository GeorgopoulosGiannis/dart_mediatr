import 'i_request.dart';

abstract class IRequestHandler<R, T extends IRequest<R>> {
  Future<R> call(T request);
}
