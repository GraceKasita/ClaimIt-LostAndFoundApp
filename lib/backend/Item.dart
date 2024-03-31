class Item {
  static const String C_Name = 'name';
  static const String C_Category = 'category';
  static const String C_Color = 'color';
  static const String C_Location = 'location';
  static const String C_Description = 'description';
  static const String C_ImagePath = 'image_path';
  static const String C_ItemType = 'item_type';

  String? name;
  String? category;
  String? color;
  String? location;
  String? description;
  String? imagePath;
  String? itemType;

  Item(
      {this.name,
      this.category,
      this.color,
      this.location,
      this.description,
      this.imagePath,
      this.itemType});

  Map<String, dynamic> toMap() {
    return {
      C_Name: name,
      C_Category: category,
      C_Color: color,
      C_Location: location,
      C_Description: description,
      C_ImagePath: imagePath,
      C_ItemType: itemType,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
        name: map[C_Name],
        category: map[C_Category],
        color: map[C_Color],
        location: map[C_Location],
        description: map[C_Description],
        imagePath: map[C_ImagePath],
        itemType: map[C_ItemType]);
  }

  void updateItemType(String newType) {
    this.itemType = newType;
  }
}
