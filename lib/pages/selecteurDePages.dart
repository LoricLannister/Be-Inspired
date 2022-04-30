import 'package:be_inspired/pages/addNewPost.dart';
import 'package:be_inspired/pages/chat.dart';
import 'package:be_inspired/pages/listOfUsers.dart';
import 'package:be_inspired/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:be_inspired/pages/accueil.dart';

class SelecteurDePage extends StatefulWidget {
  final int index;
  const SelecteurDePage({Key? key, required this.index}) : super(key: key);

  @override
  _SelecteurDePageState createState() => _SelecteurDePageState();
}

class _SelecteurDePageState extends State<SelecteurDePage> {
  _SelecteurDePageState();
  int _selectedPageIndex = 2;

  void _onItemTaped(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: <Widget>[
          ListOfUsers(),
          AddNewPost(),
          Accueil(),
          Chat(),
          Settings(),
        ].elementAt(_selectedPageIndex),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.person_search, size: 28), label: "Members"),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline, size: 28), label: "Post"),
            BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 28), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.message, size: 28), label: "Messages"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings, size: 28), label: "Settings"),
          ],
          currentIndex: _selectedPageIndex,
          unselectedItemColor: Colors.grey.shade600,
          selectedItemColor: Colors.purple,
          showUnselectedLabels: true,
          backgroundColor: Colors.blue.shade100,
          onTap: _onItemTaped,
        ));
  }
}
