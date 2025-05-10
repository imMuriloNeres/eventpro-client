import 'package:eventpro_app/appbars/appbarperfil.dart';
import 'package:eventpro_app/utils/botaopersonalizado.dart';
import 'package:eventpro_app/utils/criarlisttiles.dart';
import 'package:eventpro_app/utils/fotoperfil.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String nomeUsuario = "Laura Valverde";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarPerfil(), 
      body: SafeArea(
        child: Container(
          color: Colors.transparent,
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    fotoPerfil( // função que retorna a foto de perfil
                      imagePath: 'assets/images/perfil.jpg',
                      onCameraTap: () {
                        print('Abrir seletor de imagem');
                      },
                    ), 
                    Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Column(
                        children: [
                          // nome do usuário
                          Text(
                            nomeUsuario,  // variável que passa o nome
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          // botão Editar perfil
                          customButton(   // função que retorna botão personalizado
                            width: 160,
                            height: 45,
                            icon: Icons.edit,
                            iconColor: Colors.white,
                            text: 'Editar perfil',
                            textStyle: TextStyle(color: Colors.white),
                            color: Color.fromARGB(240, 0, 74, 173),
                            borderRadius: 10, // borda mais arredondada
                            onPressed: () {
                              print('Botão editar perfil clicado!');
                            },
                          ),
                        ]
                      ),
                    ),
                  ]
                ),
                Column(
                  children: [
                    criarListTiles(Icons.favorite_border, 'Favoritos', (){}, iconColor: Colors.black,),
                    criarListTiles(Icons.history, 'Histórico de Eventos', (){}, iconColor: Colors.black,),
                    criarListTiles(Icons.settings, 'Configurações', (){}, iconColor: Colors.black,),
                    criarListTiles(
                      Icons.chevron_right,
                      'Sair da conta', 
                      (){
                        print("Deslogado!!!");
                        }, 
                      textStyle: TextStyle(
                        color: Colors.red, 
                      ),
                      iconColor: Colors.red,
                      backgroundColor: Colors.red.withOpacity(0.1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

