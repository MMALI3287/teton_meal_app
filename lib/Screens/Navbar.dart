import 'package:flutter/material.dart';
import 'package:teton_meal_app/Styles/colors.dart';
import 'package:teton_meal_app/Screens/BottomNavPages/Votes/votes_page.dart';
import 'package:teton_meal_app/Screens/BottomNavPages/Menus/menu_page.dart';
import 'package:teton_meal_app/Screens/BottomNavPages/Account/accounts_page.dart';
import 'package:teton_meal_app/Screens/Register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teton_meal_app/services/auth_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _userRole = 'Diner';
  bool _isLoading = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchUserRole() async {
    try {
      final user = AuthService().currentUser;
      if (user != null) {
        setState(() {
          _userRole = user.role;
          _isLoading = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to fetch user role: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() => _isLoading = false);
    }
  }

  List<Widget> _getScreens() {
    if (_userRole == 'Admin') {
      return [
        const VotesPage(),
        const MenusPage(),
        const Register(),
        const AccountsPage(),
      ];
    } else if (_userRole == 'Planner') {
      return [
        const VotesPage(),
        const MenusPage(),
        const AccountsPage(),
      ];
    } else {
      return [
        const VotesPage(),
        const AccountsPage(),
      ];
    }
  }

  List<NavItemData> _getNavItems() {
    if (_userRole == 'Admin') {
      return [
        NavItemData(
          icon: Icons.poll,
          activeIcon: Icons.poll_outlined,
          label: 'Vote',
          tooltip: 'View and cast votes',
        ),
        NavItemData(
          icon: Icons.menu_book,
          activeIcon: Icons.menu_book_outlined,
          label: 'Menu',
          tooltip: 'View and manage menus',
        ),
        NavItemData(
          icon: Icons.app_registration,
          activeIcon: Icons.app_registration_outlined,
          label: 'Register',
          tooltip: 'Register new users',
        ),
        NavItemData(
          icon: Icons.account_circle,
          activeIcon: Icons.account_circle_outlined,
          label: 'Account',
          tooltip: 'Manage your account',
        ),
      ];
    } else if (_userRole == 'Planner') {
      return [
        NavItemData(
          icon: Icons.poll,
          activeIcon: Icons.poll_outlined,
          label: 'Vote',
          tooltip: 'View and cast votes',
        ),
        NavItemData(
          icon: Icons.menu_book,
          activeIcon: Icons.menu_book_outlined,
          label: 'Menu',
          tooltip: 'View and manage menus',
        ),
        NavItemData(
          icon: Icons.account_circle,
          activeIcon: Icons.account_circle_outlined,
          label: 'Account',
          tooltip: 'Manage your account',
        ),
      ];
    } else {
      return [
        NavItemData(
          icon: Icons.poll,
          activeIcon: Icons.poll_outlined,
          label: 'Vote',
          tooltip: 'View and cast votes',
        ),
        NavItemData(
          icon: Icons.account_circle,
          activeIcon: Icons.account_circle_outlined,
          label: 'Account',
          tooltip: 'Manage your account',
        ),
      ];
    }
  }

  List<BottomNavigationBarItem> _getBottomNavItems() {
    final navItems = _getNavItems();
    return navItems
        .map((item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: Icon(item.activeIcon),
              label: item.label,
              tooltip: item.tooltip,
            ))
        .toList();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    String message = '';
    switch (index) {
      case 0:
        message = 'Place your lunch order';
        break;
      case 1:
        message =
            _userRole == 'Diner' ? 'Manage your profile' : 'Manage lunch menus';
        break;
      case 2:
        message = _userRole == 'Admin'
            ? 'Register new employee'
            : 'Manage your profile';
        break;
      case 3:
        message = 'Manage your profile';
        break;
    }

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Loading...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Get current screen based on selected index
    final currentScreen = _getScreens()[_selectedIndex];
    final navItems = _getNavItems();

    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        child: currentScreen,
      ),
      bottomNavigationBar: Container(
        height: 85,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 15,
              offset: const Offset(0, -3),
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              navItems.length,
              (index) => _buildNavItem(navItems[index], index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavItemData item, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width / _getNavItems().length,
        padding: const EdgeInsets.symmetric(vertical: 8), // Increased padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 3, // Increased indicator height
              width: isSelected ? 25 : 0, // Increased indicator width
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8), // Increased padding
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                color: isSelected ? AppColors.primaryColor : Colors.grey[500],
                size: 24, // Increased icon size
              ),
            ),
            const SizedBox(height: 4), // Increased spacing
            Text(
              item.label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryColor : Colors.grey[500],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13, // Increased font size
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class for navigation items
class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String tooltip;

  NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.tooltip,
  });
}
