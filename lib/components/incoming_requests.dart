import 'package:flutter/material.dart';
import 'package:map_mates/components/accept_friend_request_button.dart';
import 'package:map_mates/components/deny_friend_request_button.dart';

class IncomingRequests extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  final Function(int index) onHandled;

  const IncomingRequests({
    super.key,
    required this.requests,
    required this.onHandled,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true, // ← wichtig!
      physics:
          const NeverScrollableScrollPhysics(), // ← verhindert doppeltes Scrollen
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final user = requests[index];
        final username = user["sender_username"];

        return ListTile(
          title: Text(username),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AcceptFriendButton(
                userId: user["sender_id"],
                onAccepted: () => onHandled(index),
              ),
              const SizedBox(width: 8),
              DenyFriendButton(
                userId: user["sender_id"],
                onAccepted: () => onHandled(index),
              ),
            ],
          ),
        );
      },
    );
  }
}
