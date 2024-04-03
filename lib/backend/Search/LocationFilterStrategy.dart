import '../DbHelper.dart';
import '../Item.dart';
import 'SearchStrategy.dart';

class LocationFilterStrategy implements SearchStrategy {
  final String location;
  final String itemType;
  final List<Item>? itemsToFilter;
  final DbHelper _dbHelper = DbHelper();

  LocationFilterStrategy(this.location, this.itemType, {this.itemsToFilter});

  @override
  Future<List<Item>> filterItems() async {
    return _dbHelper.getItemsByLocation(location, itemType);
  }

  Future<List<Item>> filterItemsFromList(List<Item> items) async {
    List<Item> filteredItems = [];
    for (var item in items) {
      if (item.location == location && item.itemType == itemType) {
        filteredItems.add(item);
      }
    }
    return filteredItems;
  }
}
