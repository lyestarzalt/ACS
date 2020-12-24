import 'package:flutter/material.dart';
import 'profile.dart';
import 'scanner.dart';
import 'place.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'placesList.dart';
import 'page.dart';

class MainScreen extends StatefulWidget {
  //const MainScreen({Key key, this.user}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Widget> tabs;
  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    tabs = [
      PlaceList(),
      Scanner(),
      ProfilePage(),
    ];
  }

  onTapped(int index) {
    setState(() {
      currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      /*  decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.blue[400], Colors.white])), */
      color: Colors.blue,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,

        body: tabs[currentTabIndex],
//I used the Convex packge for the bttom bar.

        bottomNavigationBar: ConvexAppBar(
          onTap: onTapped,
          backgroundColor: Colors.blue,
          activeColor: Colors.blue[50],
          elevation: 15,
          style: TabStyle.titled,
          height: 45,
          //Each item represnets a tab
          items: [
            TabItem(
              icon: Icon(Icons.meeting_room),
              title: "Places",
            ),
            TabItem(
              icon: Icon(
                Icons.library_books_rounded,
              ),
              title: "My Booking",
            ),
            TabItem(
              icon: Icon(
                Icons.person,
              ),
              title: "Profile",
            )
          ],
        ),
      ),
    );
  }
}
