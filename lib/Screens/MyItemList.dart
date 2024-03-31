import 'package:flutter/material.dart';
import '../backend/Item.dart';
import '../ui_helper/ItemTile_del.dart';
import '../backend/User.dart';
import 'LostItemPage.dart';
import 'RecommendLost.dart';

class MyItemList extends StatefulWidget {
  final User user;
  final List<Item> itemList;

  MyItemList({Key? key, required this.user, required this.itemList})
      : super(key: key);

  @override
  State<MyItemList> createState() => _MyItemListState();
}

class _MyItemListState extends State<MyItemList> {
  List<Item> get itemList => widget.itemList;
  User get user => widget.user;

  void deleteItem(Item item, int index) {
    setState(() {
      user.deleteItem(item);
      itemList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('My Lost Item'),
        elevation: 0,
      ),
      body: itemList.isEmpty
          ? Center(
              child: Text(
                'No items to display',
                style: TextStyle(fontSize: 18.0),
              ),
            )
          : ListView.builder(
              itemCount: itemList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Navigate to another page when the item is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RecommendLostPage(item: itemList[index]),
                      ),
                    );
                  },
                  child: ItemTileD(
                    item: itemList[index],
                    deleteFunction: (context) =>
                        deleteItem(itemList[index], index),
                  ),
                );
              },
            ),
    );
  }
}
