import 'package:lost_and_found/backend/API.dart';
import 'package:lost_and_found/backend/EmailSender.dart';
import 'package:lost_and_found/backend/ItemPoster.dart';
import 'package:lost_and_found/backend/UserModel.dart';

import 'Item.dart';
import '../backend/DbHelper.dart';

class ItemManager implements ItemPoster {
  String _verificationCode = 'admin1234';

  Future<bool> compareVerificationCode(String inputCode) async {
    return inputCode == _verificationCode;
  }

  Future<void> post(Item newItem) async {
    try {
      DbHelper dbHelper = DbHelper();
      int itemId = await dbHelper.saveItem(newItem);
      print('save successfully');
      await matchAndNotify(newItem);
    } catch (e) {
      print('Error while posting item: $e');
    }
  }

  Future<void> matchAndNotify(Item newItem) async {
    try {
      DbHelper dbHelper = DbHelper();

      List<Item> LostItems =
          await dbHelper.getItemsByCategoryAndType(newItem.category!, 'Lost');

      for (Item lostItem in LostItems) {
        String similarityString = await APIService.instance.getSimilarityScore(
          newItem.imagePath!,
          lostItem.imagePath!,
        );
        print(similarityString);

        String formattedSimilarityString =
            similarityString.replaceAll(RegExp(r'[^\d.]+'), '');

        double similarity = double.tryParse(formattedSimilarityString) ?? 0;
        print(similarity);

        if (similarity >= 0.7) {
          print('Found a similar item: ${lostItem.name}');
          int? itemId = await dbHelper.getItemIdByAttributes(lostItem);
          String? email = await dbHelper.getEmailByItemIdFromLostTable(itemId!);

          await sendMatchingItemEmail(
              email!, newItem, lostItem, similarity, lostItem.imagePath!);
        }
      }
    } catch (e) {
      print('Error while matching and notifying: $e');
    }
  }

  Future<void> sendMatchingItemEmail(String recipientEmail, Item lostItem,
      Item foundItem, double similarity, String foundItemImagePath) async {
    try {
      final emailSender = EmailSender(
          username: 'theintnandarsu246@gmail.com', password: 'fjpk rgpp nlgq hkct');

      String subject = 'Matching Item Found! Is this yours?';
      String body = 'Dear User,\n\n'
          'We have found a matching item for your lost item:\n\n'
          'Lost Item: ${lostItem.name}\n'
          'Found Item: ${foundItem.name}\n'
          'There is a high similarity Score: $similarity between these items\n\n'
          'We have also attached the image. Please kindly check it\n\n'
          'Please contact us for further details.\n\n'
          'Regards,\n'
          'Lost and Found Team';

      await emailSender.sendEmail(
          recipientEmail, subject, body, foundItemImagePath);
    } catch (e) {
      print('Error sending matching item email: $e');
    }
  }

  Future<void> saveMarkAsReceived(
      Item newItem, String name, String email) async {
    try {
      DbHelper dbHelper = DbHelper();
      dbHelper.updateItemTypeToReceive(newItem, name, email);
    } catch (e) {
      print("Error saving: $e");
    }
  }
    Future<Map<String, String>?> getLostItemOwner(Item item) async {
    DbHelper dbHelper = DbHelper();
    Map<String, String>? result = await dbHelper.getLostItemOwnerDetails(item);
    return result;
  }
}

