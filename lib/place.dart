import 'package:flutter/material.dart';
import 'placesList.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:grid_selector/base_grid_selector_item.dart';
import 'package:grid_selector/grid_selector.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flip_card/flip_card.dart';
import 'scanner.dart';

// ignore: unused_element
CameraPosition _initialPosition =
    CameraPosition(target: LatLng(6.467861, 100.507639));
Completer<GoogleMapController> _controller = Completer();
GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

// ignore: unused_element
void _onMapCreated(GoogleMapController controller) {
  _controller.complete(controller);
}

class Place extends StatefulWidget {
  @override
  _PlaceState createState() => _PlaceState();
}

class _PlaceState extends State<Place> {
  void initState() {
    _getUserInfo();
    getCurrentLocation();
    super.initState();
    allMarkers.add(Marker(
        markerId: MarkerId('IASDO'),
        draggable: false,
        onTap: () => null,
        position: LatLng(6.468013, 100.507168)));
  }

/* Init variables */
  int mesafa;
  final String assetName = 'assets/plan.svg';
  var seat1;
  var today = DateTime.now();
  var seat2;
  var seat3;
  var seat4;
  var seat5;
  var seat6;
  var image1 = Image.asset('images/1.png');
  var image2 = Image.asset('images/1.png');
  var image3 = Image.asset('images/1.png');
  bool isSeatEnabled = false;
  bool isBookEnabled = false;
  var bookedSeats = List();
  int distance;
  List<Marker> allMarkers = [];
  dynamic selectedCard;
  String url2;
  int freeSeats = 1;
  dynamic seatsleft = 0;
  bool showCircular = false;
  bool showPlace = false;
  bool showBook = false;
  bool showConfirme = false;
  var currentSelectedValue;
  bool showPlacesLeft = false;
  DateTime selectedDate = DateTime.now();
  final FirebaseAuth auth = FirebaseAuth.instance;
  dynamic chosenday = '';
  String username;
  List<dynamic> imagesList = [
    Image.asset('images/1.png'),
    Image.asset('images/2.png'),
    Image.asset('images/3.png'),
  ];

  var distance2;
  List<String> images = [
    'assets/iasdo3.jpeg',
    'assets/iasdo4.jpeg',
    'assets/iasdo5.jpeg',
  ];

  Map<String, dynamic> bookings = {
    'seat1': true,
    'seat2': true,
    'seat3': true,
    'seat4': true,
    'seat5': true,
    'seat6': true,
  };

  Map<String, dynamic> newbookings = {
    'seat1': true,
    'seat2': true,
    'seat3': true,
    'seat4': true,
    'seat5': true,
    'seat6': true,
  };

  Map<String, dynamic> users = {
    'seat1': '',
    'seat2': '',
    'seat3': '',
    'seat4': '',
    'seat5': '',
    'seat6': '',
  };
  Completer<GoogleMapController> _controller = Completer();

  static const LatLng _center = const LatLng(6.467861, 100.507639);

/* 
All the functions used in this page
*/
  enableBook() {
    setState(() {
      isBookEnabled = true;
    });
  }

  disableBook() {
    setState(() {
      isBookEnabled = false;
      showConfirme = false;
    });
  }

//get the location of the user
  void getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double startLatitude = position.latitude;
    double startLongitude = position.longitude;
    double distanceInMeters = Geolocator.distanceBetween(
        startLatitude, startLongitude, 6.467859, 100.507634);

    if (mounted) {
      setState(() {
        distance = distanceInMeters.round();
        distance2 = distance / 1000;
      });
    }
  }
//Google maps controller

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

// fetch user Profile Picture.
  Future<void> _getUserInfo() async {
    final FirebaseUser user = await auth.currentUser();

    DocumentSnapshot document =
        await Firestore.instance.collection('users').document(user.uid).get();

    if (mounted) {
      setState(() {
        if (document.data == null) {
          print('nothign here');
        } else
          url2 = document.data['PhotoUrl'];
        username = document.data['displayName'];
      });
    }
  }

//Display Bottom Sheet
  void displayBottomSheet(BuildContext context) async {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white,
        isScrollControlled: true,
        isDismissible: false,
        elevation: 200,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setState /*You can rename this!*/) {
            return Container(
              child: GridView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: 1,
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                    crossAxisCount: 1,
                    childAspectRatio: MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height / 2),
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: <Widget>[
                        GridSelector<int>(
                          title: '',
                          items: _getTails(),
                          itemTextSelectedColor: Colors.orange,
                          backgroundColor: Colors.green,
                          backgroundDisableColor: Colors.grey,
                          itemTextColor: Colors.white,
                          itemSize: 40,
                          onSelectionChanged: (option) {
                            setState(() {
                              // ontap of each card, set the defined int to the grid view index
                              selectedCard = option;
                              print(selectedCard);
                              showConfirme = true;
                            });
                          },
                        ),
                        // _buildDivider(),
                        Visibility(
                          visible: showPlacesLeft,
                          child: Text('There are $freeSeats free seats'),
                        ),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: InteractiveViewer(
                                boundaryMargin: EdgeInsets.all(100),
                                constrained: true,
                                child: SvgPicture.asset(
                                  assetName,
                                  width: 280,
                                  fit: BoxFit.contain,
                                  allowDrawingOutsideViewBox: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              child: RaisedButton(
                                onPressed: () {
                                  disableBook();
                                  setState(() {
                                    selectedCard = null;
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel'),
                                color: Colors.grey,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side:
                                        BorderSide(color: Colors.transparent)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              child: RaisedButton(
                                onPressed: showConfirme
                                    ? () {
                                        enableBook();
                                        Navigator.pop(context);
                                      }
                                    : null,
                                child: Text('Confime'),
                                disabledColor: Colors.green[100],
                                color: Colors.green[400],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side:
                                        BorderSide(color: Colors.transparent)),
                              ),
                            ),
                            _buildDivider(),
                          ],
                        ),
                      ],
                    );
                  }),
            );
          });
        });
  }

  void showBooking() {
    if (selectedCard != null) {
      setState(() {
        showBook = true;
      });
    } else {
      //TODO Forgot what to do here, but the app works fine so far..

    }
  }

// selection of a date
  Future _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2022),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      var date = DateTime.parse('$selectedDate');
      var formattedDate = "${date.day}-${date.month}-${date.year}";
      chosenday = formattedDate.toString();

      if (chosenday != null && picked != null) {
        showPlace = true;
      } else {
        showPlace = false;
      }

      ///Fetch the chosen date from the db, if there is no records, creat one.

      await Firestore.instance
          .collection('bookings')
          .where(FieldPath.documentId, isEqualTo: '$chosenday')
          .getDocuments()
          .then((event) {
        if (event.documents.isNotEmpty) {
          setState(() {
            bookings = event.documents.single.data; //if it is a single document

            seat1 = bookings['seat1'];
            seat2 = bookings['seat2'];
            seat3 = bookings['seat3'];
            seat4 = bookings['seat4'];
            seat5 = bookings['seat5'];
            seat6 = bookings['seat6'];
            var newfreeseats = bookings.values.toList();
            freeSeats = newfreeseats.where((e) => e == true).length;
          });
        } else {
          Firestore.instance
              .collection('bookings')
              .document('$chosenday')
              .setData(newbookings);
          setState(
            () {
              seat1 = newbookings['seat1'];
              seat2 = newbookings['seat2'];
              seat3 = newbookings['seat3'];
              seat4 = newbookings['seat4'];
              seat5 = newbookings['seat5'];
              seat6 = newbookings['seat6'];

              var newfreeseats = newbookings.values.toList();

              freeSeats = newfreeseats.where((e) => e == true).length;
            },
          );
        }
      }).catchError(
        (e) => print("error fetching data: $e"),
      );

//Convert the map into a list to count how many seats are left.
      var freeseats = bookings.values.toList();

// rebuild the UI framwork while counting how many empty slots there is
      setState(() {
        freeSeats = freeseats.where((e) => e == true).length;
        showPlacesLeft = true;
        isSeatEnabled = true;
      });
//debug logs..
    } else {
      setState(() {
        showPlacesLeft = false;

        isSeatEnabled = false;
      });
    }
  }

  Future book() async {
    final FirebaseUser user = await auth.currentUser();
    users['seat$selectedCard'] = user.email;

    bookedSeats.add(selectedCard);
    Firestore.instance
        .collection('bookings')
        .document('$chosenday')
        .updateData({
      'seat$selectedCard': false,
    }).then((_) {
      Firestore.instance
          .collection('users')
          .document(user.uid)
          .collection('Bookings')
          .document(chosenday)
          .setData({
        'seat$selectedCard': true,
      }, merge: true);
      //users.clear();
    }).then(
      (_) {
        Firestore.instance
            .collection('bookings')
            .where(FieldPath.documentId, isEqualTo: '$chosenday')
            .getDocuments()
            .then((event) {
          if (event.documents.isNotEmpty) {
            bookings = event.documents.single.data; //if it is a single document

            setState(() {
              seat1 = bookings['seat1'];
              seat2 = bookings['seat2'];
              seat3 = bookings['seat3'];
              seat4 = bookings['seat4'];
              seat5 = bookings['seat5'];
              seat6 = bookings['seat6'];
              setState(() {
                var freeseats = bookings.values.toList();
                freeSeats = freeseats.where((e) => e == true).length;
                isSeatEnabled = true;
              });
            });
          }
        }).catchError((e) => print("error fetching data: $e"));
      },
    );

    //.setData(booking);
  }

// the Grid for selecting places
  List<BaseGridSelectorItem> _getTails() {
    return [
      BaseGridSelectorItem(key: 1, label: "1", isEnabled: seat1 ?? false),
      BaseGridSelectorItem(key: 2, label: "2", isEnabled: seat2 ?? false),
      BaseGridSelectorItem(key: 3, label: "3", isEnabled: seat3 ?? false),
      BaseGridSelectorItem(key: 4, label: "4", isEnabled: seat4 ?? false),
      BaseGridSelectorItem(key: 5, label: "5", isEnabled: seat5 ?? false),
      BaseGridSelectorItem(key: 6, label: "6", isEnabled: seat6 ?? false),
    ];
  }

/* End of functions */

/* The UI starts here */
  Widget build(BuildContext context) {
    showCircular ? CircularProgressIndicator() : SizedBox();

    Widget titleSection = Container(
      padding: const EdgeInsets.all(0),
      child: Row(),
    );

    Widget textSection = Container(
      margin: EdgeInsets.only(left: 10, top: 25, right: 10, bottom: 25),
      height: 200,
      child: Stack(fit: StackFit.loose, children: [
        GoogleMap(
          padding: const EdgeInsets.all(50),
          mapType: MapType.hybrid,
          zoomControlsEnabled: false,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 17.0,
          ),
          markers: Set.from(allMarkers),
        ),
        Positioned(
          right: 5.0,
          top: 5.0,
          child: Container(
            height: 100,
            width: 150,
            child: Column(children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: (url2 == null)
                          ? AssetImage('images/avatar.png')
                          : NetworkImage('$url2'),
                    ),
                  ),
                  (username == null)
                      ? Text(
                          '',
                          style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: Colors.black,
                            ),
                          ),
                        )
                      : Expanded(
                          child: Text(
                            '$username',
                            style: GoogleFonts.nunito(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            softWrap: true,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 1),
                  child: RichText(
                      text: TextSpan(
                          style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          children: [
                        TextSpan(
                          text: '$distance2 Km',
                          style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: ' from your\n current location',
                          style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      ])),
                ),
              ),
            ]),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 2.0,
                  spreadRadius: 0.0,
                  offset: Offset(2.0, 2.0), // shadow direction: bottom right
                )
              ],
            ),
          ),
        ),
      ]),
      decoration: BoxDecoration(
        color: Colors.blue[200],
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          hintColor: Color(0xFFC0F0E8),
          primaryColor: Color(0xff476cfb),
          fontFamily: "Montserrat",
          canvasColor: Colors.transparent),
      home: Scaffold(
        backgroundColor: Colors.white,
        /*   appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: GestureDetector(
            onTap: () {/* Write listener code here */},
            child: IconTheme(
                data: IconThemeData(color: Colors.black),
                child: CloseButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceList(),
                      fullscreenDialog: true,
                    ),
                  ),
                )),
          ),
        ), */
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.blue[400], Colors.white])),
          child: ListView(
            children: [
              Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaceList(),
                          fullscreenDialog: true,
                        )),
                  )),
              SizedBox(
                height: 250,
                child: new Swiper(
                  itemBuilder: (BuildContext context, int index) {
                    return new Image.asset(
                      images[index],
                      fit: BoxFit.fill,
                    );
                  },
                  autoplay: true,
                  itemCount: images.length,
                  viewportFraction: 0.8,
                  scale: 1,
                  layout: SwiperLayout.TINDER,
                  itemHeight: 500,
                  itemWidth: 500,
                  outer: true,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /*2*/
                  Container(
                    margin: EdgeInsets.only(
                        left: 10, top: 25, right: 10, bottom: 0),
                    child: Text(
                      'Institute for Advanced and Smart Digital Opportunities (IASDO)',
                      style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            letterSpacing: .5,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'UUM, Kedah',
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          color: Colors.grey,
                          letterSpacing: .5,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Card(
                          color: Colors.blue[200],
                          margin: EdgeInsets.only(
                              left: 10, top: 25, right: 10, bottom: 0),
                          elevation: 0,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(15.0)),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.blue,
                                  child: Icon(
                                    Icons.wifi_rounded,
                                  ),
                                ),
                              ),
                              Text(
                                '\tHigh-Speed Wifi ',
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.blue[900],
                                    letterSpacing: .4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          color: Colors.indigo[200],
                          margin: EdgeInsets.only(
                              left: 10, top: 25, right: 10, bottom: 0),
                          elevation: 0,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(17.0)),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.indigo,
                                  child: Icon(
                                    Icons.ac_unit_rounded,
                                  ),
                                ),
                              ),
                              Text(
                                '\t AC    ',
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.indigo[900],
                                    letterSpacing: .4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          color: Colors.orange[200],
                          margin: EdgeInsets.only(
                              left: 10, top: 25, right: 10, bottom: 0),
                          elevation: 0,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(17.0)),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.orange,
                                  child: Icon(
                                    Icons.date_range_rounded,
                                  ),
                                ),
                              ),
                              Text(
                                '\t Flexible Dates ',
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.orange[900],
                                    letterSpacing: .4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          color: Colors.blueGrey[200],
                          margin: EdgeInsets.only(
                              left: 10, top: 25, right: 10, bottom: 0),
                          elevation: 0,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(17.0)),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.blueGrey,
                                  child:
                                      Icon(Icons.emoji_food_beverage_rounded),
                                ),
                              ),
                              Text(
                                '\tWe have Tea! ',
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.blueGrey[900],
                                    letterSpacing: .4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Card(
                color: Colors.transparent,
                elevation: 0,
                margin:
                    EdgeInsets.only(left: 10, top: 25, right: 10, bottom: 0),
                child: FlipCard(
                  key: cardKey,
                  front: Container(
                    color: Colors.transparent,
                    height: 220,
                    child: Column(children: [
                      Text(
                        '\n'
                        'Welcome to the Institute for Advanced and Smart Digital Opportunities (IASDO). '
                        ' We are involved in research, publications, consultations and training towards '
                        'smart society transformation. We aim to be a distinguished referral centre for '
                        'consultative activities in advanced and smart digital opportunities, ',
                        softWrap: true,
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            letterSpacing: .4,
                          ),
                        ),
                      ),
                      RaisedButton(
                        elevation: 24,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        onPressed: () => cardKey.currentState.toggleCard(),
                        child: Text(
                          'SELECT YOUR PLAN',
                          style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black,
                              letterSpacing: .4,
                            ),
                          ),
                        ),
                        color: Colors.blue[200],
                      )
                    ]),
                  ),
                  back: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                        /* decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent)), */
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              constraints:
                                  BoxConstraints(minWidth: 50, maxWidth: 200),
                              padding: const EdgeInsets.all(0),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                child: RaisedButton.icon(
                                    elevation: 25.0,
                                    icon: Icon(Icons.calendar_today),
                                    onPressed: () {
                                      _selectDate(context);
                                      print('this is the day$chosenday');
                                    },
                                    label: Text("1"),
                                    color: Color(0xffff2e63E),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(10.0),
                                        side:
                                            BorderSide(color: Colors.white10))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                (() {
                                  if (chosenday == '') {
                                    return "Choose your day📅";
                                  } else {
                                    return "$chosenday";
                                  }
                                })(),
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      letterSpacing: .5,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                        /*   decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent)), */
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                child: Visibility(
                                  visible: true,
                                  child: RaisedButton.icon(
                                      elevation: 25.0,
                                      icon: Icon(Icons.event_seat),
                                      onPressed: isSeatEnabled
                                          ? () => {displayBottomSheet(context)}
                                          : null,
                                      label: Text("2"),
                                      color: Color(0xffff2e63E),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(10.0),
                                          side: BorderSide(
                                              color: Colors.white10))),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                (() {
                                  if (selectedCard == null) {
                                    return "Choose your seat🪑";
                                  } else {
                                    return "Seat $selectedCard";
                                  }
                                })(),
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      letterSpacing: .5,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                        /*  decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent)), */
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                child: Visibility(
                                  visible: true,
                                  child: RaisedButton.icon(
                                      elevation: 25.0,
                                      icon: Icon(Icons.done),
                                      onPressed: isBookEnabled
                                          ? () => showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                    .circular(
                                                                20.0)),
                                                    title: Text(
                                                        'Sure about that?'),
                                                    content: Text(
                                                        'Book for $chosenday'),
                                                    actions: [
                                                      FlatButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child:
                                                              Text('Cancel')),
                                                      FlatButton(
                                                          onPressed: () {
                                                            book().then((_) {
                                                              Navigator.of(
                                                                      context,
                                                                      rootNavigator:
                                                                          true)
                                                                  .pop();
                                                            }).then((_) {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          Scanner(),
                                                                  fullscreenDialog:
                                                                      false,
                                                                ),
                                                              );
                                                            });

                                                            SnackBar(
                                                                content: Text(
                                                                    'Booked!'));
                                                          },
                                                          child:
                                                              Text('Confirm')),
                                                    ],
                                                    elevation: 24.5,
                                                  ))
                                          : null,
                                      label: Text("3"),
                                      color: Color(0xffff2e63E),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(10.0),
                                          side: BorderSide(
                                              color: Colors.white10))),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                (() {
                                  if (isBookEnabled == false) {
                                    return "Book!";
                                  } else {
                                    return "Almost there";
                                  }
                                })(),
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      letterSpacing: .5,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [],
              ),
              titleSection,
              textSection,
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 32.0,
      ),
      child: Divider(
        height: 4,
        color: Colors.red,
      ),
    );
  }
}

@override
Widget build(BuildContext context) {
  return MaterialApp();
}
