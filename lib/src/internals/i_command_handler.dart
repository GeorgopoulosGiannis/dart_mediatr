import 'i_request.dart';

import 'i_request_handler.dart';

abstract class ICommandHandler<R extends IRequest<void>> extends IRequestHandler<void, R> {
  ICommandHandler();
}
