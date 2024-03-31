import 'package:flutter/material.dart';
import 'package:lost_and_found/ui_helper/genLoginSignUpHeader.dart';
import 'package:lost_and_found/backend/DbHelper.dart';
//import 'package:lost_and_found/backend/UserModel.dart';
import 'package:lost_and_found/Screens/LoginForm.dart';

import '../backend/UserModel.dart';
import '../ui_helper/comHelper.dart';
import '../ui_helper/genTextFormField.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  final _conUsername = TextEditingController();
  final _conEmail = TextEditingController();
  final _conPassword = TextEditingController();
  final _conCPassword = TextEditingController();

  var dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
  }

  signUp() async {
    String email = _conEmail.text;
    String username = _conUsername.text;
    String password = _conPassword.text;
    String cpassword = _conCPassword.text;

    if (_formKey.currentState!.validate()) {
      if (password != cpassword) {
        alertDialog(context, 'Password Mismatch');
      } else {
        _formKey.currentState?.save();

        UserModel uModel = UserModel(username, email, password);
        await dbHelper.saveUserData(uModel).then((userData) {
          alertDialog(context, "Successfully saved");
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => LoginForm()));
        }).catchError((error) {
          print(error);
          alertDialog(context, "Error: Data Saving Fail");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  genLoginSignUpHeader(),
                  getTextFormField(
                    controller: _conUsername,
                    icon: Icons.person,
                    inputType: TextInputType.name,
                    hintName: 'Username',
                  ),
                  SizedBox(height: 10.0),
                  getTextFormField(
                    controller: _conEmail,
                    icon: Icons.email,
                    inputType: TextInputType.emailAddress,
                    hintName: 'Email',
                  ),
                  SizedBox(height: 10.0),
                  getTextFormField(
                    controller: _conPassword,
                    icon: Icons.lock,
                    hintName: 'Password',
                    isObscureText: true,
                  ),
                  SizedBox(height: 10.0),
                  getTextFormField(
                    controller: _conCPassword,
                    icon: Icons.lock,
                    hintName: 'Confirm Password',
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
                      onPressed: signUp,
                      child: Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Do you have an account?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => LoginForm()),
                              (Route<dynamic> route) => false);
                        },
                        child: Text('Log In'),
                      )
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
