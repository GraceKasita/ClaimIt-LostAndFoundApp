import '../backend/Item.dart';

abstract class ItemPoster {
  Future<void> post(Item newItem);
}
