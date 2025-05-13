import 'package:flutter/material.dart';

PreferredSizeWidget appBarCustom({
  required String title,
  bool centerTitle = true,
  double toolbarHeight = 70.0,
  Color backgroundColor = Colors.white,
  IconData? iconRight,
  double iconSize = 24.0,
  Color iconColor = Colors.black,
  VoidCallback? onIconPressed,
}) {
  return AppBar(
    title: Text(title),
    centerTitle: centerTitle,
    toolbarHeight: toolbarHeight,
    backgroundColor: backgroundColor,
    elevation: 0,
    actions: iconRight != null
        ? [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: Icon(
                  iconRight,
                  size: iconSize,
                  color: iconColor,
                ),
                onPressed: onIconPressed,
              ),
            ),
          ]
        : null,
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1.0),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.black,
      ),
    ),
  );
}
