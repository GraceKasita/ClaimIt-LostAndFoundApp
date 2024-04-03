//database class

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

import 'UserModel.dart';
import 'Item.dart';

class DbHelper {
  static Database? _db;

  static const DB_Name = 'test_db13';

  //table name
  static const String Table_User = 'user_table';
  //attribute: name, category, color, location, description, image_path, itemtype
  static const String Table_Item = 'item_table';
  //addition attr: itemId, user [itemid, email]
  static const String Table_LostItem = 'lostItem_table';
  //addition attr: itemId, receivedBy [item3, john]
  static const String Table_FoundItem = 'foundItem_table';

  static const int Version = 1;

  //for user table
  static const String? C_Username = 'user_name';
  static const String? C_Email = 'email';
  static const String? C_Password = 'password';

  //for item table
  static const String? C_Name = 'name';
  static const String? C_Category = 'category';
  static const String? C_Color = 'color';
  static const String? C_Location = 'location';
  static const String? C_Description = 'description';
  static const String? C_ImagePath = 'image_path';
  static const String? C_ItemType = 'item_type';

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }

    _db = await initDb();

    return db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_Name);
    var db = await openDatabase(path, version: Version, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE $Table_User("
        "$C_Username TEXT, "
        "$C_Email TEXT, "
        "$C_Password TEXT, "
        "PRIMARY KEY ($C_Email)"
        ")");
    await db.execute("CREATE TABLE $Table_Item ("
        "item_id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "$C_Name TEXT, "
        "$C_Category TEXT, "
        "$C_Color TEXT, "
        "$C_Location TEXT, "
        "$C_Description TEXT, "
        "$C_ImagePath TEXT, "
        "$C_ItemType TEXT)");
    await db.execute("CREATE TABLE $Table_LostItem ("
        "item_id INTEGER, "
        "email TEXT, "
        "FOREIGN KEY (item_id) REFERENCES $Table_Item(item_id), "
        "FOREIGN KEY (email) REFERENCES $Table_User($C_Email), "
        "UNIQUE (item_id, email)"
        ")");
    await db.execute("CREATE TABLE $Table_FoundItem ("
        "item_id INTEGER, "
        "name TEXT, "
        "email TEXT, "
        "FOREIGN KEY (item_id) REFERENCES $Table_Item(item_id), "
        "FOREIGN KEY (email) REFERENCES $Table_User($C_Email)"
        ")");
  }

  //user table -> save
  Future<int> saveUserData(UserModel user) async {
    var dbClient = await db;
    var res = await dbClient!.insert(Table_User, user.toMap());
    return res;
  }

  //user table -> retrieve
  Future<UserModel?> getLoginUser(String email, String password) async {
    var dbClient = await db;
    var res = await dbClient!.rawQuery("SELECT * FROM $Table_User WHERE "
        "$C_Email = '$email' AND "
        "$C_Password = '$password' ");

    if (res.length > 0) {
      return UserModel.fromMap(res.first);
    }

    return null;
  }
  /*
  //user retreive by email
  Future<UserModel?> getUserByEmail(String email) async {
    var dbClient = await db;
    List<Map<String, dynamic>> res = await dbClient!.query(
      Table_User,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (res.isNotEmpty) {
      return UserModel.fromMap(res as Map<String, dynamic>);
    }

    return null;
  } */

  //item table -> save
  Future<int> saveItem(Item item) async {
    var dbClient = await db;
    var res = await dbClient!.insert(Table_Item, item.toMap());
    return res;
  }

  Future<int> saveLostItem(int itemId, String email) async {
    var dbClient = await db;
    int res = await dbClient!.rawInsert(
      'INSERT INTO $Table_LostItem (item_id, email) VALUES (?, ?)',
      [itemId, email],
    );
    return res;
  }

  //item table -> retreive
  Future<Item?> getItemById(int itemId) async {
    var dbClient = await db;
    List<Map<String, dynamic>> res = await dbClient!.query(
      Table_Item,
      where: 'item_id = ?',
      whereArgs: [itemId],
    );

    if (res.isNotEmpty) {
      return Item.fromMap(res.first);
    }

    return null;
  }

  //delete item
  Future<int> deleteItem(int itemId) async {
    var dbClient = await db;
    int res = await dbClient!.delete(
      Table_Item,
      where: 'item_id = ?',
      whereArgs: [itemId],
    );
    return res;
  }

  Future<int> deleteLostItem(int itemId) async {
    var dbClient = await db;
    int res = await dbClient!.delete(
      Table_LostItem,
      where: 'item_id = ?',
      whereArgs: [itemId],
    );
    return res;
  }

  Future<List<Item>> getLostItemList(String userEmail) async {
    var dbClient = await db;
    List<Map<String, dynamic>> lostItemRecords = await dbClient!.query(
      Table_LostItem,
      where: 'email = ?',
      whereArgs: [userEmail],
    );

    List<int> lostItemIds =
        lostItemRecords.map((record) => record['item_id'] as int).toList();
    List<Item> lostItems = <Item>[];

    for (int itemId in lostItemIds) {
      Item? item = await getItemById(itemId);
      if (item != null) {
        lostItems.add(item);
      }
    }

    return lostItems;
  }

  // Found Item table -> save
  Future<int> saveFoundItem(int itemId, String name, String email) async {
    var dbClient = await db;
    int res = await dbClient!.rawInsert(
      'INSERT INTO $Table_FoundItem (item_id, name, email) VALUES (?, ?, ?)',
      [itemId, name, email],
    );
    return res;
  }

  Future<int> saveReceiveItem(int itemId, String name, String email) async {
    var dbClient = await db;
    int res = await dbClient!.rawInsert(
      'INSERT INTO $Table_FoundItem (item_id, name, email) VALUES (?, ?, ?)',
      [itemId, name, email],
    );
    return res;
  }

/*
// Delete found item
  Future<int> deleteFoundItem(int itemId) async {
    var dbClient = await db;
    int res = await dbClient!.delete(
      Table_FoundItem,
      where: 'item_id = ?',
      whereArgs: [itemId],
    );
    return res;
  }

//not work
  Future<void> deleteItemByType(int itemId, String oldItemType) async {
    // Delete item from the item_table based on ID and old item type
    var dbClient = await db;
    await dbClient!.delete(
      Table_Item,
      where: 'id = ? AND item_type = ?',
      whereArgs: [itemId, oldItemType],
    );
  } */

  Future<List<Item>> getItemsByColor(String color, String itemType) async {
    var dbClient = await db;

    // Adjust the color pattern to search for the specified color
    String whereClause = "color LIKE ? AND item_type = ?";
    List<dynamic> whereArgs = ['%$color%', itemType];

    List<Map<String, dynamic>> res = await dbClient!.query(
      Table_Item,
      where: whereClause,
      whereArgs: whereArgs,
    );

    List<Item> items = [];
    for (var itemMap in res) {
      items.add(Item.fromMap(itemMap));
    }
    return items;
  }

  // Method to get items by category
  Future<List<Item>> getItemsByCategory(
      String category, String itemType) async {
    var dbClient = await db;
    List<Map<String, dynamic>> res = await dbClient!.query(
      Table_Item,
      where: 'category = ? AND item_type = ?',
      whereArgs: [category, itemType],
    );

    List<Item> items = [];
    for (var itemMap in res) {
      items.add(Item.fromMap(itemMap));
    }
    return items;
  }

  // Method to get items by location
  Future<List<Item>> getItemsByLocation(
      String location, String itemType) async {
    var dbClient = await db;
    List<Map<String, dynamic>> res = await dbClient!.query(
      Table_Item,
      where: 'location = ? AND item_type = ?',
      whereArgs: [location, itemType],
    );

    List<Item> items = [];
    for (var itemMap in res) {
      items.add(Item.fromMap(itemMap));
    }
    return items;
  }

  Future<List<Item>> getItemsByCategoryAndType(
      String category, String itemType) async {
    var dbClient = await db;
    List<Map<String, dynamic>> res = await dbClient!.query(
      Table_Item,
      where: 'category = ? AND item_type = ?',
      whereArgs: [category, itemType],
    );

    List<Item> items = [];
    for (var itemMap in res) {
      items.add(Item.fromMap(itemMap));
    }
    return items;
  }

  // Method to get all found items
  Future<List<Item>> getAllFoundItems() async {
    var dbClient = await db;
    List<Map<String, dynamic>> res = await dbClient!.query(
      Table_Item,
      where: '$C_ItemType = ?',
      whereArgs: ['Found'],
    );

    List<Item> foundItems = [];
    for (var itemMap in res) {
      foundItems.add(Item.fromMap(itemMap));
    }
    return foundItems;
  }

  Future<List<Item>> getAllLostItems() async {
    var dbClient = await db;
    List<Map<String, dynamic>> res = await dbClient!.query(
      Table_Item,
      where: '$C_ItemType = ?',
      whereArgs: ['Lost'],
    );

    List<Item> foundItems = [];
    for (var itemMap in res) {
      foundItems.add(Item.fromMap(itemMap));
    }
    return foundItems;
  }

  Future<List<Item>> getAllReceivedItems() async {
    var dbClient = await db;

    List<Map<String, dynamic>> res = await dbClient!.query(
      Table_Item,
      where: '$C_ItemType = ?',
      whereArgs: ['Received'],
    );

    List<Item> receivedItems = [];
    for (var itemMap in res) {
      receivedItems.add(Item.fromMap(itemMap));
    }

    return receivedItems;
  }

  Future<int> deleteItemByEmailAndAttributes(String email, Item item) async {
    var dbClient = await db;

    // Retrieve all item IDs associated with the given email
    List<Map<String, dynamic>> lostItemRecords = await dbClient!.query(
      Table_LostItem,
      where: 'email = ?',
      whereArgs: [email],
    );

    List<int> lostItemIds =
        lostItemRecords.map((record) => record['item_id'] as int).toList();
    int deletedItemCount = 0;

    for (int itemId in lostItemIds) {
      // Retrieve the corresponding item from the item_table
      Item? retrievedItem = await getItemById(itemId);

      // Compare attributes with the passed item
      if (retrievedItem != null &&
          retrievedItem.name == item.name &&
          retrievedItem.category == item.category &&
          retrievedItem.color == item.color &&
          retrievedItem.location == item.location &&
          retrievedItem.description == item.description &&
          retrievedItem.imagePath == item.imagePath &&
          retrievedItem.itemType == item.itemType) {
        // Delete the item from the item_table
        int res = await dbClient.delete(
          Table_Item,
          where: 'item_id = ?',
          whereArgs: [itemId],
        );
        if (res > 0) {
          deletedItemCount++;
        }
      }
    }

    return deletedItemCount;
  }

  Future<void> updateItemTypeToReceive(
      Item item, String name, String email) async {
    var dbClient = await db;

    // Retrieve the item from the database based on its attributes
    List<Map<String, dynamic>> res = await dbClient!.query(
      Table_Item,
      where: '$C_Name = ? AND '
          '$C_Category = ? AND '
          '$C_Color = ? AND '
          '$C_Location = ? AND '
          '$C_Description = ? AND '
          '$C_ImagePath = ? AND '
          '$C_ItemType = ?',
      whereArgs: [
        item.name,
        item.category,
        item.color,
        item.location,
        item.description,
        item.imagePath,
        item.itemType,
      ],
    );

    // If the item is found, update its itemType field to "Receive"
    if (res.isNotEmpty) {
      int itemId = res.first['item_id']; // Retrieve the item ID from the result
      await dbClient.update(
        Table_Item,
        {C_ItemType!: 'Received'},
        where: 'item_id = ?',
        whereArgs: [itemId], // Use the retrieved item ID for the update
      );
      await saveReceiveItem(itemId, name, email);
    }
  }

  //getItemID
  Future<int?> getItemIdByAttributes(Item item) async {
    var dbClient = await db;
    List<Map<String, dynamic>> res = await dbClient!.query(
      Table_Item,
      where: '$C_Name = ? AND '
          '$C_Category = ? AND '
          '$C_Color = ? AND '
          '$C_Location = ? AND '
          '$C_Description = ? AND '
          '$C_ImagePath = ? AND '
          '$C_ItemType = ?',
      whereArgs: [
        item.name,
        item.category,
        item.color,
        item.location,
        item.description,
        item.imagePath,
        item.itemType,
      ],
    );

    if (res.isNotEmpty) {
      return res.first['item_id'] as int?;
    }

    return null;
  }

  Future<String?> getEmailByItemIdFromLostTable(int itemId) async {
    var dbClient = await db;
    List<Map<String, dynamic>> res = await dbClient!.query(
      Table_LostItem,
      where: 'item_id = ?',
      whereArgs: [itemId],
    );

    if (res.isNotEmpty) {
      return res.first['email'] as String?;
    }

    return null;
  }

  Future<Map<String, String>?> getNameAndEmailFromFoundItem(Item item) async {
    var dbClient = await db;

    // Search for the item in the item_table
    List<Map<String, dynamic>> res = await dbClient!.query(
      Table_Item,
      where: '$C_Name = ? AND '
          '$C_Category = ? AND '
          '$C_Color = ? AND '
          '$C_Location = ? AND '
          '$C_Description = ? AND '
          '$C_ImagePath = ? AND '
          '$C_ItemType = ?',
      whereArgs: [
        item.name,
        item.category,
        item.color,
        item.location,
        item.description,
        item.imagePath,
        item.itemType,
      ],
    );

    if (res.isNotEmpty) {
      // If the item exists in the item_table, retrieve its ID
      int itemId = res.first['item_id'] as int;

      // Search for corresponding entries in the foundItem_table using the item ID
      List<Map<String, dynamic>> foundItems = await dbClient.query(
        Table_FoundItem,
        where: 'item_id = ?',
        whereArgs: [itemId],
      );

      if (foundItems.isNotEmpty) {
        // Extract name and email associated with the found item
        String name = foundItems.first['name'];
        String email = foundItems.first['email'];

        return {'name': name, 'email': email};
      }
    }

    return null; // Return null if the item is not found in the item_table or if no corresponding entry is found in the foundItem_table
  }

  Future<Map<String, String>?> getLostItemOwnerDetails(Item item) async {
    var dbClient = await db;

    // Retrieve the item ID based on its attributes
    int? itemId = await getItemIdByAttributes(item);

    if (itemId != null) {
      // Search for the item ID in the lostItem_table to get the associated email
      List<Map<String, dynamic>> lostItemRecords = await dbClient!.query(
        Table_LostItem,
        where: 'item_id = ?',
        whereArgs: [itemId],
      );

      if (lostItemRecords.isNotEmpty) {
        String email = lostItemRecords.first['email'];

        List<Map<String, dynamic>> userRecords = await dbClient.query(
          Table_User,
          where: 'email = ?',
          whereArgs: [email],
        );

        if (userRecords.isNotEmpty) {
          String username = userRecords.first['user_name'];

          return {'username': username, 'email': email};
        }
      }
    }

    return null;
  }
}
