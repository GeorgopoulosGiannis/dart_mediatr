import '../internals/i_request.dart';
import 'i_validator.dart';

class IValidatorsStore {
  List<IValidator<T>> getValidatorsFor<T extends IRequest>() => [];
}
