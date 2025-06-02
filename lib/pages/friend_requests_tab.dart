import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:map_mates/components/incoming_requests.dart';
import 'package:map_mates/components/outgoing_requests.dart';
import 'package:map_mates/services/social_service.dart';

class FriendRequestsTab extends StatefulWidget {
  const FriendRequestsTab({super.key});

  @override
  State<FriendRequestsTab> createState() => _FriendRequestsTabState();
}

class _FriendRequestsTabState extends State<FriendRequestsTab> {
  List outgoingList = [];
  List incomingList = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final outgoing = await SocialService(Client()).getOutgoingRequests();
    final incoming = await SocialService(Client()).getIncomingRequests();
    if (!mounted) return; 
    setState(() {
      outgoingList = outgoing;
      incomingList = incoming;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Incoming Requests",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          IncomingRequests(
            requests: incomingList.cast<Map<String, dynamic>>(),
            onHandled: (index) {
              if (!mounted) return; 
              setState(() {
                incomingList.removeAt(index);
              });
            },
          ),
          const SizedBox(height: 24),
          const Text(
            "Outgoing Requests",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          OutgoingRequests(
            requests: outgoingList.cast<Map<String, dynamic>>(),
            onCancelled: (index) {
              if (!mounted) return; 
              setState(() {
                outgoingList.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }
}
