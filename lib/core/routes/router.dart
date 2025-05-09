import 'package:eventpro_app/screens/events_screen.dart';
import 'package:eventpro_app/screens/homepage_screen.dart';
import 'package:eventpro_app/screens/profile_screen.dart';
import 'package:eventpro_app/screens/search_screen.dart';
import 'package:eventpro_app/widgets/main_scaffold.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainScaffold(child: child); 
      },
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => HomePage(),
        ),
        GoRoute(
          path: '/search',
          name: 'search',
          builder: (context, state) => SearchScreen(),
        ),
        GoRoute(
          path: '/events',
          name: 'events',
          builder: (context, state) => EventScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => ProfileScreen(),
        ),
      ],
    ),
  ],
);
