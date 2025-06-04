import "package:http/http.dart";
import "package:map_mates/pages/home_page.dart";
import "package:flutter/material.dart";
import "package:map_mates/services/login_register_service.dart";
import "package:shared_preferences/shared_preferences.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      bool success;
      if (const bool.fromEnvironment('TEST_MODE')) {
        // Simuliere erfolgreichen Login
        success = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("loggedIn", true);
        await prefs.setInt("user_id", 1);
      } else {
        // Echter Login
        success = await LoginRegisterService(
          Client(),
        ).login(username, password);
      }

      if (!mounted) return;
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login fehlgeschlagen")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset("lib/images/logo.png"),
              const SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: "Benutzername",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Bitte Benutzernamen eingeben";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: "Passwort"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Bitte Passwort eingeben";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _login,
                      child: const Text("Einloggen"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
