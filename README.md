# Dart mediator package

Inspired by https://github.com/jbogard/MediatR


## Create and send a request

```dart
 /// Create the request 
 class AddRequest extends IRequest<int> {
  final int i;

  AddRequest(this.i);
}

/// Create a request handler 
class AddRequestHandler extends IRequestHandler<int, AddRequest> {
  @override
  Future<int> call(AddRequest request) async {
    return request.i + 1;
  }
}
/// Register the handler to the mediator instance ( commonly stored as a singleton )
 final mediator = Mediator(Pipeline());

 mediator.registerHandler<int, AddRequest, AddRequestHandler>(
          () => AddRequestHandler(),
        );

/// Send the request througt the mediator instance
final addedOrFailure = await mediator.send<int, AddRequest>(
          AddRequest(2),
        );
print(addedOrFailure.fold((left) {
// an instance of Failure
},
(right) {
// The added number
}));

```
 
 ## Adding a custom exception handler

 ```dart
 
 MyFailure? _errorHandler(Exception e) {
  if (e is CustomException) {
    return MyFailure('message');
  }
}

final mediator = Mediator(
  Pipeline(),
  errorHandler: _errorHandler,
);

class CustomException implements Exception {}

class MyFailure extends Failure {
  MyFailure(super.message);
}

```
## Subscribe on events with functions
```dart
 /// create an event extending IDomainEvent
 
 class MyEvent extends IDomainEvent {
  @override
  String get name => 'MyEvent';
 }

/// subscribe on mediator instance
var unsubsribeFunc = mediator.subscribeWithFunc<MyEvent>((event){
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
class LoggingBehaviour extends IPipelineBehaviour {
  @override
  Future proccess(IRequest request, RequestHandlerDelegate next) {
    print(request);
    return next(request);
  }
}

final mediator = Mediator(
  Pipeline()
    ..addMiddleware(
      LoggingBehaviour(),
    ),
);
```

