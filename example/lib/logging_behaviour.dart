import 'package:mediatr/mediatr.dart';

class LoggingBehaviour extends IPipelineBehaviour {
  @override
  Future proccess(IRequest request, RequestHandlerDelegate next) {
    print('new request send $request');
    return next(request);
  }
}
