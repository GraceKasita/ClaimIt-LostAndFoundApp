import '../backend/Item.dart';

abstract class ItemPoster {
  Future<void> post(Item newItem);
  Future<void> sendMatchingItemEmail(String recipientEmail, Item lostItem,
      Item foundItem, double similarity, String foundItemImagePath);

  Future<void> matchAndNotify(Item newItem);
}
