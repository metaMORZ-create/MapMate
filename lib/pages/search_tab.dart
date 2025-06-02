import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:map_mates/components/accept_friend_request_button.dart';
import 'package:map_mates/components/deny_friend_request_button.dart';
import 'package:map_mates/services/social_service.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  List resultsList = [];
  List userList = [];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextField(
              onChanged: (search) async {
                resultsList = await SocialService(Client()).search(search);
                if (!mounted) return;
                setState(() {
                  userList = resultsList;
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search...",
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: userList.length,
                itemBuilder: (context, index) {
                  final eintrag = userList[index]["username"];
                  final user = userList[index];
                  Widget trailingIcon;

                  if (user["already_friends"] == true) {
                    trailingIcon = Icon(Icons.check, color: Colors.green);
                  } else if (user["request_sent"] == true) {
                    trailingIcon = Icon(
                      Icons.hourglass_bottom,
                      color: Colors.orange,
                    );
                  } else if (user["request_received"] == true) {
                    trailingIcon = SizedBox(
                      width: 140,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AcceptFriendButton(
                            userId: user["id"],
                            onAccepted: () {
                              if (!mounted) return;
                              setState(() {
                                user["already_friends"] = true;
                                user["request_received"] = false;
                              });
                            },
                          ),
                          DenyFriendButton(
                            userId: user["id"],
                            onAccepted: () {
                              if (!mounted) return;
                              setState(() {
                                user["request_received"] = false;
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    trailingIcon = GestureDetector(
                      onTap: () async {
                        final success = await SocialService(Client()).sendFriendRequest(
                          user["id"],
                        );
                        if (success) {
                          if (!mounted) return;
                          setState(() {
                            user["request_sent"] = true;
                          });
                        }
                      },
                      child: Icon(Icons.person_add, color: Colors.blue),
                    );
                  }

                  return ListTile(title: Text(eintrag), trailing: trailingIcon);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
