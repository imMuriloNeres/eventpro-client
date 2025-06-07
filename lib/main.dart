import 'package:eventpro_app/core/routes/router.dart';
import 'package:eventpro_app/core/themes/app_theme.dart';
import 'package:eventpro_app/controller/signup_controller.dart';
import 'package:eventpro_app/controller/login_controller.dart';
import 'package:eventpro_app/controller/profile_controller.dart';
import 'package:eventpro_app/controller/event_controller.dart';
import 'package:eventpro_app/controller/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Ensures that Flutter widgets are initialized first
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initializes date formatting for Brazilian Portuguese
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
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => EventsController()),
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