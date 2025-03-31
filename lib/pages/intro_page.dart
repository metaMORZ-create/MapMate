import "package:map_mates/pages/home_page.dart";
import "package:flutter/material.dart";

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

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
              const SizedBox(height: 75),

              // title
              Text(
                "Just Do It",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),

              const SizedBox(height: 24),
              // sub title
              Text(
                "Brand new Sneakers and custom Kicks made with premium Quality",
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              //start now button
              GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(25),
                  child: Center(
                    child: Text(
                      "Shop Now",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
