import 'package:lost_and_found/backend/DbHelper.dart';

import '../Item.dart';
import 'SearchStrategy.dart';

enum ItemType { Lost, Found }

class CompositeSearchStrategy implements SearchStrategy {
  final List<SearchStrategy> strategies;
  final ItemType itemType;
  CompositeSearchStrategy(this.strategies, {required this.itemType});
  @override
  Future<List<Item>> filterItems() async {
    if (strategies.isEmpty) {
      switch (itemType) {
        case ItemType.Lost:
          return DbHelper().getAllLostItems();
        case ItemType.Found:
          return DbHelper().getAllFoundItems();
      }
    }

    List<Item> items = [];

    int i = 0;
    for (var strategy in strategies) {
      if (i == 0) {
        items = await strategy.filterItems();
      } else {
        items = await strategy.filterItemsFromList(items);
      }
      i = i + 1;
    }
    return items;
  }

  @override
  Future<List<Item>> filterItemsFromList(List<Item> items) async {
    for (var strategy in strategies) {
      List<Item> itemsFilteredByStrategy =
          await strategy.filterItemsFromList(items);
      items = itemsFilteredByStrategy;
    }

    return items;
  }
}
