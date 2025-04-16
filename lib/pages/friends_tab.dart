import "package:flutter/material.dart";
import "package:map_mates/pages/area_map.dart";
import "package:map_mates/services/social_service.dart";

class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {

  late List friendsList = [];

   @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final friends = await SocialService.getFriends();
    if (!mounted) return; 
    setState(() {
      friendsList = friends;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: friendsList.length,
      itemBuilder: (context, index) {
        final friend = friendsList[index];
        return ListTile(
          leading: Icon(Icons.person),
          title: Text(friend["friend_username"]),
          subtitle: Text("ID: ${friend["friend_id"]}"),
          trailing: IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VisitedAreaPage(userId: friend["friend_id"], userName: friend["friend_username"],),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
