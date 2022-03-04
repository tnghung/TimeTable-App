import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetable/constants/colors.dart';
import 'package:timetable/constants/texts.dart';
import 'package:timetable/http/http_exception.dart';
import 'package:timetable/providers/auth.dart';
import 'package:timetable/views/authentication/sign_up_screen.dart';
import 'package:timetable/views/timetable/timetable_screen.dart';

class SignInScreen extends StatefulWidget {
  static String routeName = "login_screen";

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey();

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

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

  var _isLoading = false;

  Future<void> _loginApp() async {
    if (!_formKey.currentState.validate()) {
      // Invalid
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    // Sign In app
    try {
      await Provider.of<Auth>(context, listen: false)
          .signIn(_authData['email'], _authData['password']);
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 60,
                        ),
                        Padding(
                            padding: EdgeInsets.only(bottom: 15),
                            child: Text(
                              'Sign in',
                              style: titleText,
                            )),
                        Text(
                          'Login to your account',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
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
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Colors.blueGrey, width: 3.0),
                                  ),
                                  hintText: "Email Address",
                                  hintStyle: TextStyle(
                                      fontSize: 16, color: Colors.grey[85]),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter an email!';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['email'] = value;
                                },
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                obscureText: true,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: mainColor,
                                  ),
                                  errorStyle: TextStyle(fontSize: 20),
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Colors.blueGrey, width: 3.0),
                                  ),
                                  hintText: "Password",
                                  hintStyle: TextStyle(
                                      fontSize: 16, color: Colors.grey[85]),
                                ),
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter a password!';
                                  }
                                  if (value.length < 5) {
                                    return 'Password must be greater than 6!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['password'] = value;
                                },
                              ),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(top: 20, bottom: 20),
                                    child: Text(
                                      "Forgot Password?",
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Colors.white,
                                          fontSize: 12),
                                    ),
                                  )),
                              RaisedButton(
                                color: Colors.white,
                                textColor: mainColor,
                                child: Container(
                                  height: 60,
                                  child: Center(
                                    child: Text(
                                      'SIGN IN',
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
                                  _loginApp();
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 15),
                                child: RichText(
                                  text: TextSpan(
                                      text: 'Don\'t have an account? ',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.white),
                                      children: [
                                        TextSpan(
                                          text: 'Sign up',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.pushNamed(context,
                                                  SignUpScreen.routeName);
                                            },
                                        )
                                      ]),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 15, bottom: 15),
                                child: Row(children: <Widget>[
                                  Expanded(
                                      child: Divider(
                                    color: Colors.white,
                                    height: 10,
                                    thickness: 1,
                                  )),
                                  Padding(
                                      padding:
                                          EdgeInsets.only(left: 10, right: 10),
                                      child: Text(
                                        "OR",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      )),
                                  Expanded(
                                      child: Divider(
                                    color: Colors.white,
                                    height: 10,
                                    thickness: 1,
                                  )),
                                ]),
                              ),
                              RaisedButton(
                                color: Colors.white,
                                textColor: mainColor,
                                child: Container(
                                    height: 60,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 10),
                                              child: Icon(
                                                Icons.facebook,
                                                size: 36,
                                              )),
                                          SizedBox(width: 15),
                                          Text(
                                            'LOGIN WITH FACEBOOK',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Work-Sans",
                                                color: mainColor),
                                          ),
                                        ])),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                onPressed: () {
                                  // login with facebook
                                },
                              ),
                              SizedBox(height: 15),
                              RaisedButton(
                                color: Color(0xffE75A4C),
                                textColor: Colors.white,
                                child: Container(
                                    height: 60,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 10),
                                              child: Image.asset(
                                                "assets/google.png",
                                                height: 32,
                                              )),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Text(
                                            'LOGIN WITH GOOGLE',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Work-Sans",
                                                color: Colors.white),
                                          ),
                                        ])),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                onPressed: () {
                                  // login with google
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
