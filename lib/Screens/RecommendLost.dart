import 'dart:io';
import 'package:flutter/material.dart';
import '../backend/Item.dart';
import '../backend/Search/CategoryFilterStrategy.dart';
import '../backend/Search/ColorFilterStrategy.dart';
import '../backend/Search/CompositeSearchStrategy.dart';
import '../backend/Search/LocationFilterStrategy.dart';
import '../backend/Search/SearchStrategy.dart';
import '../ui_helper/ItemTile.dart';

class RecommendLostPage extends StatefulWidget {
  final Item item;

  RecommendLostPage({required this.item});

  @override
  _RecommendLostPageState createState() => _RecommendLostPageState();
}

class _RecommendLostPageState extends State<RecommendLostPage> {
  late Item _displayedItem;
  List<Item> filteredItems = [];

  @override
  void initState() {
    super.initState();
    _displayedItem = widget.item;
    // Call a method to filter related items based on category, color, location if needed.
    filterItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Details'),
      ),
      body: ListView(
        children: [
          // Display details of the displayed item
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.orange,
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 100,
                height: 100,
                child: _displayedItem.imagePath != null &&
                        File(_displayedItem.imagePath!).existsSync()
                    ? Image.file(
                        File(_displayedItem
                            .imagePath!), // Load image from file path
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : Placeholder(), // Placeholder if image is not available
              ),
              title: Text(
                _displayedItem.name ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold, // Make name text bold
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Color: ${_displayedItem.color ?? ''}'),
                  Text('Category: ${_displayedItem.category ?? ''}'),
                  Text('Location: ${_displayedItem.location ?? ''}'),
                  Text('Description: ${_displayedItem.description ?? ''}'),
                ],
              ),
            ),
          ),
          // Display filtered items based on selected criteria
          Container(
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return ItemTile(item: filteredItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  void filterItems() async {
    // Create search strategies based on selected criteria
    List<SearchStrategy> strategies = [];

    if (_displayedItem.category != null &&
        _displayedItem.category!.isNotEmpty) {
      print(_displayedItem.category);
      strategies.add(CategoryFilterStrategy(_displayedItem.category!, 'Found'));
    }

    if (_displayedItem.color != null && _displayedItem.color!.isNotEmpty) {
      print(_displayedItem.color);
      strategies.add(ColorFilterStrategy(_displayedItem.color!, 'Found'));
    }

    if (_displayedItem.location != null &&
        _displayedItem.location!.isNotEmpty) {
      print(_displayedItem.location);
      strategies.add(LocationFilterStrategy(_displayedItem.location!, 'Found'));
    }

    // Use composite strategy to combine all selected strategies
    CompositeSearchStrategy compositeStrategy =
        CompositeSearchStrategy(strategies, itemType: ItemType.Found);

    // Filter items
    List<Item> filtered = await compositeStrategy.filterItems();

    setState(() {
      filteredItems = filtered;
    });
  }
}
