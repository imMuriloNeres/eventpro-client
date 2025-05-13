import 'package:eventpro_app/utils/criarappbar.dart';
import 'package:eventpro_app/utils/fotoperfil.dart';
import 'package:eventpro_app/utils/input_label.dart';
import 'package:flutter/material.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({super.key});

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  final nomeController = TextEditingController();
  final sobrenomeController = TextEditingController();
  final cpfController = TextEditingController();
  final nascimentoController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarCustom(
        title: 'Editar Perfil',
        centerTitle: true,
        backgroundColor: Colors.white,
        iconRight: Icons.check,
        iconColor: Colors.green,
        iconSize: 28.0,
        onIconPressed: () {
          print('Perfil salvo!!!');
        },
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(right: 15, left: 15, bottom: 15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    fotoPerfil( // função que retorna a foto de perfil
                      imagePath: 'assets/images/perfil.jpg',
                      onCameraTap: () {
                        print('Abrir seletor de imagem');
                      },
                    ), 
                  ],
                ),
                buildLabel('Nome'),
                TextField(controller: nomeController, decoration: inputStyle('Digite seu nome')),
            
                buildLabel('Sobrenome'),
                TextField(controller: sobrenomeController, decoration: inputStyle('Digite seu sobrenome')),
            
                buildLabel('CPF'),
                TextField(controller: cpfController, decoration: inputStyle('000.000.000-00')),
            
                buildLabel('Data de Nascimento'),
                TextField(controller: nascimentoController, decoration: inputStyle('DD/MM/AAAA')),
            
                buildLabel('E-mail'),
                TextField(controller: emailController, decoration: inputStyle('exemplo@email.com')),
            
                buildLabel('Telefone'),
                TextField(controller: telefoneController, decoration: inputStyle('(00) 00000-0000')),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

