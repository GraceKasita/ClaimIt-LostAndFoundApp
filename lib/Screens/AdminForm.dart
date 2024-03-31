import 'package:flutter/material.dart';
import 'package:lost_and_found/Screens/AdminHome.dart';
import '../backend/ItemManager.dart';
import '../ui_helper/genTextFormField.dart';

class AdminForm extends StatefulWidget {
  const AdminForm({Key? key}) : super(key: key);

  @override
  State<AdminForm> createState() => _AdminFormState();
}

class _AdminFormState extends State<AdminForm> {
  final ItemManager itemManager = ItemManager();
  final TextEditingController _conVerify = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Form'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 35.0),
            Image.asset(
              'assets/images/staff.png',
              height: 150,
            ),
            SizedBox(height: 35.0),
            getTextFormField(
              controller: _conVerify,
              hintName: 'Verification Code',
              icon: Icons.description,
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: () async {
                String enteredCode = _conVerify.text;
                bool isCodeCorrect =
                    await itemManager.compareVerificationCode(enteredCode);
                if (isCodeCorrect) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => AdminHome()),
                      (Route<dynamic> route) => false);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Incorrect Verification Code'),
                        content:
                            Text('Please enter the correct verification code.'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.orange, // Set button background color to orange
              ),
              child: Text('Log in'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _conVerify.dispose();
    super.dispose();
  }

  void login() async {}
}
