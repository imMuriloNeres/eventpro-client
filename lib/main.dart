// lib/main.dart
import 'package:eventpro_app/core/routes/router.dart';
import 'package:eventpro_app/core/themes/app_theme.dart';
import 'package:eventpro_app/controller/signup_controller.dart';
import 'package:eventpro_app/controller/login_controller.dart';
import 'package:eventpro_app/controller/profile_controller.dart'; // Import the new controller
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventpro_app/controller/event_controller.dart';

// 1. Importe a biblioteca de inicialização de data
import 'package:intl/date_symbol_data_local.dart';

// 2. Transforme a função main em assíncrona
void main() async {
  // 3. Garante que os widgets do Flutter sejam inicializados primeiro
  WidgetsFlutterBinding.ensureInitialized();
  
  // 4. Inicializa os dados de formatação para o português do Brasil
  await initializeDateFormatting('pt_BR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignupController()),
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => ProfileController()), // Add the ProfileController
        ChangeNotifierProvider(create: (_) => EventsController()),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
      ),
    );
  }
}