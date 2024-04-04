import 'package:flutter/material.dart';
import 'package:lost_and_found/backend/EmailSender.dart';
import 'package:lost_and_found/backend/ItemPoster.dart';
import 'package:lost_and_found/main.dart';

import '../backend/Item.dart';
import 'API.dart';
import 'DbHelper.dart';
import 'UserModel.dart';
import '../Screens/UploadForm.dart';
import '../backend/Item.dart';

class User implements ItemPoster {
  UserModel userdetail;
  List<Item>? itemList;

  User(this.userdetail, this.itemList);

  Future<void> post(Item newItem) async {
    try {
      DbHelper dbHelper = DbHelper();

      int itemId = await dbHelper.saveItem(newItem);
      String userEmail = userdetail.getEmail()!;
      await dbHelper.saveLostItem(itemId, userEmail);

      itemList ??= <Item>[];
      itemList!.add(newItem);

      print(itemList?.length);
      print('add item sucessfully');

      await matchAndNotify(newItem);
    } catch (e) {
      print('Error while posting item: $e');
    }
  }

  Future<void> matchAndNotify(Item newItem) async {
    try {
      DbHelper dbHelper = DbHelper();

      List<Item> foundItems =
          await dbHelper.getItemsByCategory(newItem.category!, 'Found');

      for (Item foundItem in foundItems) {
        String similarityString = await APIService.instance.getSimilarityScore(
          newItem.imagePath!,
          foundItem.imagePath!,
        );
        print(similarityString);

        String formattedSimilarityString =
            similarityString.replaceAll(RegExp(r'[^\d.]+'), '');

        double similarity = double.tryParse(formattedSimilarityString) ?? 0;
        print(similarity);

        if (similarity >= 0.7) {
          print('Found a similar item: ${foundItem.name}');
          String fsimilarity = '${(similarity * 100).toStringAsFixed(2)}%';
          await sendMatchingItemEmail(userdetail.getEmail()!, newItem,
              foundItem, fsimilarity, foundItem.imagePath!);
        }
      }
    } catch (e) {
      print('Error while matching and notifying: $e');
    }
  }

  // // Print the number of found items
  // print('Number of found items: ${foundItems.length}');

  // // Iterate over each found item and print its details
  // for (Item foundItem in foundItems) {
  //   print('Found Item:');
  //   print('ID: ${foundItem.id}');
  //   print('Name: ${foundItem.name}');
  //   // Print other attributes as needed
  // }

//not use
  Future<void> delete_Item(int itemId) async {
    try {
      DbHelper dbHelper = DbHelper();

      await dbHelper.deleteItem(itemId);
      await dbHelper.deleteLostItem(itemId);
    } catch (e) {
      print('Error while deleting item: $e');
    }
  }

  Future<void> deleteItem(Item item) async {
    String? email = userdetail.email;
    try {
      DbHelper dbHelper = DbHelper();

      await dbHelper.deleteItemByEmailAndAttributes(email!, item);
    } catch (e) {
      print('Error while deleting item: $e');
    }
  }

  UserModel get getUserDetail => userdetail;

  Future<void> sendMatchingItemEmail(String recipientEmail, Item lostItem,
      Item foundItem, String fsimilarity, String foundItemImagePath) async {
    try {
      final emailSender = EmailSender(
          username: 'gkasita.sst@gmail.com', password: 'ihxy kbao jwvv yefo');

      String subject = 'Matching Item Found! Is this yours?';
      String body = 'Dear User,\n\n'
          'We have found a matching item for your lost item:\n\n'
          'Lost Item: ${lostItem.name}\n'
          'Found Item: ${foundItem.name}\n'
          'There is a high similarity Score: {$fsimilarity} between these items\n\n'
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
}
