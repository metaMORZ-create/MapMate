import "package:map_mates/components/login_button.dart";
import "package:map_mates/components/register_button.dart";
import "package:flutter/material.dart";

class IntroPage extends StatefulWidget {
  final bool permissionGranted;

  const IntroPage({super.key, required this.permissionGranted});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset("lib/images/logo.png"),
              const SizedBox(height: 10),
              // Sub Title
              const Text(
                "„Ich sehe die Welt in Grau - außer dort, wo ich war - dort ist sie bunt.“",
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Start now button
              RegisterButton(permissionGranted: widget.permissionGranted),
              const SizedBox(height: 20),
              LoginButton(
                key: const Key('login_button'),
                permissionGranted: widget.permissionGranted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
