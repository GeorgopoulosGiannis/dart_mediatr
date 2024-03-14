import 'package:mediatr/mediatr.dart';

class LoggingBehavior extends IPipelineBehavior {
  @override
  Future process(IRequest request, RequestHandlerDelegate next) {
    print('new request send $request');
    return next(request);
  }
}
