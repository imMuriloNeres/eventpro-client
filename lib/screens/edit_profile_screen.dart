import 'package:eventpro_app/utils/fotoperfil.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({Key? key}) : super(key: key);

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

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    carregarPerfil();
  }

  Future<void> carregarPerfil() async {
    setState(() => _isLoading = true);

    final url = Uri.parse('http://localhost:3000/perfil');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        nomeController.text = data['nome'] ?? '';
        sobrenomeController.text = data['sobrenome'] ?? '';
        cpfController.text = data['cpf'] ?? '';
        nascimentoController.text = data['nascimento']?.split('T')[0] ?? '';
        emailController.text = data['email'] ?? '';
        telefoneController.text = data['telefone'] ?? '';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar perfil. Código: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> salvarPerfil() async {
    setState(() => _isLoading = true);

    final url = Uri.parse('http://localhost:3000/perfil');

    final body = {
      "nome": nomeController.text.trim(),
      "sobrenome": sobrenomeController.text.trim(),
      "cpf": cpfController.text.trim(),
      "nascimento": nascimentoController.text.trim(),
      "email": emailController.text.trim(),
      "telefone": telefoneController.text.trim(),
    };

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar perfil. Código: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  @override
  void dispose() {
    nomeController.dispose();
    sobrenomeController.dispose();
    cpfController.dispose();
    nascimentoController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    super.dispose();
  }

  Widget buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Text('Editar Perfil'),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : salvarPerfil,
          ),
        
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.black,
          ),
        ),
      ),
      body: 
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.white,
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView( 
                padding: const EdgeInsets.all(16.0),
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
                    buildTextField('Nome', nomeController),
                    buildTextField('Sobrenome', sobrenomeController),
                    buildTextField('CPF', cpfController, keyboardType: TextInputType.number),
                    buildTextField('Data de Nascimento (YYYY-MM-DD)', nascimentoController, keyboardType: TextInputType.datetime),
                    buildTextField('E-mail', emailController, keyboardType: TextInputType.emailAddress),
                    buildTextField('Telefone', telefoneController, keyboardType: TextInputType.phone),
                  ],
                ),
              ),
      ),
    );
  }
}
