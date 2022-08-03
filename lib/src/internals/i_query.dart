import 'i_request.dart';

/// Same thing as [IRequest] but required to return not null
class IQuery<T extends Object> extends IRequest<T> {
  const IQuery();
}
