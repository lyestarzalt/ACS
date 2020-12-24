import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'clipper.dart';
import 'custom/customTextField.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginRegister extends StatefulWidget {
  @override
  _LoginRegisterState createState() => _LoginRegisterState();
}

//add data here

//
class _LoginRegisterState extends State<LoginRegister> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PersistentBottomSheetController _sheetController;
  String _email;
  String _password;
  String _displayName;
  bool _loading = false;
  bool _autoValidate = false;
  String errorMsg = "";
  final String project1 = 'assets/project1.svg';
  final String register = 'assets/register.svg';
  final String login = 'assets/login.svg';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Colors.blueAccent;

    //GO logo widget
    Widget logo() {
      return Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 220,
          child: Stack(
            children: <Widget>[
              Positioned(
                  child: Container(
                child: Align(
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    width: 500,
                    height: 500,
                  ),
                ),
                height: 154,
              )),
              Positioned(
                child: Container(
                    height: 154,
                    child: Align(
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: AssetImage('assets/logo.png'),
                        // AssetImage('images/avatar.png')
                      ),
                    )),
              ),
            ],
          ),
        ),
      );
    }

    //button widgets
    Widget filledButton(String text, Color splashColor, Color highlightColor,
        Color fillColor, Color textColor, void function()) {
      return RaisedButton(
        highlightElevation: 0.0,
        splashColor: splashColor,
        highlightColor: highlightColor,
        elevation: 0.0,
        color: fillColor,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)),
        child: Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: textColor, fontSize: 20),
        ),
        onPressed: () {
          function();
        },
      );
    }

    outlineButton(void function()) {
      return OutlineButton(
        highlightedBorderColor: Colors.white,
        borderSide: BorderSide(color: Colors.white, width: 2.0),
        highlightElevation: 0.0,
        splashColor: Colors.white,
        highlightColor: Colors.blueAccent,
        color: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(30.0),
        ),
        child: Text(
          "Register",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
          function();
        },
      );
    }

    void _validateLoginInput() async {
      final FormState form = _formKey.currentState;
      if (_formKey.currentState.validate()) {
        form.save();
        _sheetController.setState(() {
          _loading = true;
        });
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _email,
            password: _password,
          );
          Navigator.of(context).pushReplacementNamed('/home');
        } catch (error) {
          switch (error.code) {
            case "ERROR_USER_NOT_FOUND":
              {
                _sheetController.setState(() {
                  errorMsg =
                      "There is no user with such entries. Please try again.";

                  _loading = false;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Text(errorMsg),
                        ),
                      );
                    });
              }
              break;
            case "ERROR_WRONG_PASSWORD":
              {
                _sheetController.setState(() {
                  errorMsg = "Password doesn\'t match your email.";
                  _loading = false;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Text(errorMsg),
                        ),
                      );
                    });
              }
              break;
            default:
              {
                _sheetController.setState(() {
                  errorMsg = "";
                });
              }
          }
        }
      } else {
        setState(() {
          _autoValidate = true;
        });
      }
    }

    void _validateRegisterInput() async {
      final FormState form = _formKey.currentState;
      if (_formKey.currentState.validate()) {
        form.save();
        _sheetController.setState(() {
          _loading = true;
        });
        try {
          FirebaseUser user = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: _email, password: _password);

          UserUpdateInfo userUpdateInfo = new UserUpdateInfo();

          userUpdateInfo.displayName = _displayName;
          final uid = user.uid;
//
//Upload data of the users to the database
//
//
          user.updateProfile(userUpdateInfo).then((onValue) {
            Firestore.instance.collection('users').document(uid).setData({
              'email': _email,
              'userID': uid,
              'displayName': _displayName
            }).then((onValue) {
              print('this is the user i${user.uid}');
              _sheetController.setState(() {
                _loading = false;
              });
            });

            Navigator.of(context).pushReplacementNamed('/home');
          });
        } catch (error) {
          switch (error.code) {
            case "ERROR_EMAIL_ALREADY_IN_USE":
              {
                _sheetController.setState(() {
                  errorMsg = "This email is already in use.";
                  _loading = false;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Text(errorMsg),
                        ),
                      );
                    });
              }
              break;
            case "ERROR_WEAK_PASSWORD":
              {
                _sheetController.setState(() {
                  errorMsg = "The password must be 6 characters long or more.";
                  _loading = false;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Text(errorMsg),
                        ),
                      );
                    });
              }
              break;
            default:
              {
                _sheetController.setState(() {
                  errorMsg = "";
                });
              }
          }
        }
      } else {
        setState(() {
          _autoValidate = true;
        });
      }
      //////////////

      /////////////////////////
    }

    String emailValidator(String value) {
      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      if (value.isEmpty) return '*Required';
      if (!regex.hasMatch(value))
        return '*Enter a valid email';
      else
        return null;
    }

    void loginSheet() {
      _sheetController = _scaffoldKey.currentState
          .showBottomSheet<void>((BuildContext context) {
        return DecoratedBox(
          decoration: BoxDecoration(color: Theme.of(context).canvasColor),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0)),
            child: Container(
              child: ListView(
                children: <Widget>[
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: 10,
                          top: 10,
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.close,
                                size: 30.0, color: Colors.blueAccent),
                          ),
                        )
                      ],
                    ),
                    height: 50,
                    width: 50,
                  ),
                  SingleChildScrollView(
                      child: Form(
                    key: _formKey,
                    // ignore: deprecated_member_use
                    autovalidate: _autoValidate,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Happy to you Again',
                          style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 300,
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                child: Align(
                                  child: Container(
                                    width: 400,
                                    height: 500,
                                  ),
                                  alignment: Alignment.center,
                                ),
                              ),
                              Container(
                                color: Colors.transparent,
                                child: SvgPicture.asset(
                                  login,
                                  fit: BoxFit.contain,
                                  allowDrawingOutsideViewBox: true,
                                ),
                                alignment: Alignment.center,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(bottom: 20, top: 10),
                            child: CustomTextField(
                              onSaved: (input) {
                                _email = input;
                              },
                              validator: emailValidator,
                              icon: Icon(Icons.email),
                              hint: "EMAIL",
                            )),
                        Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: CustomTextField(
                              icon: Icon(Icons.lock),
                              obsecure: true,
                              onSaved: (input) => _password = input,
                              validator: (input) =>
                                  input.isEmpty ? "*Required" : null,
                              hint: "PASSWORD",
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: _loading == true
                              ? CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      primaryColor),
                                )
                              : Container(
                                  child: filledButton(
                                      "Let's Go",
                                      Colors.white,
                                      primaryColor,
                                      primaryColor,
                                      Colors.white,
                                      _validateLoginInput),
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  )),
                ],
              ),
              height: MediaQuery.of(context).size.height / 1.1,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
            ),
          ),
        );
      });
    }

    void registerSheet() {
      _sheetController = _scaffoldKey.currentState
          .showBottomSheet<void>((BuildContext context) {
        return DecoratedBox(
          decoration: BoxDecoration(color: Theme.of(context).canvasColor),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0)),
            child: Container(
              child: ListView(
                children: <Widget>[
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: 10,
                          top: 10,
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.close,
                              size: 30.0,
                              color: Colors.blueAccent,
                            ),
                          ),
                        )
                      ],
                    ),
                    height: 50,
                    width: 50,
                  ),
                  SingleChildScrollView(
                      child: Form(
                    child: Column(children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 330,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Welcome Aboard',
                              style: GoogleFonts.nunito(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            new Container(
                              child: SvgPicture.asset(
                                register,
                                fit: BoxFit.contain,
                                allowDrawingOutsideViewBox: true,
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                            bottom: 15,
                            top: 20,
                          ),
                          child: CustomTextField(
                            icon: Icon(Icons.account_circle),
                            hint: "DISPLAY NAME",
                            validator: (input) =>
                                input.isEmpty ? "*Required" : null,
                            onSaved: (input) => _displayName = input,
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                            bottom: 20,
                          ),
                          child: CustomTextField(
                            icon: Icon(Icons.email),
                            hint: "EMAIL",
                            onSaved: (input) {
                              _email = input;
                            },
                            validator: emailValidator,
                          )),
                      Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: CustomTextField(
                            icon: Icon(Icons.lock),
                            obsecure: true,
                            onSaved: (input) => _password = input,
                            validator: (input) =>
                                input.isEmpty ? "*Required" : null,
                            hint: "PASSWORD",
                          )),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: _loading
                            ? CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    primaryColor),
                              )
                            : Container(
                                child: filledButton(
                                    "REGISTER",
                                    Colors.white,
                                    primaryColor,
                                    primaryColor,
                                    Colors.white,
                                    _validateRegisterInput),
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                              ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ]),
                    key: _formKey,
                    // ignore: deprecated_member_use
                    autovalidate: _autoValidate,
                  )),
                ],
              ),
              height: MediaQuery.of(context).size.height / 1.1,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
            ),
          ),
        );
      });
    }

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        key: _scaffoldKey,
        backgroundColor: Colors.blueAccent,
        body: Column(
          children: <Widget>[
            logo(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Padding(
              child: Container(
                child: filledButton("LOGIN", primaryColor, Colors.white,
                    Colors.white, primaryColor, loginSheet),
                height: 50,
              ),
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.05,
                  left: 20,
                  right: 20),
            ),
            Padding(
              child: Container(
                child: outlineButton(registerSheet),
                height: 50,
              ),
              padding: EdgeInsets.only(top: 10, left: 20, right: 20),
            ),
            Expanded(
              child: Align(
                child: ClipPath(
                  child: Container(
                    color: Colors.white,
                    height: 300,
                  ),
                  clipper: BottomWaveClipper(),
                ),
                alignment: Alignment.bottomCenter,
              ),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ));
  }
}
