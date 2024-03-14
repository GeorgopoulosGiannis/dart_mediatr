/// Subclasses of IDomainEvent can be published through the mediator instance.
abstract class IDomainEvent extends Object {
  /// Should be unique across events.
  String get name;

  const IDomainEvent();
}
