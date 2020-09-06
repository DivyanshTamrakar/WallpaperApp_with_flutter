import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';
import 'package:wallyapp/bottom_navigation_pages/account.dart';
import 'package:wallyapp/bottom_navigation_pages/explore.dart';
import 'package:wallyapp/bottom_navigation_pages/favourite.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _selectedPageIndex = 0;

  var page = [
    ExploreScreen(),
    FavoriteScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: page[_selectedPageIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedPageIndex,
          onTap: (int value){
            setState(() {
              _selectedPageIndex = value;

            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              title: Text("Explore")
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                title: Text("Favorite")
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                title: Text("Account")
            )

          ],

            )
    );
  }
}
