import 'package:flutter/material.dart';
import 'package:thread_clone_flutter/screens/favorite_screen.dart';
import 'package:thread_clone_flutter/screens/feed.dart';
import 'package:thread_clone_flutter/screens/post_screen.dart';
import 'package:thread_clone_flutter/screens/profile_screen.dart';

import 'search.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;

  List<Widget> pages = [
    const FeedScreen(),
    const SearchScreen(),
    const PostScreen(),
    const FavoriteScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'search'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'post'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'profile'),
        ],
      ),
    );
  }
}
