import 'package:example/items_repository.dart';
import 'package:mediatr/mediatr.dart';

class GetItemsQuery extends IQuery<List<String>> {}

class GetItemsQueryHandler
    extends IRequestHandler<List<String>, GetItemsQuery> {
  final ItemsRepository itemsRepository;

  GetItemsQueryHandler(this.itemsRepository);
  @override
  Future<List<String>> call(GetItemsQuery request) async {
    return itemsRepository.items;
  }
}
