import 'package:flutter/material.dart';
import 'package:map_mates/components/deny_friend_request_button.dart';

class OutgoingRequests extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  final Function(int index) onCancelled;

  const OutgoingRequests({
    super.key,
    required this.requests,
    required this.onCancelled,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true, // ← macht den ListView anpassbar in Column
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final user = requests[index];
        final username = user["receiver_username"];

        return ListTile(
          title: Text(username),
          trailing: DenyFriendButton(
            userId: user["receiver_id"],
            onAccepted: () => onCancelled(index),
          ),
        );
      },
    );
  }
}
