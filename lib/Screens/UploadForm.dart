import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lost_and_found/backend/ItemPoster.dart';
import '../backend/ItemManager.dart';
import '../backend/User.dart';
import '../backend/API.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../backend/Item.dart';
import '../ui_helper/genDropDown.dart';
import '../ui_helper/genTextFormField.dart';

class UploadForm extends StatefulWidget {
  final ItemPoster itemPoster;
  UploadForm({super.key, required this.itemPoster});
  @override
  _UploadFormState createState() => _UploadFormState();
}

class _UploadFormState extends State<UploadForm> {
  String? selectedColor;
  String? selectedCategory;
  String? selectedLocation;
  String name = '';
  String description = '';

  final _conName = TextEditingController();
  final _conColor = TextEditingController();
  final _conLocation = TextEditingController();
  final _conCategory = TextEditingController();
  final _conDescription = TextEditingController();

  File? _selectedImage;

  void updateTextField(String newText) {
    setState(() {
      _conName.text = newText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Form'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10),
              Container(
                height: 200,
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Text(
                          "Please select an image",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _pickImageFromGallery();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text(
                      'Pick Image',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      _openCamera();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text(
                      'Open Camera',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              getTextFormField(
                controller: _conName,
                hintName: 'Name',
                icon: Icons.inventory,
              ),
              SizedBox(height: 8),
              getDropdownFormField(
                hintName: 'Category',
                items: [
                  'IT Gadget',
                  'Stationary',
                  'Personal Belonging',
                  'Bag',
                  'Others'
                ],
                icon: Icons.category,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                value: selectedCategory,
              ),
              SizedBox(height: 8),
              getDropdownFormField(
                hintName: 'Color',
                items: [
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
                ],
                icon: Icons.color_lens,
                onChanged: (value) {
                  setState(() {
                    selectedColor = value;
                  });
                },
                value: selectedColor,
              ),
              SizedBox(height: 8),
              getDropdownFormField(
                hintName: 'Location',
                items: [
                  'HM Building',
                  'ECC Building',
                  'Engineering Faculty',
                  'Architect Faculty',
                  'Science Faculty',
                  'Business Faculty',
                  'Art Faculty',
                  'Others'
                ],
                icon: Icons.location_on,
                onChanged: (value) {
                  setState(() {
                    selectedLocation = value;
                  });
                },
                value: selectedLocation,
              ),
              SizedBox(height: 8),
              getTextFormField(
                controller: _conDescription,
                hintName: 'Description',
                icon: Icons.description,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _uploadItem();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text(
                      'Upload',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadItem() async {
    if (_selectedImage == null ||
        selectedCategory == null ||
        selectedColor == null ||
        selectedLocation == null ||
        _conName.text.isEmpty ||
        _conDescription.text.isEmpty) {
      // Display an error message or alert the user about missing information
      return;
    }

    String itemType = widget.itemPoster.runtimeType == User ? 'Lost' : 'Found';

    Item item = Item(
      name: _conName.text,
      category: selectedCategory,
      color: selectedColor,
      location: selectedLocation,
      description: _conDescription.text,
      imagePath: _selectedImage!.path,
      itemType: itemType,
    );

    try {
      await widget.itemPoster.post(item);
      _showSuccessDialog();
      print('Item uploaded successfully');
    } catch (e) {
      print('Error uploading item: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Upload Successful'),
            content: Text('Your item has been successfully uploaded'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        });
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        String detectedObject = await APIService.instance
            .getDetected(pickedFile.path); // Pass the file path
        String cleanedDetectedObject = detectedObject.substring(1);

        // Remove the last two characters
        cleanedDetectedObject = cleanedDetectedObject.substring(
            0, cleanedDetectedObject.length - 1);

        print('Detected Object: $cleanedDetectedObject');
        updateTextField(cleanedDetectedObject);
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _openCamera() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        String detectedObject = await APIService.instance
            .getDetected(pickedFile.path); // Pass the file path

        String cleanedDetectedObject = detectedObject.substring(1);

        // Remove the last two characters
        cleanedDetectedObject = cleanedDetectedObject.substring(
            0, cleanedDetectedObject.length - 1);

        print('Detected Object: $cleanedDetectedObject');
        updateTextField(cleanedDetectedObject);
      } else {
        print('No image selected from camera.');
      }
    } catch (e) {
      print('Error opening camera: $e');
    }
  }
}
