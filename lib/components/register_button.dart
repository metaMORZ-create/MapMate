import "package:flutter/material.dart";
import "package:map_mates/pages/home_page.dart";

class RegisterButton extends StatelessWidget {
  final bool permissionGranted;
  const RegisterButton({super.key, required this.permissionGranted});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (permissionGranted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
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
          child: Text("Register", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
