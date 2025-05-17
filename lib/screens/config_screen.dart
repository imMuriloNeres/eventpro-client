import 'package:eventpro_app/utils/criarappbar.dart';
import 'package:flutter/material.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({
    super.key,
  });

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  bool isSwitched = false;

  /// Este método retorna um Switch corretamente
  Widget buildSwitch() {
    return Switch(
      value: isSwitched,
      onChanged: (value) {
        setState(() {
          isSwitched = value;
        });
      },
      activeColor: Colors.green,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: Colors.grey,
    );
  }

  Widget gerarBarraConfig2(){
  return Container(
    width: double.infinity,
    height: 50,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: const Color.fromARGB(179, 143, 143, 143), // Cor da borda
        width: 1.0,          // Espessura da borda
      ),
      borderRadius: BorderRadius.circular(5), // Cantos arredondados (opcional)
    ),
    child: Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Private Account'),
          buildSwitch(),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarCustom(
        title: 'Configurações',
        centerTitle: true,
        backgroundColor: Colors.white,
      
      ),
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromARGB(69, 159, 161, 165),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      'ACCOUNT',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18
                      ),
                    ),
                  ),
                ],
              ),
            gerarBarraConfig(),
            gerarBarraConfig2(),
            gerarBarraConfig2(),
            ],
          ),
        ),
      )
    );
  }
}


Widget gerarBarraConfig(){
  return Container(
    width: double.infinity,
    height: 50,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: const Color.fromARGB(179, 143, 143, 143),  // Cor da borda
        width: 1.0,          // Espessura da borda
      ),
      borderRadius: BorderRadius.circular(5), // Cantos arredondados (opcional)
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 10),
        Icon(Icons.person),
        SizedBox(width: 10),
        Text('Laura Valverde')
      ],
    ),
  );
}

