import 'package:flutter/material.dart';
//import '../backend/ItemModel.dart';
//import '../backend/User.dart';
import '../backend/Item.dart';
import '../backend/User.dart';
import '../backend/UserModel.dart';
import '../ui_helper/comHelper.dart';
import '../ui_helper/genLoginSignUpHeader.dart';
import '../ui_helper/genTextFormField.dart';
import 'AdminForm.dart';
import 'HomePage.dart';
import 'SignUpForm.dart';
import '../backend/DbHelper.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = new GlobalKey<FormState>();

  final _conEmail = TextEditingController();
  final _conPassword = TextEditingController();

  var dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
  }

  login() async {
    String email = _conEmail.text;
    String password = _conPassword.text;

    if (email.isEmpty) {
      alertDialog(context, 'Please Enter Email');
    } else if (password.isEmpty) {
      alertDialog(context, 'Please Enter Password');
    } else {
      await dbHelper.getLoginUser(email, password).then((userData) async {
        if (userData != null) {
          List<Item> lostItemList = await dbHelper.getLostItemList(email);

          // Create User object
          User user = User(userData, lostItemList);

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => HomePage(user: user)),
              (Route<dynamic> route) => false);
        } else {
          alertDialog(context, "Error: User Not Found");
        }
      }).catchError((error) {
        print(error);
        alertDialog(context, "Error: Login Fail");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('ClaimIt KMITL: Lost and Found App'),
      ),
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  genLoginSignUpHeader(),
                  getTextFormField(
                    controller: _conEmail,
                    icon: Icons.email,
                    hintName: 'Email',
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  getTextFormField(
                    controller: _conPassword,
                    icon: Icons.lock,
                    hintName: 'Password',
                    isObscureText: true,
                  ),
                  Container(
                    margin: EdgeInsets.all(30.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: TextButton(
                      onPressed: login,
                      child: Text(
                        'Login',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Does not have an account yet?'),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => SignUpForm()));
                        },
                        child: Text('Sign up'),
                      )
                    ],
                  ),
                  TextButton(
                    child: Text(
                      'I am admin',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => AdminForm()));
                    },
                  )
                ],
              ),
            ),
          )),
    );
  }
}
