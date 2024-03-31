import 'package:flutter/material.dart';

import '../backend/Item.dart';
import '../backend/Search/CategoryFilterStrategy.dart';
import '../backend/Search/ColorFilterStrategy.dart';
import '../backend/Search/CompositeSearchStrategy.dart';
import '../backend/Search/LocationFilterStrategy.dart';
import '../backend/Search/SearchStrategy.dart';
import '../ui_helper/ItemTile.dart'; // Import your Item class

class LostItemPage extends StatefulWidget {
  const LostItemPage({Key? key}) : super(key: key);

  @override
  State<LostItemPage> createState() => _LostItemPageState();
}

class _LostItemPageState extends State<LostItemPage> {
  String? selectedCategory;
  String? selectedColor;
  String? selectedLocation;
  late List<Item> filteredItems = []; // Initialize with an empty list

  final List<String> categories = [
    'none',
    'IT Gadget',
    'Stationary',
    'Personal Belonging',
    'Bag',
    'Others'
  ];
  final List<String> colors = [
    'none',
    'Red',
    'Green',
    'Blue',
    'Yellow',
    'Orange',
    'Purple',
    'Pink',
    'Brown',
    'Black',
    'White',
    'Gray',
    'Other'
  ];
  final List<String> locations = [
    'none',
    'HM Building',
    'ECC Building',
    'Engineering Faculty',
    'Architect Faculty',
    'Science Faculty',
    'Business Faculty',
    'Art Faculty',
    'Others'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lost Items'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              hint: Text('Category'),
              value: selectedCategory,
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              hint: Text('Color'),
              value: selectedColor,
              items: colors.map((color) {
                return DropdownMenuItem(
                  value: color,
                  child: Text(color),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedColor = value;
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              hint: Text('Location'),
              value: selectedLocation,
              items: locations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLocation = value;
                });
              },
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () {
                // Implement filter logic here
                filterItems();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: Text('Filter Items'),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return ItemTile(
                  item: filteredItems[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void filterItems() async {
    // Create your search strategies based on selected criteria
    List<SearchStrategy> strategies = [];

    if (selectedCategory != 'none' &&
        selectedCategory != null &&
        selectedCategory!.isNotEmpty) {
      strategies.add(CategoryFilterStrategy(selectedCategory!, 'Lost'));
    }

    if (selectedColor != 'none' &&
        selectedColor != null &&
        selectedColor!.isNotEmpty) {
      strategies.add(ColorFilterStrategy(selectedColor!, 'Lost'));
    }

    if (selectedLocation != 'none' &&
        selectedLocation != null &&
        selectedLocation!.isNotEmpty) {
      strategies.add(LocationFilterStrategy(selectedLocation!, 'Lost'));
    }

    // Use composite strategy to combine all selected strategies
    CompositeSearchStrategy compositeStrategy =
        CompositeSearchStrategy(strategies, itemType: ItemType.Lost);

    // Filter items
    List<Item> filtered = await compositeStrategy.filterItems();

    setState(() {
      filteredItems = filtered;
    });
  }
}
