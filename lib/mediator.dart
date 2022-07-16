import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';

import 'src/internals/failure.dart';
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

typedef HandlerCreator<T> = T Function();
typedef FuncEventHandler<T extends IDomainEvent> = FutureOr<void> Function(
    T event);

typedef UnsubscribeFunc = void Function();
typedef RunnerGuard = Failure Function(dynamic Function());

class Mediator {
  final Pipeline pipeline;

  @visibleForTesting
  final handlers = <Type, HandlerCreator>{};

  @visibleForTesting
  final eventHandlers = <Type, List<IEventHandler>>{};

  @visibleForTesting
  final eventFuncHandler = <Type, List<FuncEventHandler>>{};

  Mediator(
    this.pipeline,
  );

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

  void subscribe<E extends IDomainEvent>(IEventHandler<E> handler) {
    if (eventHandlers[E] == null) {
      eventHandlers[E] = [];
    }
    eventHandlers[E]?.add(handler);
  }

  void unsubscribe<E extends IDomainEvent>(IEventHandler<E> handler) {
    eventHandlers[E]?.remove(handler);
  }

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

  Future<Either<Failure, R>> send<R extends Object?, T extends IRequest<R>>(
    T request,
  ) async {
    final handler = _getRequestHandlerFor<T>();
    if (handler == null) {
      throw Exception('Unknown handler ${T.toString()}');
    }
    try {
      final result = await pipeline.passThrough(request, handler);
      return Right(result);
    } catch (e) {
      return Left(
        RequestFailure(
          e.toString(),
          request.toString(),
        ),
      );
    }
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
