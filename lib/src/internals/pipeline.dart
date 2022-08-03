import '../behaviours/i_pipeline_behaviour.dart';
import 'i_request.dart';
import 'i_request_handler.dart';

/// A pipeline passes  an [IRequest] through all of its [middlewares]
/// before being send to the [IRequestHandler]
class Pipeline {
  late final List<IPipelineBehaviour> middlewares = [];

  /// Adds a middleware to the [Pipeline]
  void addMiddleware(IPipelineBehaviour behaviour) =>
      middlewares.add(behaviour);

  /// The function that gets called from [Mediator] in order to pass the [IRequest] throught the middlewares
  Future passThrough(
    IRequest request,
    IRequestHandler requestHandler,
  ) async {
    Future runner(index) async {
      if (index == middlewares.length) {
        return requestHandler(request);
      }
      final m = middlewares[index];
      return m.proccess(
        request,
        (req) async => runner(index + 1),
      );
    }

    return runner(0);
  }
}
