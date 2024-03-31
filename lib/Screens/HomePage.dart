import 'package:flutter/material.dart';
import 'package:lost_and_found/backend/User.dart';

import 'FoundUserItemPage.dart';
import 'LoginForm.dart';
import 'LostItemPage.dart';
import 'UploadForm.dart';
import '../backend/User.dart';
import 'MyItemList.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String username;
  get user => widget.user;

  @override
  void initState() {
    super.initState();
    // Access user property using widget.user
    username = widget.user.getUserDetail.getUsername()!;
  }

  void _logout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginForm()),
    );
  }

  void _upload(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UploadForm(itemPoster: user)),
    );
  }

  void _onFoundItemListTapped(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              FoundUserItemPage()), // Replace LostItemPage() with your actual page
    );
  }

  void _onLostItemListTapped(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MyItemList(
              user: user,
              itemList: user
                  .itemList)), // Replace LostItemPage() with your actual page
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: Scaffold(
        appBar: null,
        body: Stack(
          children: [
            Container(
              color: Colors.white,
              width: double.infinity,
              height: double.infinity,
            ),
            AspectRatio(
              aspectRatio: 12 / 9,
              child: Container(
                color: Colors.orange,
              ),
            ),
            Positioned(
              left: 35,
              top: MediaQuery.of(context).size.height * 0.15,
              child: Row(
                children: [
                  // Add space between icon and text
                  Text(
                    'Hello $username,\nWelcome to ClaimIt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 45),
                  Icon(
                    Icons.account_circle_sharp,
                    color: Colors.white,
                    size: 70,
                  ),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              right: MediaQuery.of(context).size.width * 0.05,
              child: GestureDetector(
                onTap: () {
                  _onFoundItemListTapped(context);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.black,
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25), // Shadow color
                        spreadRadius: 2, // Spread radius
                        blurRadius: 5, // Blur radius
                        offset: const Offset(0, 4), // Offset
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Found Item List',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.57,
              right: MediaQuery.of(context).size.width * 0.05,
              child: GestureDetector(
                onTap: () {
                  _onLostItemListTapped(context);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.90,
                  height: MediaQuery.of(context).size.height * 0.28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.black,
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25), // Shadow color
                        spreadRadius: 2, // Spread radius
                        blurRadius: 5, // Blur radius
                        offset: const Offset(0, 4), // Offset
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'My Lost Item',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color.fromARGB(255, 237, 237, 239),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: 'Log out',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.upload),
              label: 'Upload',
            ),
          ],
          selectedItemColor: Colors.blue,
          //onTap: _onItemTapped,
          onTap: (int index) {
            if (index == 0) {
              _logout(context); // Logout action when the first tab is tapped
            } else if (index == 1) {
              _upload(context);
            }
          },
        ),
      ),
    );
  }
}
