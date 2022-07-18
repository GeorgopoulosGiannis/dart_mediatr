# Dart mediator package

Inspired by https://github.com/jbogard/MediatR


## Example Usage


Create a request 
```dart
 class AddRequest extends IRequest<int> {
  final int i;

  AddRequest(this.i);
}
```
Create a request handler 
```dart
class AddRequestHandler extends IRequestHandler<int, AddRequest> {
  @override
  Future<int> call(AddRequest request) async {
    return request.i + 1;
  }
}
```
Register the handler to the mediator instance
```dart
 final mediator = Mediator(Pipeline());

 mediator.registerHandler<int, AddRequest, AddRequestHandler>(
          () => AddRequestHandler(),
        );
 ```
 
 Start sending requests!
 ```dart
 final addedOrFailure =await mediator.send<int, AddRequest>(
          AddRequest(2),
        );
print(addedOrFailure.fold((left) {
// an instance of Failure
},
(right) {
// The added number
}));


To add a cfinal mediator = Mediator(Pipeline(),errorHandler:_errorHandler );


MyFailure? _errorHandler(Exception e){
  if(e is CustomException){
    return MyFailure('message');
  }
}

class CustomException implements Exception{}
class MyFailure extends Failure{
  MyFailure(super.message);
}
```
 
  
 To add a custom exception handler
 
 ```dart
final mediator = Mediator(
  Pipeline(),
  errorHandler: _errorHandler,
);

MyFailure? _errorHandler(Exception e) {
  if (e is CustomException) {
    return MyFailure('message');
  }
}

class CustomException implements Exception {}

class MyFailure extends Failure {
  MyFailure(super.message);
}
```

To add a custom behaviour
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

