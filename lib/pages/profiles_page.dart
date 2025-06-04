import 'package:flutter/material.dart';
import 'package:map_mates/pages/friend_requests_tab.dart';
import 'package:map_mates/pages/friends_tab.dart';
import 'package:map_mates/pages/search_tab.dart';

class ProfilesPage extends StatelessWidget {
  const ProfilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Anzahl Tabs
      child: Scaffold(
        key: Key("profiles_tabview"),
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.grey[300],
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: "Friends"),
              Tab(text: "Search"),
              Tab(text: "Friend Requests"),
            ],
          ),
          title: const Text(
            "Your Friends",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: const TabBarView(
          children: [FriendsTab(), SearchTab(), FriendRequestsTab()],
        ),
      ),
    );
  }
}
