import '../DbHelper.dart';
import '../Item.dart';
import 'SearchStrategy.dart';

class ColorFilterStrategy implements SearchStrategy {
  final String color;
  final String itemType;
  final List<Item>? itemsToFilter;
  final DbHelper _dbHelper = DbHelper();

  ColorFilterStrategy(this.color, this.itemType, {this.itemsToFilter});

  @override
  Future<List<Item>> filterItems() async {
    return _dbHelper.getItemsByColor(color, itemType);
  }

  Future<List<Item>> filterItemsFromList(List<Item> items) async {
    List<Item> filteredItems = [];
    for (var item in items) {
      if (item.color == color && item.itemType == itemType) {
        filteredItems.add(item);
      }
    }
    return filteredItems;
  }
}

