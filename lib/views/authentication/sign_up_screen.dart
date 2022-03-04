import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetable/constants/colors.dart';
import 'package:timetable/constants/texts.dart';
import 'package:timetable/providers/auth.dart';
import 'package:timetable/views/authentication/sign_in_screen.dart';
import 'package:timetable/views/timetable/timetable_screen.dart';

class SignUpScreen extends StatefulWidget {
  static String routeName = "signup_screen";

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  Map<String, String> _authData = {
    'fullname': '',
    'email': '',
    'password': '',
  };

  final _passwordController = TextEditingController();

  var _isLoading = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An error occurred!'),
        content: Text(message),
        actions: [
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _registerApp() async {
    if (!_formKey.currentState.validate()) {
      // Invalid
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    // Sign up user
    try {
      await Provider.of<Auth>(context, listen: false).signUp(
        _authData['email'],
        _authData['password'],
      );
      Navigator.of(context).popAndPushNamed(TimetableScreen.routeName);
    } on HttpException catch (error) {
      // Catch the validation sign in
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use!';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address!';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = "This password is too weak!";
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email!';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password!';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      // Catch other error (networking, status code,...)
      var errorMessage = 'Could not authenticate you! Please try again later.';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: mainColor,
        body: _isLoading ? Center(child: CircularProgressIndicator(color: Colors.white,),) : Form(
          key: _formKey,
          child: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Column(children: [
                    const SizedBox(
                      height: 80,
                    ),
                    Padding(
                        padding: EdgeInsets.only(bottom: 15),
                        child: Text(
                          'Sign up',
                          style: titleText,
                        )),
                    Text(
                      'Enter the below information to sign up',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextFormField(
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person,
                                color: mainColor,
                              ),
                              errorStyle: TextStyle(fontSize: 20),
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.blueGrey, width: 3.0),
                              ),
                              hintText: "Full Name",
                              hintStyle: TextStyle(
                                  fontSize: 16, color: Colors.grey[85]),
                            ),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your full name!';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _authData['fullname'] = value;
                            },
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.mail,
                                color: mainColor,
                              ),
                              errorStyle: TextStyle(fontSize: 20),
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.blueGrey, width: 3.0),
                              ),
                              hintText: "Email Address",
                              hintStyle: TextStyle(
                                  fontSize: 16, color: Colors.grey[85]),
                            ),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your email!';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email!';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _authData['email'] = value;
                            },
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            obscureText: true,
                            controller: _passwordController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.lock,
                                color: mainColor,
                              ),
                              errorStyle: TextStyle(fontSize: 20),
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.blueGrey, width: 3.0),
                              ),
                              hintText: "Password",
                              hintStyle: TextStyle(
                                  fontSize: 16, color: Colors.grey[85]),
                            ),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your password!';
                              }
                              if (value.length < 6) {
                                return 'Password must be greater than 6!';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _authData['password'] = value;
                            },
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            obscureText: true,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.shield,
                                color: mainColor,
                              ),
                              errorStyle: TextStyle(fontSize: 20),
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.blueGrey, width: 3.0),
                              ),
                              hintText: "Confirm Password",
                              hintStyle: TextStyle(
                                  fontSize: 16, color: Colors.grey[85]),
                            ),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please confirm your password!";
                              }
                              if (value != _passwordController.text) {
                                return "Password do not match!";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 32),
                          RaisedButton(
                            color: Colors.white,
                            textColor: mainColor,
                            child: Container(
                              height: 60,
                              child: Center(
                                child: Text(
                                  'SIGN UP',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Work-Sans",
                                      color: mainColor),
                                ),
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onPressed: () {
                              _registerApp();
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 15),
                            child: RichText(
                              text: TextSpan(
                                  text: 'Already have an account? ',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white),
                                  children: [
                                    TextSpan(
                                      text: 'Sign in',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.pushNamed(
                                              context, SignInScreen.routeName);
                                        },
                                    )
                                  ]),
                            ),
                          )
                        ],
                      ),
                    ),
                  ])))),
        ));
  }
}
