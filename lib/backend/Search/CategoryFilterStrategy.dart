import '../DbHelper.dart';
import '../Item.dart';
import 'SearchStrategy.dart';

class CategoryFilterStrategy implements SearchStrategy {
  final String category;
  final String itemType;
  final List<Item>? itemsToFilter;
  final DbHelper dbHelper = DbHelper();

  CategoryFilterStrategy(this.category, this.itemType, {this.itemsToFilter});

  @override
  Future<List<Item>> filterItems() async {
    return dbHelper.getItemsByCategory(category, itemType);
  }

  Future<List<Item>> filterItemsFromList(List<Item> items) async {
    List<Item> filteredItems = [];
    for (var item in items) {
      if (item.category == category && item.itemType == itemType) {
        filteredItems.add(item);
      }
    }
    return filteredItems;
  }
}
