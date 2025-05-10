import 'package:flutter/material.dart';

// função que retorna a foto do perfil do usuário com imagem e ação personalizáveis
Widget fotoPerfil({
  required String imagePath,
  required VoidCallback onCameraTap,
}) {
  return Padding(
    padding: EdgeInsets.all(20),
    child: Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Foto de perfil
        CircleAvatar(
          radius: 70,
          backgroundImage: AssetImage(imagePath),
        ),

        // Botão de câmera sobreposto
        InkWell(
          onTap: onCameraTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(6),
            child: Icon(
              Icons.camera_alt,
              size: 20,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}