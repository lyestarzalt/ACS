import 'dart:async';
//import 'dart:html';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class Scanner extends StatefulWidget {
  @override
  _ScannerState createState() => _ScannerState();
}

final FirebaseAuth auth = FirebaseAuth.instance;

class _ScannerState extends State<Scanner> {
  @override
  void initState() {
    countDocuments();
    getList();
    super.initState();
    test();
  }

  var bookings = List();
  var days;
  var numberofbookings = 0;
  String barcode = '';
  Uint8List bytes = Uint8List(200);
  var userID;
  List<DocumentSnapshot> myDocCount;
  var anis;

  String date;

  test() {
    var date = DateTime.parse('${DateTime.now()}');
    var formattedDate = "${date.day}-${date.month}-${date.year}";
    var chosenday = formattedDate.toString();
    print(chosenday);
  }

  String checkin = 'Welcome aboard';
  String checkout = 'Hope to see you again';

  //!////////////////////////////////
  Future _scan() async {
    final FirebaseUser user = await auth.currentUser();
    userID = user.uid;
    String barcode = await scanner.scan();

    setState(() => this.barcode = barcode);

    var date = DateTime.parse('${DateTime.now()}');
    var formattedDate = "${date.day}-${date.month}-${date.year}";
    var chosenday = formattedDate.toString();
    print(
        'today issssssssssssssssssssssssssssssssssssssssssssss $formattedDate');

    final db = Firestore.instance;
    DocumentSnapshot document = await db
        .collection('users')
        .document(userID)
        .collection('Bookings')
        .document(chosenday)
        .get();
    print('yo this is the empty ${document.data}');

    if (barcode == checkout && document.data != null) {
      final db = Firestore.instance;
      DocumentSnapshot document = await db
          .collection('users')
          .document(userID)
          .collection('Bookings')
          .document(chosenday)
          .get();
      Map<String, dynamic> documentData =
          document.data; //if it is a single document
      print('this is the documet $documentData');
      Firestore.instance
          .collection('bookings')
          .document(chosenday)
          .updateData(documentData)
          .then((_) {
        Firestore.instance
            .collection('users')
            .document(userID)
            .collection('Bookings')
            .document(chosenday)
            .delete();

        //users.clear();

        print("success!");
      }).then((_) async {
        await Firestore.instance
            .collection("Check-Out")
            .document(chosenday)
            .setData({
          'Space': {user.email: FieldValue.serverTimestamp()},
        }, merge: true).then((_) {
          print("success!");
        });
      }).then((_) {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text('Hope to see you again!')));
      });
    } else if (barcode == checkin && document.data != null) {
      await Firestore.instance
          .collection("Check-In")
          .document(chosenday)
          .setData({
        'Space': {user.email: FieldValue.serverTimestamp()},
      }, merge: true).then((_) {
        print("success!");
      }).then((_) {
        Scaffold.of(context)
            .showSnackBar(new SnackBar(content: new Text('welcome aboard!')));
      });
    } else {
      Scaffold.of(context)
          .showSnackBar(new SnackBar(content: new Text('Error')));
    }
  }

//!////////////////////
  void countDocuments() async {
    final FirebaseUser user = await auth.currentUser();
    userID = user.uid;
    QuerySnapshot _myDoc = await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('Bookings')
        .getDocuments()
        .then((event) {
      if (event.documents.isNotEmpty) {
        myDocCount = event.documents; // Count of Documents in Collection
        // print('hey this is the first $myDocCount');
        event.documents.forEach((doc) {
          //  print('this is dates you booked ${doc.documentID}');
          doc.documentID;
        });

        setState(() {
          numberofbookings = myDocCount.length;
          bookings = myDocCount;
        });
      } else {}
    }).catchError(
      (e) => print("error fetching data: $e"),
    );
  }

  getListViewItems(String item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
          title: new Text('Cancel Bookings for $item?'),
          content: Image.asset(
            "images/giphy.gif",
            height: 125.0,
            width: 125.0,
          ),
          actions: <Widget>[
            FlatButton(
              child: new Text("Confirme"),
              onPressed: () async {
                final db = Firestore.instance;
                DocumentSnapshot document = await db
                    .collection('users')
                    .document(userID)
                    .collection('Bookings')
                    .document(item)
                    .get();
                Map<String, dynamic> documentData =
                    document.data; //if it is a single document
                print('this is the documet $documentData');
                Firestore.instance
                    .collection('bookings')
                    .document(item)
                    .updateData(documentData)
                    .then((_) {
                  Firestore.instance
                      .collection('users')
                      .document(userID)
                      .collection('Bookings')
                      .document(item)
                      .delete();

                  //users.clear();

                  print("success!");
                });
/* 
                     .setData({
        documentData
      }, merge: true); */

                //////////////////////////////////!
                print(documentData);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future deleteBooking() async {
    final FirebaseUser user = await auth.currentUser();

    final bookings = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('Bookings')
        .document();
  }

  Future getList() async {
    final FirebaseUser user = await auth.currentUser();

    final bookings = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('Bookings');

    bookings.getDocuments().then((snapshot) {
      snapshot.documents.forEach((doc) {
        anis = doc.documentID;
      });
    });
  }

  Widget _buildList(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      title: Text(document['title']),
      subtitle: Text(document['body']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          tooltip: 'Scan Qr',
          onPressed: _scan,
          child: Icon(Icons.qr_code_scanner_rounded,
              color: Colors.white, size: 40.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.blue, Colors.white])),
          child: StreamBuilder(
            stream: Firestore.instance
                .collection("users")
                .document('$userID')
                .collection('Bookings')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                QuerySnapshot snap = snapshot.data;
                List<DocumentSnapshot> documents = snap.documents;

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot doc = documents[index];

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                      child: Slidable(
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        child: Container(
                          color: Colors.white,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Text(
                                "📆",
                                style: GoogleFonts.nunito(
                                    textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                )),
                              ),
                              foregroundColor: Colors.white,
                            ),
                            title: Text('${doc.documentID}'),
                            subtitle: Text('hint: Swipe right to cancel'),
                          ),
                        ),
                        actions: <Widget>[
                          IconSlideAction(
                            caption: 'Cancel',
                            color: Colors.red,
                            icon: Icons.delete_forever,
                            onTap: () => {getListViewItems(doc.documentID)},
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else if (snapshot.data == null ||
                  snapshot.data.documents.length == 0) {
                print('amos');
                return Center(child: Text('No Bookings yet¯\_(ツ)_/¯'));
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ));
  }
}

//() =>{getListViewItems(doc.documentID)},
