import 'package:flutter/material.dart';

// Função que cria o appbar do Perfil
PreferredSizeWidget appBarPerfil() {
  return AppBar(
    title: Text('Perfil'),
    centerTitle: true,
    toolbarHeight: 70,
    backgroundColor: Colors.white,
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(1.0),
      child: Container(
        color: Colors.black,
        height: 1,
      ),
    ),
  );
}