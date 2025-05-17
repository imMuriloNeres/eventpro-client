import 'package:eventpro_app/screens/config_screen.dart';
import 'package:eventpro_app/screens/edit_profile_screen.dart';
import 'package:eventpro_app/utils/botaopersonalizado.dart';
import 'package:eventpro_app/utils/criarappbar.dart';
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
      appBar: appBarCustom(
        title: 'Perfil',
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditarPerfil()),
                              );
                            },
                          ),
                        ]
                      ),
                    ),
                  ]
                ),
                Column(
                  children: [
                    criarListTiles(Icons.favorite_border, 'Favoritos', (){showMyBottomSheet(context);} ,iconColor: Colors.black,),
                    criarListTiles(Icons.history, 'Histórico de Eventos', (){}, iconColor: Colors.black,),
                    criarListTiles(Icons.settings, 'Configurações', (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ConfigPage()),
                      );
                    }, iconColor: Colors.black,),
                    criarListTiles(
                      Icons.logout,
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



void showMyBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // permite ocupar mais da tela
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.all(20),
            child: ListView(
              controller: scrollController,
              children: [
                Text('Eventos favoritos'),
                SizedBox(height: 20),
                Text('Mais conteúdo...'),
                SizedBox(height: 500), // aumenta artificialmente a altura
              ],
            ),
          );
        },
      );
    },
  );
}