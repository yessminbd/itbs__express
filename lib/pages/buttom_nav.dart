import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:itbs__express/pages/home.dart';
import 'package:itbs__express/pages/profile.dart';

class ButtomNav extends StatefulWidget {
  const ButtomNav({super.key});

  @override
  State<ButtomNav> createState() => _ButtomNavState();
}

class _ButtomNavState extends State<ButtomNav> {
  int currentTabIndex = 0;
  late List<Widget> pages;
  late Widget currentPage;
  late Home homePage;
  late Profile profile;
  @override
  void initState() {
    homePage = Home();
    profile = Profile();
    pages = [homePage, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
          height: 65,
          backgroundColor: Colors.white,
          color: Colors.white,
          animationDuration: Duration(milliseconds: 500),
          onTap: (int index) {
            setState(() {
              currentTabIndex = index;
            });
          },
          items: [
            Icon(
              Icons.home_outlined,
              color: Colors.red,
            ),
            Icon(
              Icons.wallet,
              color: Colors.red,
            ),
          ]),
      body: pages[currentTabIndex],
    );
  }
}
