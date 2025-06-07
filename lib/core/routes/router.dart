import 'package:eventpro_app/controller/login_controller.dart';
import 'package:eventpro_app/screens/auth/screens/login_screen.dart';
import 'package:eventpro_app/screens/auth/screens/signup/signup_step_one.dart';
import 'package:eventpro_app/screens/auth/screens/signup/signup_step_two.dart';
import 'package:eventpro_app/screens/auth/screens/signup/signup_step_three.dart';
import 'package:eventpro_app/screens/auth/screens/signup/signup_success.dart';
import 'package:eventpro_app/screens/events_screen.dart';
import 'package:eventpro_app/screens/homepage_screen.dart';
import 'package:eventpro_app/screens/profile_screen.dart';
import 'package:eventpro_app/screens/search_screen.dart';
import 'package:eventpro_app/widgets/main_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:eventpro_app/screens/qr_scanner_screen.dart'; // Import the new screen

// A configuração do router agora está em uma classe para gerenciar o estado de login
class AppRouter {
  final LoginController loginController;

  AppRouter(this.loginController);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    // refreshListenable diz ao router para reavaliar a rota quando o loginController notificar mudanças
    refreshListenable: loginController,
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(path: '/signup', redirect: (context, state) => '/signup/step1'),
      GoRoute(
        path: '/signup/step1',
        name: 'signup-step1',
        builder: (context, state) => SignupStepOneScreen(),
      ),
      GoRoute(
        path: '/signup/step2',
        name: 'signup-step2',
        builder: (context, state) => SignupStepTwoScreen(),
      ),
      GoRoute(
        path: '/signup/step3',
        name: 'signup-step3',
        builder: (context, state) => const SignupStepThreeScreen(),
      ),
      GoRoute(
        path: '/signup/success',
        name: 'signup-success',
        builder: (context, state) => const SignupSuccessScreen(),
      ),

      // As rotas protegidas que precisam de login
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/events',
            name: 'events',
            builder: (context, state) => const EventsScreen(),
          ),
          // ROTA ADICIONADA: QR Scanner
          GoRoute(
            path: '/qr_scanner',
            name: 'qr_scanner',
            builder: (context, state) => const QRScannerScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    // A lógica de redirecionamento fica aqui
    redirect: (BuildContext context, GoRouterState state) {
      final bool isLoggedIn = loginController.currentUser != null;
      
      // Rotas que não exigem login
      final bool isPublicRoute = state.matchedLocation == '/login' || 
                                 state.matchedLocation.startsWith('/signup');

      // Se o usuário não está logado e tenta acessar uma rota protegida, redireciona para /login.
      if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }

      // Se o usuário está logado e tenta acessar uma rota pública (login/signup),
      // redireciona para a home.
      if (isLoggedIn && isPublicRoute) {
        return '/home';
      }

      // Em todos os outros casos, permite a navegação.
      return null;
    },
  );
}
