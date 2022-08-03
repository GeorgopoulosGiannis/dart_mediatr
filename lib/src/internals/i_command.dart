import 'i_request.dart';

/// Extend [ICommand] instead of [IRequest] when you dont need to return anything.
abstract class ICommand<T extends Object?> extends IRequest<T> {
  const ICommand();
}
