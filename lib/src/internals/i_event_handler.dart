import 'i_domain_event.dart';

abstract class IEventHandler<E extends IDomainEvent> {
  Future<void> call(E event);
}
