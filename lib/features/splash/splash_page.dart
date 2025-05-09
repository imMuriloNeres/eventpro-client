import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFF004AAD)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("event", style: 
              TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 40.0, 
                fontWeight: FontWeight.w300),
              ),
            const Text("PRO", style: 
              TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 40.0, 
                fontWeight: FontWeight.w700),
              ),
          ],
        ),
      ),
    );
  }
}