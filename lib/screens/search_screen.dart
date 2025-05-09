import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EventPro"),
      ),
      body: SafeArea(child: Center(
        child: const Text("Search Screen"),
      )),
    );
  }
}