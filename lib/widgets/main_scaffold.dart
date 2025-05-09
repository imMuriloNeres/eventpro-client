import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    final currentIndex = _getIndexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex,
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go('/home');
                  break;
                case 1:
                  context.go('/search');
                  break;
                case 2:
                  context.go('/events');
                  break;
                case 3:
                  context.go('/profile');
                  break;
              }
            },
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              _buildItem(icon: Icons.home, isSelected: currentIndex == 0),
              _buildItem(icon: Icons.search, isSelected: currentIndex == 1),
              _buildItem(icon: Icons.event, isSelected: currentIndex == 2),
              _buildItem(icon: Icons.person, isSelected: currentIndex == 3),
            ],
          ),
        ),
      ),
    );
  }

  int _getIndexFromLocation(String location) {
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/events')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  BottomNavigationBarItem _buildItem({required IconData icon, required bool isSelected}) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFE7F1FF),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF005BD4) : const Color(0xFF1E1E1E),
        ),
      ),
      label: '',
    );
  }
}
