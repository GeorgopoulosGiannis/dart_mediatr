abstract class IDomainEvent extends Object {
  /// Should be unique across events.
  String get name;

  const IDomainEvent();
}
