import 'get_items_query.dart';
import 'items_repository.dart';
import 'package:mediatr/mediatr.dart';

import 'add_item_command.dart';
import 'logging_behavior.dart';

Mediator setupMediator() {
  final repo = ItemsRepository();

  final pipeline = Pipeline()..addMiddleware(LoggingBehavior());
  final mediator = Mediator(pipeline);

  mediator.registerHandler<AddItemCommand, void, AddItemCommandHandler>(
    () => AddItemCommandHandler(
      repo,
    ),
  );

  mediator.registerHandler<GetItemsQuery, List<String>, GetItemsQueryHandler>(
    () => GetItemsQueryHandler(
      repo,
    ),
  );

  return mediator;
}
