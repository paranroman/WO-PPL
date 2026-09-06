import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../navigation/app_router.dart';

class BottomNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavigationShell({super.key, required this.navigationShell});

  void _onItemTapped(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        final String currentLocation = GoRouterState.of(context).uri.path;

        if (currentLocation == AppRoutes.home) {
          SystemNavigator.pop(); // Opsional
        } else {
          if (navigationShell.currentIndex != 0) {
            navigationShell.goBranch(0);
          }
        }
      },

      child: Scaffold(
        body: SafeArea(child: navigationShell),

        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFEEEEEE), width: 1.0),
            ),
          ),
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                currentIndex: currentIndex,
                onTap: () => _onItemTapped(context, 0),
              ),
              _buildNavItem(
                context: context,
                index: 1,
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
                currentIndex: currentIndex,
                onTap: () => _onItemTapped(context, 1),
              ),
              _buildNavItem(
                context: context,
                index: 2,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                currentIndex: currentIndex,
                onTap: () => _onItemTapped(context, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isActive = index == currentIndex;
    final activeColor = Color(0xFFB93F4A);
    final inactiveColor = const Color(0xFFF78DA7);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          isActive ? activeIcon : icon,
          size: 26,
          color: isActive ? activeColor : inactiveColor,
        ),
      ),
    );
  }
}
