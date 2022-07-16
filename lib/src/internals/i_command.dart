import 'i_request.dart';

abstract class ICommand<T extends Object?> extends IRequest<T> {
  const ICommand();
}
