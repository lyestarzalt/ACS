import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login-register.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

final FirebaseAuth auth = FirebaseAuth.instance;

///
class MapScreenState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  //variables
  File _image;
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  final firestoreInstance = Firestore.instance;
  bool loading = false;

  final nameController = new TextEditingController();
  final mobileController = new TextEditingController();
  //
  String url3;
  @override
  void initState() {
    _getUserInfo();

    super.initState();
    // initUser();
  }

//Get Image here from the device/////////////////////////////////////////////////
  Future getImage() async {
    final FirebaseUser user = await auth.currentUser();

    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      print("amos");
    } else {
      setState(() {
        _image = image;
        print('Image Path $_image');
      });

      String fileName = basename(_image.path);

      StorageReference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('uploads/${user?.uid}/$fileName');
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      taskSnapshot.ref.getDownloadURL();
//
      final url = await (await uploadTask.onComplete).ref.getDownloadURL();

      Firestore.instance
          .collection('users')
          .document(user.uid)
          .updateData({'PhotoUrl': url}).then((_) {
        setState(() {
          url2 = url;
        });
      });
      /* UserUpdateInfo updateUser = UserUpdateInfo();
    updateUser.photoUrl = url; */
      print('this is the url $url');
    }
  }

//

//uplaod//////////////////////////////////////////////////////////////////////////
/*   Future<String> uploadImageToFirebase(BuildContext context) async {
    final FirebaseUser user = await auth.currentUser();

    String fileName = basename(_image.path);
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('uploads/${user?.uid}/$fileName');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    taskSnapshot.ref.getDownloadURL();
    print('');
//
///////////////////////update url to users
    /* final url = await (await uploadTask.onComplete).ref.getDownloadURL();
    Firestore.instance
        .collection('users')
        .document(uid)
        .updateData({'ProfilePicture': url}); */

//

    final url = await (await uploadTask.onComplete).ref.getDownloadURL();
    UserUpdateInfo updateUser = UserUpdateInfo();
    updateUser.photoUrl = url;
    print('this is the url $url');
    print('this is the profilurl  ${user.photoUrl}');
  }
 */
////////////////////////////////////////
  bool isFieldshown = false;
  String url2;
  String _username;
  String _userphone;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<void> _getUserInfo() async {
    final FirebaseUser user = await auth.currentUser();

    DocumentSnapshot document =
        await Firestore.instance.collection('users').document(user.uid).get();

    if (mounted) {
      setState(() {
        url2 = document.data['PhotoUrl'];
        _username = document.data['displayName'];

        _userphone = document.data['Phone'];
      });
    }
  }

/////////////////////////////////////////
  Future<void> _updatedata() async {
    final FirebaseUser user = await auth.currentUser();

    mobileController.text.toString();
    nameController.text.toString();
    Firestore.instance.collection('users').document(user.uid).updateData(
        {'Phone': mobileController.text, 'displayName': nameController.text});
  }

/////////////////////
  ///
  showfield() {
    setState(() {
      isFieldshown = true;
    });
  }

  hidefield() {
    setState(() {
      isFieldshown = false;
    });
  }

  _signOut() async {
    await firebaseAuth.signOut().whenComplete(() => null);

    /*  .then((_) {
      Navigator.push(
        this.context,
        MaterialPageRoute(
          builder: (context) => LoginRegister(),
          fullscreenDialog: true,
        ),
      );
    });  */
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Colors.white60,
      child: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                height: 250.0,
                child: new Column(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(left: 10.0, top: 10.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            (_username == null)
                                ? Text(
                                    'Hello',
                                    style: GoogleFonts.nunito(
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Hello $_username',
                                    style: GoogleFonts.nunito(
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ],
                        )),
                    Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: Container(
                        child:
                            new Stack(fit: StackFit.loose, children: <Widget>[
                          new Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: new CircleAvatar(
                                  radius: 80.0,
                                  backgroundColor: Colors.blue,
                                  backgroundImage: (url2 == null)
                                      ? AssetImage('images/avatar.png')
                                      : NetworkImage('$url2'),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                              padding:
                                  EdgeInsets.only(top: 110.0, right: 140.0),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  new CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 25.0,
                                    child: new IconButton(
                                      icon: Icon(Icons.camera_alt_rounded),
                                      onPressed: getImage,
                                    ),
                                  )
                                ],
                              )),
                        ]),
                      ),
                    )
                  ],
                ),
              ),
              Material(
                elevation: 20,
                child: new Container(
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                          offset: Offset(
                              2.0, 2.0), // shadow direction: bottom right
                        )
                      ],
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(40.0),
                        topRight: const Radius.circular(40.0),
                      ),
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.blue[400], Colors.white])),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 25.0),
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 25.0),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    new Text(
                                      'Parsonal Informations:',
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    _status ? _getEditIcon() : new Container(),
                                  ],
                                )
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 25.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    (_username == null)
                                        ? Text(
                                            'Name:',
                                            style: GoogleFonts.nunito(
                                              textStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.black,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            'Name $_username',
                                            style: GoogleFonts.nunito(
                                              textStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 2.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Flexible(
                                  child: Visibility(
                                    visible: isFieldshown,
                                    child: new TextField(
                                      controller: nameController,
                                      decoration: const InputDecoration(
                                        hintText: "Enter Your Name",
                                      ),
                                      enabled: !_status,
                                      autofocus: !_status,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 25.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    /*  new Text(
                                              'Email ID',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ), */
                                  ],
                                ),
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 2.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                /* new Flexible(
                                          child: new TextField(
                                            decoration: const InputDecoration(
                                                hintText: "Enter Email ID"),
                                            enabled: !_status,
                                          ),
                                        ), */
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 25.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    (_userphone == null)
                                        ? Text(
                                            'Phone number:',
                                            style: GoogleFonts.nunito(
                                              textStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.black,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            'Phone number: $_userphone',
                                            style: GoogleFonts.nunito(
                                              textStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 2.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Flexible(
                                  child: Visibility(
                                    visible: isFieldshown,
                                    child: new TextField(
                                      controller: mobileController,
                                      decoration: const InputDecoration(
                                          hintText: "Enter Mobile Number"),
                                      enabled: !_status,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 25.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                            )),
                        !_status ? _getActionButtons() : new Container(),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Your Qr code ',
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 2.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  elevation: 50,
                                  child: QrImage(
                                      data: "${user?.uid}",
                                      version: QrVersions.auto,
                                      size: 158.0,
                                      gapless: false,
                                      embeddedImage: AssetImage(
                                        'assets/logo.png',
                                      )),
                                ),
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 2.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                RaisedButton.icon(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  icon: Icon(Icons.logout),
                                  onPressed: () => showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        20.0)),
                                            title: Text('Sure about that?'),
                                            content: Text(''),
                                            actions: [
                                              FlatButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Cancel')),
                                              FlatButton(
                                                  onPressed: () {
                                                    _signOut();
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Confirm')),
                                            ],
                                            elevation: 24.5,
                                          )),
                                  color: Colors.red[200],
                                  label: const Text('Log Out'),
                                ),
                                Spacer(),
                                RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  color: Colors.blue[200],
                                  child: Text('About'),
                                  onPressed: () {
                                    showAboutDialog(
                                      context: context,
                                      children: [
                                        Text(
                                            'Hey There!\nThank for using UNA, if you facing any issues please email us.')
                                      ],
                                      applicationName: 'UNA',
                                      applicationVersion: '0.5.1',
                                      applicationIcon: Image.asset(
                                        'assets/logo.png',
                                        width: 30,
                                        height: 30,
                                      ),
                                    );
                                  },
                                )
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Save"),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: () {
                  _updatedata().then((_) {
                    setState(() {
                      _status = true;
                      _getUserInfo();
                      isFieldshown = false;
                    });
                  });
                },

                //uploadImageToFirebase(this.context),

                //() {
                // setState(() {
                //  _status = true;
                //   FocusScope.of(context).requestFocus(new FocusNode());
                //  });
                // },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Cancel"),
                textColor: Colors.white,
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    _status = true;
                    isFieldshown = false;
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.red,
        radius: 14.0,
        child: new Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
          semanticLabel: 'Edit',
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
          isFieldshown = true;
        });
      },
    );
  }

  Widget _disposeEditIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.red,
        radius: 14.0,
        child: new Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = true;
          isFieldshown = false;
        });
      },
    );
  }
}
