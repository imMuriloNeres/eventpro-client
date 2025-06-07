import 'package:eventpro_app/core/routes/router.dart';
import 'package:eventpro_app/core/themes/app_theme.dart';
import 'package:eventpro_app/controller/signup_controller.dart';
import 'package:eventpro_app/controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importe a biblioteca de inicialização de data
import 'package:intl/date_symbol_data_local.dart';

// NOVO: Importe o seu controller de inscrições
import 'package:eventpro_app/controller/subscription_controller.dart';

void main() async {
  // Garante que os widgets do Flutter sejam inicializados primeiro
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa os dados de formatação para o português do Brasil
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
        
        // ADICIONADO: Registra o SubscriptionController para uso global
        // Isso resolve o erro 'ProviderNotFoundException'.
        ChangeNotifierProvider(create: (_) => SubscriptionController()),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
      ),
    );
  }
}
