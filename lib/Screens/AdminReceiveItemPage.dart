import 'package:flutter/material.dart';
import '../backend/DbHelper.dart'; // Import your DbHelper class
import '../backend/Item.dart'; // Import your Item class
import '../ui_helper/ItemTile.dart'; // Import your ItemTile widget

class ReceiveItemPage extends StatefulWidget {
  const ReceiveItemPage({Key? key}) : super(key: key);

  @override
  State<ReceiveItemPage> createState() => _ReceiveItemPageState();
}

class _ReceiveItemPageState extends State<ReceiveItemPage> {
  late Future<List<Item>> receivedItems;

  @override
  void initState() {
    super.initState();
    receivedItems = _getReceivedItems();
  }

  Future<List<Item>> _getReceivedItems() async {
    return await DbHelper().getAllReceivedItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Received Items'),
      ),
      body: FutureBuilder<List<Item>>(
        future: receivedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No received items available.'),
            );
          } else {
            // Display the received items using a ListView.builder
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ItemTile(item: snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }
}
