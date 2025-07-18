import "package:flutter/material.dart";
import "package:map_mates/pages/login_page.dart";

class LoginButton extends StatelessWidget {
  final bool permissionGranted;
  const LoginButton({super.key, required this.permissionGranted});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (permissionGranted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Standortberechtigung ist erforderlich, um fortzufahren.',
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(25),
        child: const Center(
          child: Text("Login", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
