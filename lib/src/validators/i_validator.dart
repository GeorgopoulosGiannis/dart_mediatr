import 'dart:async';

import '../internals/i_request.dart';

abstract class IValidator<T extends IRequest> {
  FutureOr<void> validate(T request);
}
