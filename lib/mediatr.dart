import 'dart:async';

import 'src/internals/i_domain_event.dart';
import 'src/internals/i_event_handler.dart';
import 'src/internals/i_request.dart';
import 'src/internals/i_request_handler.dart';
import 'src/internals/pipeline.dart';
import 'src/extensions.dart';

export 'src/internals/i_command.dart';
export 'src/internals/i_command_handler.dart';
export 'src/internals/i_domain_event.dart';
export 'src/internals/i_event_handler.dart';
export 'src/internals/i_query.dart';
export 'src/internals/i_request.dart';
export 'src/internals/i_request_handler.dart';
export 'src/internals/pipeline.dart';
export 'src/behaviours/i_pipeline_behaviour.dart';

typedef HandlerCreator<T> = T Function();
typedef FuncEventHandler<T extends IDomainEvent> = FutureOr<void> Function(
    T event);

typedef UnsubscribeFunc = void Function();

/// Core mediator
class Mediator {
  /// Add pipeline behaviours that will be called with each request send through
  /// the mediator instance.
  final Pipeline pipeline;

  final handlers = <Type, HandlerCreator>{};

  final eventHandlers = <Type, List<IEventHandler>>{};

  final eventFuncHandler = <Type, List<FuncEventHandler>>{};

  Mediator(this.pipeline);

  /// Called subscribe with func to register to IDomainEvents with a function that will receive the event.
  /// You can add as many subscribers as you want.
  UnsubscribeFunc subscribeWithFunc<E extends IDomainEvent>(
      FutureOr<void> Function(IDomainEvent event) func) {
    if (eventFuncHandler[E] == null) {
      eventFuncHandler[E] = [];
    }
    eventFuncHandler[E]?.add(func);
    return () {
      eventFuncHandler[E]?.remove(func);
    };
  }

  /// Call subscribe to register to IDomainEvents with a class That implements IEventHandler
  /// if you do not wish to register with a function.
  void subscribe<E extends IDomainEvent>(IEventHandler<E> handler) {
    if (eventHandlers[E] == null) {
      eventHandlers[E] = [];
    }
    eventHandlers[E]?.add(handler);
  }

  /// Unsubscribes a class from the given Event
  void unsubscribe<E extends IDomainEvent>(IEventHandler<E> handler) {
    eventHandlers[E]?.remove(handler);
  }

  /// Publishes an event to both function and class subscribers.
  Future<void> publish<E extends IDomainEvent>(E event) async {
    // reverse loops to avoid concurrent modification of list
    // if event handler gets removed while looping.

    final eventHandlers = _getEventHandlersFor<E>();
    for (var i = eventHandlers.length - 1; i >= 0; i--) {
      final eh = eventHandlers.tryGet(i);
      await eh?.call(event);
    }

    final funcHandlers = _getFuncHandlersFor<E>();
    for (var i = funcHandlers.length - 1; i >= 0; i--) {
      final fh = funcHandlers.tryGet(i);
      await fh?.call(event);
    }
  }

  /// Sends a request to the given handlers after passing it through all middleware.
  Future<R> send<R extends Object?, T extends IRequest<R>>(
    T request,
  ) async {
    final handler = _getRequestHandlerFor<T>();
    if (handler == null) {
      throw Exception('Unknown handler ${T.toString()}');
    }

    return await pipeline.passThrough(request, handler);
  }

  /// [creator] should be a function that creates a [IRequestHandler]
  /// [R] is the return type of the request handler
  /// [IR] is the [IRequest] type
  /// [H] is the type of the [IRequestHandler], the return type of the [creator]
  void registerHandler<R, IR extends IRequest<R>,
      H extends IRequestHandler<R, IR>>(HandlerCreator<H> creator) {
    handlers[IR] = creator;
  }

  IRequestHandler? _getRequestHandlerFor<T extends IRequest>() =>
      handlers[T]?.call();

  List<IEventHandler> _getEventHandlersFor<E extends IDomainEvent>() =>
      eventHandlers[E] ?? [];

  List<FuncEventHandler> _getFuncHandlersFor<E extends IDomainEvent>() =>
      eventFuncHandler[E] ?? [];
}
