import 'i_domain_event.dart';

/// Extend [IEventHandler] with [E] as the event you want to subscribe to
abstract class IEventHandler<E extends IDomainEvent> {
  const IEventHandler();

  Future<void> call(E event);
}
