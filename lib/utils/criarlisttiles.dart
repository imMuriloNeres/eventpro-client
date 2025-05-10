import 'package:flutter/material.dart';

// Função que cria ListTiles
Widget criarListTiles(
  IconData icone,
  String texto,
  VoidCallback onTap, {
  TextStyle? textStyle,
  Color? iconColor,
  Color? backgroundColor,
}) {
  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icone, color: iconColor),
        title: Text(
          texto,
          style: textStyle,
        ),
        trailing: Icon(Icons.chevron_right, color: iconColor),
        onTap: onTap,
        tileColor: backgroundColor,
      ),
    ),
  );
}
