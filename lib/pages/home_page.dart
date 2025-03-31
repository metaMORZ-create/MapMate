import "package:map_mates/components/bottom_navigation_bar.dart";
import "package:map_mates/pages/map_page.dart";
import "package:map_mates/pages/settings_page.dart";
import "package:map_mates/pages/profiles_page.dart";
import "package:flutter/material.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // this selected index is to control the bottom nav bar
  int _selectedIndex = 0;

  // this method will update our selected index
  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // pages to display
  final List<Widget> _pages = [
    //shop page
    const ProfilesPage(),

    //map page
    const MapPage(),

    //cart page
    const SettingsPage(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // other pages
            Column(
              children: [
                // logo
                DrawerHeader(
                  child: Image.asset(
                    "lib/images/logo.png",
                    color: Colors.white,
                  ),
                ),
                
                const Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    leading: Icon(Icons.home, color: Colors.white),
                    title: Text("Home", style: TextStyle(color: Colors.white)),
                  ),
                ),

                const Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    leading: Icon(Icons.info, color: Colors.white),
                    title: Text("About", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),

            const Padding(
              padding: const EdgeInsets.only(left: 25),
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.white),
                title: Text("Logout", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
