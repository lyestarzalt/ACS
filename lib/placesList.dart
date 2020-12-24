import 'package:flutter/material.dart';
import 'place.dart';
import 'package:google_fonts/google_fonts.dart';

class PlaceList extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<PlaceList> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.blue, Colors.white])),
          child: ListView.separated(
            itemCount: 2,
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(
                height: 30,
              );
            },
            itemBuilder: (context, index) {
              return TileItem(num: 1);
            },
          ),
        ),
      ),
    );
  }
}

class TileItem extends StatelessWidget {
  final int num;

  const TileItem({Key key, this.num}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 430,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Place(),
            fullscreenDialog: true,
          ),
        ),
        child: Card(
          margin: EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 10),
          elevation: 50,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(25.0),
            ),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            children: [
              Container(
                margin:
                    EdgeInsets.only(left: 10, top: 25, right: 10, bottom: 0),
                child: Text(
                  'Institute for Advanced and Smart Digital Opportunities.',
                  style: GoogleFonts.nunito(
                    textStyle: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        letterSpacing: .5,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin:
                      EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 0),
                  child: Text(
                    'UUM, Sintok, Kedah',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          letterSpacing: .5,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 5, top: 10, right: 10, bottom: 0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 5, 5, 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.asset(
                            'images/1.png',
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 5, 5, 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: Image.asset(
                                  'images/2.png',
                                  width: 120.0,
                                  height: 95.0,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 5, 5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: Image.asset(
                                  'images/3.png',
                                  width: 120.0,
                                  height: 95.0,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 5, top: 0, right: 10, bottom: 0),
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
                              child: Icon(Icons.emoji_food_beverage_rounded),
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
        ),
      ),
    );
  }
}

class PageItem extends StatelessWidget {
  final int num;

  const PageItem({Key key, this.num}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppBar appBar = new AppBar();
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return Stack(children: <Widget>[
      Column(
        children: <Widget>[
          Container(
            height: mediaQuery.padding.top,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: appBar.preferredSize.height),
            child: appBar,
          )
        ],
      ),
    ]);
  }
}
