import 'package:buddies_gram/screen/ProfileScreen.dart';
import 'package:buddies_gram/screen/favourite.dart';
import 'package:buddies_gram/screen/uploadscreen.dart';

import 'timeline.dart';
import 'package:flutter/material.dart';
import 'searchscreen.dart';
class TabbedScreen extends StatefulWidget {
  const TabbedScreen({Key? key}) : super(key: key);

  @override
  _TabbedScreenState createState() => _TabbedScreenState();
}

class _TabbedScreenState extends State<TabbedScreen> {
  List<Widget> tabs = [
    Timeline(),
    SearchScreen(),
    UploadScreen(),
    Favourite(),
    ProfileScreen()
  ];
  var index;
  @override
  void initState() {
    index = 0;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:tabs[index],
      bottomNavigationBar: BottomNavigationBar(iconSize: 30,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.black,
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        items: [
          BottomNavigationBarItem(label: ' ',icon:Icon(Icons.home_outlined)),
          BottomNavigationBarItem(label: ' ',icon: Icon(Icons.search)),
          BottomNavigationBarItem(label: ' ',icon: Icon(Icons.camera_alt,size: 50,)),
          BottomNavigationBarItem(label: ' ',icon: Icon(Icons.volunteer_activism)),
          BottomNavigationBarItem(label: ' ',icon: Icon(Icons.person))

        ],
      ),
    );
  }
}
