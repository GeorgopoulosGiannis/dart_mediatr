# Dart mediator package

Pure dart package.
No dependencies in flutter can be run both in flutter and dart API's.

Inspired by https://github.com/jbogard/MediatR


## Create and send a request

```dart
 /// Create the request 
 class AddRequest extends IRequest<int> {
  final int i;

  AddRequest(this.i);
}

/// Create a request handler 
class AddRequestHandler extends IRequestHandler<AddRequest, int> {
  @override
  Future<int> call(AddRequest request) async {
    return request.i + 1;
  }
}
/// Register the handler to the mediator instance ( commonly stored as a singleton )
 final mediator = Mediator(Pipeline());

 mediator.registerHandler<AddRequest, int, AddRequestHandler>(
          () => AddRequestHandler(),
        );

/// Send the request through the mediator instance
final added = await mediator.send<AddRequest, int>(
          AddRequest(2),
        );
print(added); // prints 3

```

## Publishing events
```dart
/// create an event extending IDomainEvent
class MyEvent extends IDomainEvent {
  @override
  String get name => 'MyEvent';
}

mediator.publish<MyEvent>(MyEvent());
```

## Subscribe on events with functions
```dart
/// subscribe on mediator instance
var unsubscribeFunc = mediator.subscribeWithFunc<MyEvent>((event){
 print(event.name);
});

/// call the func returned to unsubscribe
unsubscribeFunc();

```
## Subscribe on events with a class instance
```dart
class MyEventHandler extends IEventHandler<MyEvent> {
  @override
  Future<void> call(MyEvent event) {
    print(event);
  }
}
var eventHandler = MyEventHandler();

mediator.subscribe<MyEvent>(eventHandler);


/// call unsubscribe with the same instance to remove the handler.
mediator.unsubscribe<MyEvent>(eventHandler);

```


 ## Adding a middleware for all requests
 
```dart
class LoggingBehavior extends IPipelineBehavior {
  @override
  Future process(IRequest request, RequestHandlerDelegate next) {
    print(request);
    return next(request);
  }
}

final mediator = Mediator(
  Pipeline()
    ..addMiddleware(
      LoggingBehavior(),
    ),
);
```

