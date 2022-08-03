/// Subsclasses of IDomainEvent can be published through the mediator instane.
abstract class IDomainEvent extends Object {
  /// Should be unique across events.
  String get name;

  const IDomainEvent();
}
