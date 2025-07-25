import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:map_mates/services/social_service.dart';

class AcceptFriendButton extends StatelessWidget {
  final int userId;
  final VoidCallback onAccepted;

  const AcceptFriendButton({
    super.key,
    required this.userId,
    required this.onAccepted,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final success = await SocialService(
          Client(),
        ).acceptFriendRequest(userId);
        if (success) {
          onAccepted(); // ruft setState im Parent auf
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        elevation: 2,
      ),
      child: const Icon(Icons.check),
    );
  }
}
