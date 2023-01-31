import 'i_request.dart';

import 'i_request_handler.dart';

/// Extend this class when you need to handle an [ICommand] that returns nothing.
abstract class ICommandHandler<R extends IRequest<void>>
    extends IRequestHandler<void, R> {
  const ICommandHandler();
}
