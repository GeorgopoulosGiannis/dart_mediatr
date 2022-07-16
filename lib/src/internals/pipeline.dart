import '../behaviours/i_pipeline_behaviour.dart';
import 'i_request.dart';
import 'i_request_handler.dart';

class Pipeline {
  late final List<IPipelineBehaviour> middlewares = [];

  void addMiddleware(IPipelineBehaviour behaviour) =>
      middlewares.add(behaviour);

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
