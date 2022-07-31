import 'dart:async';

import 'package:example/get_items_query.dart';
import 'package:example/items_repository.dart';
import 'package:mediatr/mediatr.dart';

import 'add_item_command.dart';
import 'logging_behaviour.dart';

Mediator setupMediator() {
  final repo = ItemsRepository();

  final pipeline = Pipeline()..addMiddleware(LoggingBehaviour());
  final mediator = Mediator(pipeline, errorHandler: _customErrorHandler);

  mediator.registerHandler<void, AddItemCommand, AddItemCommandHandler>(
    () => AddItemCommandHandler(
      repo,
    ),
  );

  mediator.registerHandler<List<String>, GetItemsQuery, GetItemsQueryHandler>(
    () => GetItemsQueryHandler(
      repo,
    ),
  );

  return mediator;
}

FutureOr<Failure?> _customErrorHandler(Exception e) {
  if (e is EmptyItemException) {
    return EmptyItemFailure(e.toString());
  }
  return null;
}
