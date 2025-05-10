import 'package:flutter/material.dart';

// função que retorna um botão personalizado
Widget customButton({
  required double width,
  required double height,
  required String text,
  required Color color,
  required IconData icon,
  required VoidCallback onPressed,
  required TextStyle textStyle,
  Color iconColor = Colors.white,
  double borderRadius = 8.0, // novo parâmetro
}) {
  return SizedBox(
    width: width,
    height: height,
    child: ElevatedButton.icon(
      icon: Icon(icon, color: iconColor),
      label: Text(text, style: textStyle),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    ),
  );
}
