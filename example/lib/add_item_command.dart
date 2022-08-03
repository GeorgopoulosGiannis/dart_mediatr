import 'package:mediatr/mediatr.dart';

import 'items_repository.dart';

class AddItemCommand extends ICommand {
  final String item;

  AddItemCommand(this.item);
}

class AddItemCommandHandler extends ICommandHandler<AddItemCommand> {
  final ItemsRepository itemsRepository;

  AddItemCommandHandler(this.itemsRepository);
  @override
  Future<void> call(AddItemCommand request) async {
    if (request.item.isEmpty) {
      throw EmptyItemException();
    }
    itemsRepository.items.add(request.item);
  }
}

class EmptyItemException implements Exception {
  @override
  String toString() => 'Cannot add empty item';
}

class EmptyItemFailure extends Failure {
  EmptyItemFailure(super.message);
}
