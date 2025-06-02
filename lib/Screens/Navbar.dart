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
          icon: Icons.how_to_vote_outlined,
          activeIcon: Icons.how_to_vote,
          label: 'Vote',
          tooltip: 'Place your vote',
        ),
        NavItemData(
          icon: Icons.menu_book_outlined,
          activeIcon: Icons.menu_book,
          label: 'Order',
          tooltip: 'View and manage orders',
        ),
        NavItemData(
          icon: Icons.people_outline,
          activeIcon: Icons.people,
          label: 'User',
          tooltip: 'User management',
        ),
        NavItemData(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'Settings',
          tooltip: 'Manage settings',
        ),
      ];
    } else if (_userRole == 'Planner') {
      return [
        NavItemData(
          icon: Icons.how_to_vote_outlined,
          activeIcon: Icons.how_to_vote,
          label: 'Vote',
          tooltip: 'Place your vote',
        ),
        NavItemData(
          icon: Icons.menu_book_outlined,
          activeIcon: Icons.menu_book,
          label: 'Order',
          tooltip: 'Manage lunch menus',
        ),
        NavItemData(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'Settings',
          tooltip: 'Manage settings',
        ),
      ];
    } else {
      return [
        NavItemData(
          icon: Icons.how_to_vote_outlined,
          activeIcon: Icons.how_to_vote,
          label: 'Vote',
          tooltip: 'Place your vote',
        ),
        NavItemData(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'Settings',
          tooltip: 'Manage settings',
        ),
      ];
    }
  }

  // Removed unused method _getBottomNavItems
  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      // Reset and play animation for smoother transitions
      _controller.reset();
      _controller.forward();

      String message = '';
      if (_userRole == 'Admin') {
        switch (index) {
          case 0:
            message = 'Place your lunch vote';
            break;
          case 1:
            message = 'Manage lunch menus';
            break;
          case 2:
            message = 'Register new employee';
            break;
          case 3:
            message = 'Manage your profile';
            break;
        }
      } else if (_userRole == 'Planner') {
        switch (index) {
          case 0:
            message = 'Place your lunch vote';
            break;
          case 1:
            message = 'Manage lunch menus';
            break;
          case 2:
            message = 'Manage your profile';
            break;
        }
      } else {
        switch (index) {
          case 0:
            message = 'Place your lunch vote';
            break;
          case 1:
            message = 'Manage your profile';
            break;
        }
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.primaryColor,
        textColor: Colors.white,
      );
    }
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

    final currentScreen = _getScreens()[_selectedIndex];
    final navItems = _getNavItems();
    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        child: currentScreen,
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 15),
        height: 58, // Further reduced height to avoid overflow
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                navItems.length,
                (index) => Flexible(
                  child: _buildNavItem(navItems[index], index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavItemData item, int index) {
    final isSelected = _selectedIndex == index;
    final activeColor =
        AppColors.primaryColor; // Using app's primary color for selected items
    final inactiveColor = Colors.black87; // Black color for non-selected items

    return InkWell(
      onTap: () => _onItemTapped(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Use a lightweight icon that matches the design in the second image
            Icon(
              item.icon, // Always use outline version
              color: isSelected ? activeColor : inactiveColor,
              size: 18, // Smaller icon size as per design
            ),
            const SizedBox(height: 3), // Reduced spacing between icon and text
            Text(
              item.label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected
                    ? FontWeight.w500
                    : FontWeight.w400, // Slightly bolder for selected items
                fontSize: 9, // Smaller font size for text
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
