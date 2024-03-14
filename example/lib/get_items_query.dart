import 'package:mediatr/mediatr.dart';

import 'items_repository.dart';

class GetItemsQuery extends IQuery<List<String>> {}

class GetItemsQueryHandler
    extends IRequestHandler<GetItemsQuery, List<String>> {
  final ItemsRepository itemsRepository;

  GetItemsQueryHandler(this.itemsRepository);
  @override
  Future<List<String>> call(GetItemsQuery request) async {
    return itemsRepository.items;
  }
}
