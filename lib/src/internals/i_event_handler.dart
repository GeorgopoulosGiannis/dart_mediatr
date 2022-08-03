import 'i_domain_event.dart';

/// Extend [IEventHandler] with [E] as the event you want to subscribe to
abstract class IEventHandler<E extends IDomainEvent> {
  Future<void> call(E event);
}
