import 'package:flutter/material.dart';

InputDecoration inputStyle(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[600]),
    filled: true,
    fillColor: Colors.grey[200],
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    ),
  );
}

Widget buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8, left: 5),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
    ),
  );
}